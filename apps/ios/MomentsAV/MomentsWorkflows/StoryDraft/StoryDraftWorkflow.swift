import Foundation
import OSLog

@MainActor
final class StoryDraftWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var generatedDraft: MomentsStoryDraftResponse?
    @Published private(set) var isDrafting = false
    @Published private(set) var statusMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let authTokenProvider: any MomentsAuthTokenProviding
    private let storyDraftSaver: any MomentsStoryDraftSaving
    private let storyClient: MomentsStoryClient
    private let logger = Logger(subsystem: "com.avalsys.momentsav", category: "story")

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
    ) async -> Bool {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = L10n.string("workflow.story.signInDraft")
            return false
        }
        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            statusMessage = L10n.string("workflow.story.signInAgainDraft")
            return false
        }
        guard isConfigured else {
            statusMessage = L10n.string("workflow.story.notConfigured")
            return false
        }

        let media = persistedMedia ?? storyMedia(from: selectedMedia, fallbackMediaAssets: activeWorkspace?.mediaAssets)
        let storyInputSignature = MomentsStoryDraftInputSignature.make(
            projectId: projectId,
            form: form,
            selectedMedia: media
        )
        let availability = MomentsMediaRules.availability(
            template: form.template,
            selectedCount: media.filter(\.selected).count
        )
        guard availability.canUseSelection else {
            statusMessage = generateBlockMessage(availability)
            return false
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
            guard isCurrentWorkflowGeneration(generation) else { return false }
            try validateDraftMediaReferences(draft, availableMedia: media)
            generatedDraft = draft
            do {
                try await storyDraftSaver.saveStoryDraft(
                    ownerUserId: ownerUserId,
                    projectId: projectId,
                    draft: draft,
                    storyInputSignature: storyInputSignature
                )
            } catch {
                logger.error("Story draft save failed projectId=\(projectId, privacy: .public) error=\(String(describing: error), privacy: .public)")
                throw StoryDraftWorkflowError.saveFailed
            }
            guard isCurrentWorkflowGeneration(generation) else { return false }
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
            statusMessage = draft.helperCopy
        } catch let error as StoryDraftWorkflowError {
            guard isCurrentWorkflowGeneration(generation) else { return false }
            logger.error("Story draft workflow failed projectId=\(projectId, privacy: .public) reason=\(error.localizedDescription, privacy: .public)")
            statusMessage = error.localizedDescription
            isDrafting = false
            return false
        } catch let error as LocalizedError {
            guard isCurrentWorkflowGeneration(generation) else { return false }
            logger.error("Story draft request failed projectId=\(projectId, privacy: .public) error=\(String(describing: error), privacy: .public)")
            statusMessage = MomentsRecoveryCopy.storyFailure()
            isDrafting = false
            return false
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return false }
            logger.error("Story draft failed projectId=\(projectId, privacy: .public) error=\(String(describing: error), privacy: .public)")
            statusMessage = MomentsRecoveryCopy.storyFailure()
            isDrafting = false
            return false
        }

        guard isCurrentWorkflowGeneration(generation) else { return false }
        isDrafting = false
        return true
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

    private func validateDraftMediaReferences(
        _ draft: MomentsStoryDraftResponse,
        availableMedia: [MomentsStoryDraftMedia]
    ) throws {
        let availableMediaIds = Set(availableMedia.map(\.mediaAssetId))
        let missingMediaIds = draft.scenes
            .flatMap(\.mediaAssetIds)
            .filter { !availableMediaIds.contains($0) }

        guard missingMediaIds.isEmpty else {
            throw StoryDraftWorkflowError.invalidMediaReferences
        }
    }

    private func generateBlockMessage(_ availability: MomentsMediaRules.Availability) -> String {
        switch availability.blockReason {
        case nil:
            return L10n.string("create.story.status.ready")
        case .tooFewSelected(let missingCount):
            let label = missingCount == 1
                ? L10n.string("media.photoOrClip.singular")
                : L10n.string("media.photoOrClip.plural")
            return L10n.string("create.story.status.tooFew", missingCount, label)
        case .tooManySelected(let extraCount):
            let label = extraCount == 1
                ? L10n.string("media.photoOrClip.singular")
                : L10n.string("media.photoOrClip.plural")
            return L10n.string("create.story.status.tooMany", extraCount, label)
        }
    }
}

private enum StoryDraftWorkflowError: LocalizedError {
    case invalidMediaReferences
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .invalidMediaReferences:
            L10n.string("create.story.error.invalidMediaReferences")
        case .saveFailed:
            L10n.string("create.story.error.saveFailed")
        }
    }
}
