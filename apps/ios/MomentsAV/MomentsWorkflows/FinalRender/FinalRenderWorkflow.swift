import Foundation

@MainActor
final class FinalRenderWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var finalExport: MomentArtifact?
    @Published private(set) var latestFinalJob: MomentRenderJob?
    @Published private(set) var renderPlan: MomentsRenderPlanResponse?
    @Published private(set) var isGenerating = false
    @Published private(set) var isRefreshingStatus = false
    @Published private(set) var statusMessage: String?

    private var latestFinalJobProjectId: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let authTokenProvider: any MomentsAuthTokenProviding
    private let creditBalanceProvider: any MomentsCreditBalanceProviding
    private let finalRenderResultSaver: any MomentsFinalRenderResultSaving
    private let finalRenderClient: MomentsFinalRenderClient
    private let statusClient: MomentsRenderStatusClient

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        authTokenProvider: any MomentsAuthTokenProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        finalRenderResultSaver: any MomentsFinalRenderResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        finalRenderClient: MomentsFinalRenderClient,
        statusClient: MomentsRenderStatusClient
    ) {
        self.currentUserProvider = currentUserProvider
        self.authTokenProvider = authTokenProvider
        self.creditBalanceProvider = creditBalanceProvider
        self.finalRenderResultSaver = finalRenderResultSaver
        self.finalRenderClient = finalRenderClient
        self.statusClient = statusClient
        super.init(workspaceObserver: workspaceObserver)
    }

    override func workspaceDidChange(_ workspace: MomentProjectWorkspace?) {
        finalExport = workspace?.latestArtifact(kind: "final_export")
        let projectId = workspace?.project.id
        if let workspaceFinalJob = workspace?.latestRenderJob(kind: "final") {
            latestFinalJob = workspaceFinalJob
            latestFinalJobProjectId = projectId
        } else if projectId == nil || latestFinalJobProjectId != projectId {
            latestFinalJob = nil
            latestFinalJobProjectId = projectId
        }
    }

    var isConfigured: Bool {
        finalRenderResultSaver.isConfigured && finalRenderClient.isConfigured && statusClient.isConfigured
    }

    func canGenerate(template: MomentTemplate, latestPreview: MomentArtifact?) -> Bool {
        guard let project = activeWorkspace?.project else { return false }
        return currentUserProvider.currentUserId != nil
            && isConfigured
            && MomentsFinalRenderRules.canGenerate(
                project: project,
                template: template,
                balance: creditBalanceProvider.currentCreditBalance,
                latestPreview: latestPreview
            )
            && !isGenerating
    }

    func generateFinalRender(
        projectId: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentDraftForm,
        removesWatermark: Bool = false,
        allowPreparedStory: Bool = false
    ) async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = "Sign in before rendering the final export."
            return
        }
        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            statusMessage = "Sign in again before rendering the final export."
            return
        }
        guard isConfigured else {
            statusMessage = "Final rendering is not configured for this build."
            return
        }

        if allowPreparedStory {
            guard MomentsCreditGate.canAffordFinalRender(
                template: template,
                removesWatermark: removesWatermark,
                balance: creditBalanceProvider.currentCreditBalance
            ) else {
                let requiredCredits = MomentsCreditGate.finalRenderCreditCost(
                    template: template,
                    removesWatermark: removesWatermark,
                    balance: creditBalanceProvider.currentCreditBalance
                )
                statusMessage = MomentsCreateAvailabilityCopy.finalRenderInsufficientCredits(
                    missingCredits: max(0, requiredCredits - creditBalanceProvider.currentCreditBalance.spendable)
                )
                return
            }
        } else {
            let availability = MomentsFinalRenderRules.availability(
                project: activeWorkspace?.project,
                template: template,
                balance: creditBalanceProvider.currentCreditBalance,
                latestPreview: activeWorkspace?.latestArtifact(kind: "preview")
            )
            guard availability.canGenerate else {
                statusMessage = generateBlockMessage(availability)
                return
            }
        }

        let generation = beginWorkflowGeneration()
        isGenerating = true
        statusMessage = "Avi is preparing the final export."

        do {
            if renderPlan == nil || renderPlan?.projectId != projectId {
                statusMessage = "Checking the video plan."
                let plan = try await finalRenderClient.prepareRenderPlan(
                    projectId: projectId,
                    bearerToken: bearerToken,
                    template: template,
                    creationStyle: creationStyle,
                    form: form
                )
                renderPlan = plan
                guard plan.canCreateVideo else {
                    statusMessage = "Avi needs usable media before creating the video."
                    isGenerating = false
                    return
                }
                statusMessage = "Video plan ready. Review it before creating the video."
                isGenerating = false
                return
            }

            let startedJob = try await FinalRenderGenerationRun.perform(
                ownerUserId: ownerUserId,
                bearerToken: bearerToken,
                projectId: projectId,
                template: template,
                creationStyle: creationStyle,
                form: form,
                balance: creditBalanceProvider.currentCreditBalance,
                removesWatermark: removesWatermark,
                finalRenderClient: finalRenderClient,
                finalRenderResultSaver: finalRenderResultSaver,
                workspaceObserver: workspaceObserver,
                updateStatus: { statusMessage = $0 },
                shouldContinue: { isCurrentWorkflowGeneration(generation) }
            )
            latestFinalJob = startedJob
            latestFinalJobProjectId = projectId
            statusMessage = "Avi is creating the video. You can check progress here."
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = MomentsRecoveryCopy.renderStartFailure()
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
                job: latestFinalJob,
                messages: refreshMessages,
                statusClient: statusClient,
                statusUpdater: finalRenderResultSaver,
                workspaceObserver: workspaceObserver,
                usesProviderReconciliation: true,
                shouldContinue: { isCurrentWorkflowGeneration(generation) }
            )
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = MomentsRecoveryCopy.renderRefreshFailure()
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
        finalExport = nil
        latestFinalJob = nil
        latestFinalJobProjectId = nil
        renderPlan = nil
        statusMessage = nil
    }

    private func generateBlockMessage(_ availability: MomentsFinalRenderRules.Availability) -> String {
        MomentsFinalRenderRules.availabilityMessage(
            availability,
            missingProjectMessage: "Start or continue a project before rendering the final export.",
            insufficientCreditsMessage: "Add credits before final render."
        ) ?? "Final export is not ready to render."
    }

    private var refreshMessages: RenderJobStatusRefreshMessages {
        RenderJobStatusRefreshMessages(
            signIn: "Sign in before refreshing final render status.",
            missingProject: "Open a project before refreshing final status.",
            missingJob: "No final render job is available yet.",
            missingProviderRequest: MomentsRecoveryCopy.finalRenderStatusMissing(),
            success: "Video status updated."
        )
    }
}
