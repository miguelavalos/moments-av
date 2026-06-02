import Foundation

@MainActor
final class FinalRenderWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var finalExport: MomentArtifact?
    @Published private(set) var latestFinalJob: MomentRenderJob?
    @Published private(set) var renderPlan: MomentsRenderPlanResponse?
    @Published private(set) var isGenerating = false
    @Published private(set) var isRefreshingStatus = false
    @Published private(set) var pendingGalleryVideo: MomentsGalleryVideoRecord?
    @Published private(set) var canRetryFinalVideoDownload = false
    @Published private(set) var statusMessage: String?

    private var latestFinalJobProjectId: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let authTokenProvider: any MomentsAuthTokenProviding
    private let creditBalanceProvider: any MomentsCreditBalanceProviding
    private let finalRenderResultSaver: any MomentsFinalRenderResultSaving
    private let finalRenderClient: MomentsFinalRenderClient
    private let statusClient: MomentsRenderStatusClient
    private let galleryStore: any MomentsGalleryStoring
    private var downloadingArtifactIds = Set<String>()

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        authTokenProvider: any MomentsAuthTokenProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        finalRenderResultSaver: any MomentsFinalRenderResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        finalRenderClient: MomentsFinalRenderClient,
        statusClient: MomentsRenderStatusClient,
        galleryStore: any MomentsGalleryStoring = MomentsGalleryStore()
    ) {
        self.currentUserProvider = currentUserProvider
        self.authTokenProvider = authTokenProvider
        self.creditBalanceProvider = creditBalanceProvider
        self.finalRenderResultSaver = finalRenderResultSaver
        self.finalRenderClient = finalRenderClient
        self.statusClient = statusClient
        self.galleryStore = galleryStore
        super.init(workspaceObserver: workspaceObserver)
    }

    override func workspaceDidChange(_ workspace: MomentWorkspace?) {
        finalExport = workspace?.latestArtifact(kind: "final_export")
        let momentId = workspace?.moment.id
        if let workspaceFinalJob = workspace?.latestRenderJob(kind: "final") {
            latestFinalJob = workspaceFinalJob
            latestFinalJobProjectId = momentId
        } else if momentId == nil || latestFinalJobProjectId != momentId {
            latestFinalJob = nil
            latestFinalJobProjectId = momentId
        }
        scheduleLocalGalleryDownloadIfNeeded(workspace: workspace)
    }

    var isConfigured: Bool {
        finalRenderResultSaver.isConfigured && finalRenderClient.isConfigured && statusClient.isConfigured
    }

    func canGenerate(template: MomentTemplate, latestPreview: MomentArtifact?) -> Bool {
        guard let moment = activeWorkspace?.moment else { return false }
        return currentUserProvider.currentUserId != nil
            && isConfigured
            && MomentsFinalRenderRules.canGenerate(
                moment: moment,
                template: template,
                balance: creditBalanceProvider.currentCreditBalance,
                latestPreview: latestPreview
            )
            && !isGenerating
    }

    func generateFinalRender(
        momentId: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentDraftForm,
        removesWatermark: Bool = false,
        allowPreparedStory: Bool = false
    ) async {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = L10n.string("workflow.final.signInRender")
            return
        }
        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            statusMessage = L10n.string("workflow.final.signInAgainRender")
            return
        }
        guard isConfigured else {
            statusMessage = L10n.string("workflow.final.notConfigured")
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
                moment: activeWorkspace?.moment,
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
        statusMessage = L10n.string("workflow.final.preparing")

        do {
            if renderPlan == nil || renderPlan?.momentId != momentId {
                statusMessage = L10n.string("workflow.final.checkingPlan")
                let plan = try await finalRenderClient.prepareRenderPlan(
                    momentId: momentId,
                    bearerToken: bearerToken,
                    template: template,
                    creationStyle: creationStyle,
                    form: form
                )
                renderPlan = plan
                guard plan.canCreateVideo else {
                    statusMessage = L10n.string("workflow.final.needsUsableMedia")
                    isGenerating = false
                    return
                }
                statusMessage = L10n.string("workflow.final.planReady")
                isGenerating = false
                return
            }

            let startedJob = try await FinalRenderGenerationRun.perform(
                ownerUserId: ownerUserId,
                bearerToken: bearerToken,
                momentId: momentId,
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
            latestFinalJobProjectId = momentId
            statusMessage = L10n.string("workflow.final.creatingVideo")
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
                momentId: activeWorkspace?.moment.id,
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
        pendingGalleryVideo = nil
        canRetryFinalVideoDownload = false
        statusMessage = nil
    }

    func retryFinalVideoDownload() {
        guard let workspace = activeWorkspace,
              let artifact = workspace.latestArtifact(kind: "final_export"),
              artifact.status == "available"
        else {
            statusMessage = L10n.string("workflow.final.noDownloadReady")
            return
        }

        guard !downloadingArtifactIds.contains(artifact.id) else {
            statusMessage = L10n.string("workflow.final.downloadInProgress")
            return
        }

        canRetryFinalVideoDownload = false
        downloadingArtifactIds.insert(artifact.id)
        Task { [weak self] in
            await self?.downloadFinalExportToGallery(workspace: workspace, artifact: artifact)
        }
    }

    private func scheduleLocalGalleryDownloadIfNeeded(workspace: MomentWorkspace?) {
        guard
            let workspace,
            let artifact = workspace.latestArtifact(kind: "final_export"),
            artifact.status == "available",
            pendingGalleryVideo?.artifactId != artifact.id,
            !galleryStore.contains(artifactId: artifact.id),
            !downloadingArtifactIds.contains(artifact.id)
        else {
            return
        }

        downloadingArtifactIds.insert(artifact.id)
        canRetryFinalVideoDownload = false
        Task { [weak self] in
            await self?.downloadFinalExportToGallery(workspace: workspace, artifact: artifact)
        }
    }

    private func downloadFinalExportToGallery(
        workspace: MomentWorkspace,
        artifact: MomentArtifact
    ) async {
        defer { downloadingArtifactIds.remove(artifact.id) }

        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            statusMessage = L10n.string("workflow.final.signInAgainSaveLocal")
            return
        }

        do {
            statusMessage = L10n.string("workflow.final.savingToGallery")
            let download = try await finalRenderClient.prepareFinalArtifactDownload(
                momentId: workspace.moment.id,
                artifactId: artifact.id,
                bearerToken: bearerToken
            )
            let temporaryFileURL = try await finalRenderClient.downloadFinalArtifact(from: download)
            pendingGalleryVideo = try galleryStore.saveDownloadedVideo(
                temporaryFileURL: temporaryFileURL,
                momentId: workspace.moment.id,
                artifactId: artifact.id,
                title: workspace.moment.title,
                r2Key: download.r2Key,
                createdAt: Date()
            )
            canRetryFinalVideoDownload = false
            statusMessage = L10n.string("workflow.final.savedLocal")
        } catch {
            canRetryFinalVideoDownload = true
            statusMessage = L10n.string("workflow.final.saveLocalFailed")
        }
    }

    func finishFinalExportToGallery() {
        guard let pendingGalleryVideo else {
            statusMessage = L10n.string("workflow.final.downloadBeforeGallery")
            return
        }

        galleryStore.addRecord(pendingGalleryVideo)
        self.pendingGalleryVideo = nil
        canRetryFinalVideoDownload = false
        statusMessage = L10n.string("workflow.final.movedToGallery")
    }

    private func generateBlockMessage(_ availability: MomentsFinalRenderRules.Availability) -> String {
        MomentsFinalRenderRules.availabilityMessage(
            availability,
            missingProjectMessage: L10n.string("workflow.final.missingProject"),
            insufficientCreditsMessage: L10n.string("workflow.final.addCredits")
        ) ?? L10n.string("workflow.final.notReady")
    }

    private var refreshMessages: RenderJobStatusRefreshMessages {
        RenderJobStatusRefreshMessages(
            signIn: L10n.string("workflow.final.refreshSignIn"),
            missingProject: L10n.string("workflow.final.refreshMissingProject"),
            missingJob: L10n.string("workflow.final.refreshMissingJob"),
            missingProviderRequest: MomentsRecoveryCopy.finalRenderStatusMissing(),
            success: L10n.string("workflow.final.refreshSuccess")
        )
    }
}
