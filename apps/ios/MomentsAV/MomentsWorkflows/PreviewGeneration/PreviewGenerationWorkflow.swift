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

    override func workspaceDidChange(_ workspace: MomentWorkspace?) {
        latestPreview = workspace?.latestArtifact(kind: "preview")
        latestPreviewJob = workspace?.latestRenderJob(kind: "preview")
    }

    var isConfigured: Bool {
        previewResultSaver.isConfigured && previewClient.isConfigured && statusClient.isConfigured
    }

    func canGenerate(template: MomentTemplate) -> Bool {
        guard let moment = activeWorkspace?.moment else { return false }
        return currentUserProvider.currentUserId != nil
            && isConfigured
            && MomentsPreviewRules.canGenerate(
                moment: moment,
                template: template,
                balance: creditBalanceProvider.currentCreditBalance
            )
            && !isGenerating
    }

    func generatePreview(momentId: String, template: MomentTemplate, form: MomentDraftForm) async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = L10n.string("workflow.preview.signInReview")
            return
        }
        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            statusMessage = L10n.string("workflow.preview.signInAgainReview")
            return
        }
        guard let moment = activeWorkspace?.moment else {
            statusMessage = L10n.string("workflow.preview.missingProject")
            return
        }
        guard isConfigured else {
            statusMessage = L10n.string("workflow.preview.notConfigured")
            return
        }

        let availability = MomentsPreviewRules.availability(
            moment: moment,
            template: template,
            balance: creditBalanceProvider.currentCreditBalance
        )
        guard availability.canGenerate else {
            statusMessage = generateBlockMessage(availability)
            return
        }

        let generation = beginWorkflowGeneration()
        isGenerating = true
        statusMessage = L10n.string("workflow.preview.preparing")

        do {
            statusMessage = try await PreviewGenerationRun.perform(
                ownerUserId: ownerUserId,
                bearerToken: bearerToken,
                momentId: momentId,
                moment: moment,
                template: template,
                form: form,
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
                momentId: activeWorkspace?.moment.id,
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
            missingProjectMessage: L10n.string("workflow.preview.missingProject"),
            insufficientCreditsMessage: L10n.string("workflow.preview.addCredits")
        ) ?? L10n.string("workflow.preview.notReady")
    }

    private var refreshMessages: RenderJobStatusRefreshMessages {
        RenderJobStatusRefreshMessages(
            signIn: L10n.string("workflow.preview.refreshSignIn"),
            missingProject: L10n.string("workflow.preview.refreshMissingProject"),
            missingJob: L10n.string("workflow.preview.refreshMissingJob"),
            missingProviderRequest: MomentsRecoveryCopy.previewStatusMissing(),
            success: L10n.string("workflow.preview.refreshSuccess")
        )
    }
}
