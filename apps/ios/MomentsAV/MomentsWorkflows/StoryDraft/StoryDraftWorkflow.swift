import Foundation

@MainActor
final class StoryDraftWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var generatedDraft: MomentsStoryDraftResponse?
    @Published private(set) var isDrafting = false
    @Published private(set) var statusMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let storyDraftSaver: any MomentsStoryDraftSaving
    private let storyClient: MomentsStoryClient
    private var resetGeneration = 0

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        storyDraftSaver: any MomentsStoryDraftSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        storyClient: MomentsStoryClient
    ) {
        self.currentUserProvider = currentUserProvider
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
        form: MomentDraftForm
    ) async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = "Sign in before drafting the story."
            return
        }
        guard isConfigured else {
            statusMessage = "Story drafting is not configured yet."
            return
        }

        let mediaAssets = activeWorkspace?.mediaAssets
        let availability = MomentsStoryDraftRules.availability(
            mediaAssets: mediaAssets,
            template: form.template
        )
        guard availability.canDraft, let mediaAssets else {
            statusMessage = generateBlockMessage(availability)
            return
        }

        let generation = resetGeneration
        isDrafting = true
        statusMessage = nil

        do {
            let draft = try await storyClient.generateDraft(
                projectId: projectId,
                ownerUserId: ownerUserId,
                form: form,
                mediaAssets: mediaAssets
            )
            guard isCurrent(generation) else { return }
            generatedDraft = draft
            try await storyDraftSaver.saveStoryDraft(
                ownerUserId: ownerUserId,
                projectId: projectId,
                draft: draft
            )
            guard isCurrent(generation) else { return }
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
            statusMessage = draft.helperCopy
        } catch {
            guard isCurrent(generation) else { return }
            statusMessage = error.localizedDescription
        }

        guard isCurrent(generation) else { return }
        isDrafting = false
    }

    func reset(force: Bool = false) {
        guard force || !isDrafting else { return }
        resetGeneration += 1
        isDrafting = false
        clearActiveWorkspace()
        generatedDraft = nil
        statusMessage = nil
    }

    private func isCurrent(_ generation: Int) -> Bool {
        generation == resetGeneration
    }

    private func generateBlockMessage(_ availability: MomentsStoryDraftRules.Availability) -> String {
        MomentsStoryDraftRules.availabilityMessage(
            availability,
            missingMediaMessage: "Add media before asking Avi for a story draft."
        ) ?? "Story draft is not ready to generate."
    }
}
