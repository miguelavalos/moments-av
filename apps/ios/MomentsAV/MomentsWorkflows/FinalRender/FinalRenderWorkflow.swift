import Foundation

@MainActor
final class FinalRenderWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var finalExport: MomentArtifact?
    @Published private(set) var latestFinalJob: MomentRenderJob?
    @Published private(set) var isGenerating = false
    @Published private(set) var isRefreshingStatus = false
    @Published private(set) var statusMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let creditBalanceProvider: any MomentsCreditBalanceProviding
    private let finalRenderResultSaver: any MomentsFinalRenderResultSaving
    private let finalRenderClient: MomentsFinalRenderClient
    private let statusClient: MomentsRenderStatusClient

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        finalRenderResultSaver: any MomentsFinalRenderResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        finalRenderClient: MomentsFinalRenderClient,
        statusClient: MomentsRenderStatusClient
    ) {
        self.currentUserProvider = currentUserProvider
        self.creditBalanceProvider = creditBalanceProvider
        self.finalRenderResultSaver = finalRenderResultSaver
        self.finalRenderClient = finalRenderClient
        self.statusClient = statusClient
        super.init(workspaceObserver: workspaceObserver)
    }

    override func workspaceDidChange(_ workspace: MomentProjectWorkspace?) {
        finalExport = workspace?.latestArtifact(kind: "final_export")
        latestFinalJob = workspace?.latestRenderJob(kind: "final")
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

    func generateFinalRender(projectId: String, template: MomentTemplate) async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = "Sign in before rendering the final export."
            return
        }
        guard isConfigured else {
            statusMessage = "Final rendering is not configured for this build."
            return
        }

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

        let generation = beginWorkflowGeneration()
        isGenerating = true
        statusMessage = "Avi is preparing the final export."

        do {
            statusMessage = try await FinalRenderGenerationRun.perform(
                ownerUserId: ownerUserId,
                projectId: projectId,
                template: template,
                finalRenderClient: finalRenderClient,
                finalRenderResultSaver: finalRenderResultSaver,
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

        let generation = beginWorkflowGeneration()
        isRefreshingStatus = true
        statusMessage = nil

        do {
            statusMessage = try await RenderJobStatusRefresh.perform(
                ownerUserId: ownerUserId,
                projectId: activeWorkspace?.project.id,
                job: latestFinalJob,
                messages: refreshMessages,
                statusClient: statusClient,
                statusUpdater: finalRenderResultSaver,
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
        finalExport = nil
        latestFinalJob = nil
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
            missingProviderRequest: "Final render status is missing its provider request id.",
            success: "Final render status updated."
        )
    }
}
