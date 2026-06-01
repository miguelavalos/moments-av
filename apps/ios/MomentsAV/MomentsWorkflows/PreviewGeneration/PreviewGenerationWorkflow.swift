import Foundation

@MainActor
final class PreviewGenerationWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var latestPreview: MomentArtifact?
    @Published private(set) var latestPreviewJob: MomentRenderJob?
    @Published private(set) var isGenerating = false
    @Published private(set) var isRefreshingStatus = false
    @Published private(set) var statusMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let authTokenProvider: any MomentsAuthTokenProviding
    private let creditBalanceProvider: any MomentsCreditBalanceProviding
    private let previewResultSaver: any MomentsPreviewResultSaving
    private let previewClient: MomentsPreviewClient
    private let statusClient: MomentsRenderStatusClient

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        authTokenProvider: any MomentsAuthTokenProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        previewResultSaver: any MomentsPreviewResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        previewClient: MomentsPreviewClient,
        statusClient: MomentsRenderStatusClient
    ) {
        self.currentUserProvider = currentUserProvider
        self.authTokenProvider = authTokenProvider
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
            statusMessage = "Sign in before reviewing the story."
            return
        }
        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            statusMessage = "Sign in again before reviewing the story."
            return
        }
        guard let project = activeWorkspace?.project else {
            statusMessage = "Create the draft and story before reviewing it."
            return
        }
        guard isConfigured else {
            statusMessage = "Story Review is not configured for this build."
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

        let generation = beginWorkflowGeneration()
        isGenerating = true
        statusMessage = "Avi is preparing the story review."

        do {
            statusMessage = try await PreviewGenerationRun.perform(
                ownerUserId: ownerUserId,
                bearerToken: bearerToken,
                projectId: projectId,
                project: project,
                template: template,
                previewClient: previewClient,
                previewResultSaver: previewResultSaver,
                workspaceObserver: workspaceObserver,
                shouldContinue: { isCurrentWorkflowGeneration(generation) }
            )
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = error.localizedDescription
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        isGenerating = false
    }

    func refreshStatus() async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = refreshMessages.signIn
            return
        }
        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            statusMessage = refreshMessages.signIn
            return
        }

        let generation = beginWorkflowGeneration()
        isRefreshingStatus = true
        statusMessage = nil

        do {
            statusMessage = try await RenderJobStatusRefresh.perform(
                ownerUserId: ownerUserId,
                bearerToken: bearerToken,
                projectId: activeWorkspace?.project.id,
                job: latestPreviewJob,
                messages: refreshMessages,
                statusClient: statusClient,
                statusUpdater: previewResultSaver,
                workspaceObserver: workspaceObserver,
                shouldContinue: { isCurrentWorkflowGeneration(generation) }
            )
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = error.localizedDescription
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        isRefreshingStatus = false
    }

    func reset(force: Bool = false) {
        guard force || (!isGenerating && !isRefreshingStatus) else { return }
        advanceWorkflowGeneration()
        isGenerating = false
        isRefreshingStatus = false
        clearActiveWorkspace()
        latestPreview = nil
        latestPreviewJob = nil
        statusMessage = nil
    }

    private func generateBlockMessage(_ availability: MomentsPreviewRules.Availability) -> String {
        MomentsPreviewRules.availabilityMessage(
            availability,
            missingProjectMessage: "Create the draft and story before reviewing it.",
            insufficientCreditsMessage: "Add credits before reviewing the story."
        ) ?? "Story review is not ready."
    }

    private var refreshMessages: RenderJobStatusRefreshMessages {
        RenderJobStatusRefreshMessages(
            signIn: "Sign in before refreshing story review status.",
            missingProject: "Open a project before refreshing story review status.",
            missingJob: "No story review job is available yet.",
            missingProviderRequest: MomentsRecoveryCopy.previewStatusMissing(),
            success: "Story review status updated."
        )
    }
}
