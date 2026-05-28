import Foundation

@MainActor
final class StoryDraftWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var generatedDraft: MomentsStoryDraftResponse?
    @Published private(set) var isDrafting = false
    @Published private(set) var statusMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let authTokenProvider: any MomentsAuthTokenProviding
    private let storyDraftSaver: any MomentsStoryDraftSaving
    private let storyClient: MomentsStoryClient

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        authTokenProvider: any MomentsAuthTokenProviding,
        storyDraftSaver: any MomentsStoryDraftSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        storyClient: MomentsStoryClient
    ) {
        self.currentUserProvider = currentUserProvider
        self.authTokenProvider = authTokenProvider
        self.storyDraftSaver = storyDraftSaver
        self.storyClient = storyClient
        super.init(workspaceObserver: workspaceObserver)
    }

    var isConfigured: Bool {
        storyDraftSaver.isConfigured && storyClient.isConfigured
    }

    func canDraft(template: MomentTemplate) -> Bool {
        return currentUserProvider.currentUserId != nil
            && isConfigured
            && MomentsStoryDraftRules.availability(
                mediaAssets: activeWorkspace?.mediaAssets,
                template: template
            ).canDraft
            && !isDrafting
    }

    func generateDraft(
        projectId: String,
        form: MomentDraftForm,
        selectedMedia: [MomentsSelectedMedia],
        persistedMedia: [MomentsStoryDraftMedia]? = nil
    ) async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = "Sign in before drafting the story."
            return
        }
        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            statusMessage = "Sign in again before drafting the story."
            return
        }
        guard isConfigured else {
            statusMessage = "Story drafting is not configured yet."
            return
        }

        let media = persistedMedia ?? storyMedia(from: selectedMedia, fallbackMediaAssets: activeWorkspace?.mediaAssets)
        let availability = MomentsMediaRules.availability(
            template: form.template,
            selectedCount: media.filter(\.selected).count
        )
        guard availability.canUseSelection else {
            statusMessage = generateBlockMessage(availability)
            return
        }

        let generation = beginWorkflowGeneration()
        isDrafting = true
        statusMessage = nil

        do {
            let draft = try await storyClient.generateDraft(
                projectId: projectId,
                ownerUserId: ownerUserId,
                bearerToken: bearerToken,
                form: form,
                selectedMedia: media
            )
            guard isCurrentWorkflowGeneration(generation) else { return }
            generatedDraft = draft
            try await storyDraftSaver.saveStoryDraft(
                ownerUserId: ownerUserId,
                projectId: projectId,
                draft: draft
            )
            guard isCurrentWorkflowGeneration(generation) else { return }
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
            statusMessage = draft.helperCopy
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = "Couldn’t prepare the story. Please try again."
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        isDrafting = false
    }

    func reset(force: Bool = false) {
        guard force || !isDrafting else { return }
        advanceWorkflowGeneration()
        isDrafting = false
        clearActiveWorkspace()
        generatedDraft = nil
        statusMessage = nil
    }

    private func storyMedia(
        from selectedMedia: [MomentsSelectedMedia],
        fallbackMediaAssets: [MomentMediaAsset]?
    ) -> [MomentsStoryDraftMedia] {
        if !selectedMedia.isEmpty {
            return selectedMedia
                .filter(\.selected)
                .sorted { $0.sortOrder < $1.sortOrder }
                .map {
                    MomentsStoryDraftMedia(
                        mediaAssetId: $0.id.uuidString,
                        mediaKind: $0.kind,
                        sortOrder: $0.sortOrder,
                        selected: $0.selected,
                        moderationStatus: "pending"
                    )
                }
        }

        return (fallbackMediaAssets ?? [])
            .filter(\.selected)
            .sorted { $0.sortOrder < $1.sortOrder }
            .map {
                MomentsStoryDraftMedia(
                    mediaAssetId: $0.id,
                    mediaKind: $0.kind,
                    sortOrder: Int($0.sortOrder),
                    selected: $0.selected,
                    moderationStatus: $0.moderationStatus
                )
            }
    }

    private func generateBlockMessage(_ availability: MomentsMediaRules.Availability) -> String {
        switch availability.blockReason {
        case nil:
            return "Story plan is ready."
        case .tooFewSelected(let missingCount):
            let label = missingCount == 1 ? "photo or clip" : "photos or clips"
            return "Add \(missingCount) more \(label) before preparing the story."
        case .tooManySelected(let extraCount):
            let label = extraCount == 1 ? "photo or clip" : "photos or clips"
            return "Remove \(extraCount) \(label) before preparing the story."
        }
    }
}
