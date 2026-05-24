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
    private var resetGeneration = 0

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        projectRepository: any MomentsFinalRenderResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        finalRenderClient: MomentsFinalRenderClient,
        statusClient: MomentsRenderStatusClient
    ) {
        self.currentUserProvider = currentUserProvider
        self.creditBalanceProvider = creditBalanceProvider
        self.finalRenderResultSaver = projectRepository
        self.finalRenderClient = finalRenderClient
        self.statusClient = statusClient
        super.init(workspaceObserver: workspaceObserver)
    }

    override func workspaceDidChange(_ workspace: MomentProjectWorkspace?) {
        finalExport = workspace?.artifacts.last(where: { $0.kind == "final_export" })
        latestFinalJob = workspace?.renderJobs
            .filter { $0.kind == "final" }
            .sorted { $0.updatedAt < $1.updatedAt }
            .last
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
            latestPreview: activeWorkspace?.artifacts.last(where: { $0.kind == "preview" })
        )
        guard availability.canGenerate else {
            statusMessage = generateBlockMessage(availability)
            return
        }

        let generation = resetGeneration
        isGenerating = true
        statusMessage = "Avi is preparing the final export."

        do {
            let finalRender = try await finalRenderClient.generateFinalRender(
                projectId: projectId,
                ownerUserId: ownerUserId,
                template: template
            )
            guard isCurrent(generation) else { return }
            try await finalRenderResultSaver.saveFinalRenderResult(
                ownerUserId: ownerUserId,
                projectId: projectId,
                finalRender: finalRender,
                template: template
            )
            guard isCurrent(generation) else { return }
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
            statusMessage = "Export ready. Credits were committed for the delivered render."
        } catch {
            guard isCurrent(generation) else { return }
            statusMessage = error.localizedDescription
        }

        guard isCurrent(generation) else { return }
        isGenerating = false
    }

    func refreshStatus() async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = "Sign in before refreshing final render status."
            return
        }
        let refresh: RenderJobStatusRefresh
        do {
            refresh = try RenderJobStatusRefresh.make(
                projectId: activeWorkspace?.project.id,
                job: latestFinalJob,
                missingProjectMessage: "Open a project before refreshing final status.",
                missingJobMessage: "No final render job is available yet.",
                missingProviderRequestMessage: "Final render status is missing its provider request id."
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
                statusUpdater: finalRenderResultSaver,
                shouldContinue: { isCurrent(generation) }
            )
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: refresh.projectId)
            statusMessage = "Final render status updated."
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
        finalExport = nil
        latestFinalJob = nil
        statusMessage = nil
    }

    private func isCurrent(_ generation: Int) -> Bool {
        generation == resetGeneration
    }

    private func generateBlockMessage(_ availability: MomentsFinalRenderRules.Availability) -> String {
        MomentsFinalRenderRules.availabilityMessage(
            availability,
            missingProjectMessage: "Create or continue a draft before rendering the final export.",
            insufficientCreditsMessage: "Add credits before final render."
        ) ?? "Final export is not ready to render."
    }
}
