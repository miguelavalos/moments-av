import Foundation

@MainActor
final class PreviewGenerationWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var latestPreview: MomentArtifact?
    @Published private(set) var latestPreviewJob: MomentRenderJob?
    @Published private(set) var isGenerating = false
    @Published private(set) var isRefreshingStatus = false
    @Published private(set) var statusMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let creditBalanceProvider: any MomentsCreditBalanceProviding
    private let previewResultSaver: any MomentsPreviewResultSaving
    private let previewClient: MomentsPreviewClient
    private let statusClient: MomentsRenderStatusClient
    private var resetGeneration = 0

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        previewResultSaver: any MomentsPreviewResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        previewClient: MomentsPreviewClient,
        statusClient: MomentsRenderStatusClient
    ) {
        self.currentUserProvider = currentUserProvider
        self.creditBalanceProvider = creditBalanceProvider
        self.previewResultSaver = previewResultSaver
        self.previewClient = previewClient
        self.statusClient = statusClient
        super.init(workspaceObserver: workspaceObserver)
    }

    override func workspaceDidChange(_ workspace: MomentProjectWorkspace?) {
        latestPreview = workspace?.latestArtifact(kind: "preview")
        latestPreviewJob = workspace?.latestRenderJob(kind: "preview")
    }

    var isConfigured: Bool {
        previewResultSaver.isConfigured && previewClient.isConfigured && statusClient.isConfigured
    }

    func canGenerate(template: MomentTemplate) -> Bool {
        guard let project = activeWorkspace?.project else { return false }
        return currentUserProvider.currentUserId != nil
            && isConfigured
            && MomentsPreviewRules.canGenerate(
                project: project,
                template: template,
                balance: creditBalanceProvider.currentCreditBalance
            )
            && !isGenerating
    }

    func generatePreview(projectId: String, template: MomentTemplate) async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = "Sign in before generating a preview."
            return
        }
        guard let project = activeWorkspace?.project else {
            statusMessage = "Create the draft and story before generating a preview."
            return
        }
        guard isConfigured else {
            statusMessage = "Preview generation is not configured for this build."
            return
        }

        let availability = MomentsPreviewRules.availability(
            project: project,
            template: template,
            balance: creditBalanceProvider.currentCreditBalance
        )
        guard availability.canGenerate else {
            statusMessage = generateBlockMessage(availability)
            return
        }

        let generation = resetGeneration
        isGenerating = true
        statusMessage = "Avi is preparing a preview."

        do {
            let preview = try await previewClient.generatePreview(
                projectId: projectId,
                ownerUserId: ownerUserId,
                template: template,
                previewIndex: Int(project.previewCount) + 1
            )
            guard isCurrent(generation) else { return }
            try await previewResultSaver.savePreviewResult(
                ownerUserId: ownerUserId,
                projectId: projectId,
                preview: preview,
                template: template
            )
            guard isCurrent(generation) else { return }
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
            statusMessage = "Preview ready. You can still refine the story before final render."
        } catch {
            guard isCurrent(generation) else { return }
            statusMessage = error.localizedDescription
        }

        guard isCurrent(generation) else { return }
        isGenerating = false
    }

    func refreshStatus() async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = "Sign in before refreshing preview status."
            return
        }
        let refresh: RenderJobStatusRefresh
        do {
            refresh = try RenderJobStatusRefresh.make(
                projectId: activeWorkspace?.project.id,
                job: latestPreviewJob,
                missingProjectMessage: "Open a project before refreshing preview status.",
                missingJobMessage: "No preview render job is available yet.",
                missingProviderRequestMessage: "Preview status is missing its provider request id."
            )
        } catch {
            statusMessage = error.localizedDescription
            return
        }

        let generation = resetGeneration
        isRefreshingStatus = true
        statusMessage = nil

        do {
            try await refresh.updateStatus(
                ownerUserId: ownerUserId,
                statusClient: statusClient,
                statusUpdater: previewResultSaver,
                shouldContinue: { isCurrent(generation) }
            )
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: refresh.projectId)
            statusMessage = "Preview status updated."
        } catch {
            guard isCurrent(generation) else { return }
            statusMessage = error.localizedDescription
        }

        guard isCurrent(generation) else { return }
        isRefreshingStatus = false
    }

    func reset(force: Bool = false) {
        guard force || (!isGenerating && !isRefreshingStatus) else { return }
        resetGeneration += 1
        isGenerating = false
        isRefreshingStatus = false
        clearActiveWorkspace()
        latestPreview = nil
        latestPreviewJob = nil
        statusMessage = nil
    }

    private func isCurrent(_ generation: Int) -> Bool {
        generation == resetGeneration
    }

    private func generateBlockMessage(_ availability: MomentsPreviewRules.Availability) -> String {
        MomentsPreviewRules.availabilityMessage(
            availability,
            missingProjectMessage: "Create the draft and story before generating a preview.",
            insufficientCreditsMessage: "Add credits before generating a preview."
        ) ?? "Preview is not ready to generate."
    }
}
