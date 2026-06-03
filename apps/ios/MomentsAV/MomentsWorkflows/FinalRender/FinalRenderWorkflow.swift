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

    private var latestFinalJobMomentId: String?

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
            latestFinalJobMomentId = momentId
        } else if momentId == nil || latestFinalJobMomentId != momentId {
            latestFinalJob = nil
            latestFinalJobMomentId = momentId
        }
        scheduleLocalGalleryDownloadIfNeeded(workspace: workspace)
    }

    var isConfigured: Bool {
        finalRenderResultSaver.isConfigured && finalRenderClient.isConfigured && statusClient.isConfigured
    }

    func canGenerate(template: MomentTemplate, latestPreview: MomentArtifact?) -> Bool {
        guard activeWorkspace?.moment != nil else { return false }
        return currentUserProvider.currentUserId != nil
            && isConfigured
            && MomentsCreditGate.canAfford(template, balance: creditBalanceProvider.currentCreditBalance)
            && !isGenerating
    }

    func canPreparePlan() -> Bool {
        currentUserProvider.currentUserId != nil
            && isConfigured
            && activeWorkspace?.moment != nil
            && !isGenerating
    }

    func generateFinalRender(
        momentId: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentSetupForm,
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

        let needsRenderPlan = renderPlan == nil || renderPlan?.momentId != momentId

        if allowPreparedStory {
            if !needsRenderPlan {
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
            }
        } else {
            let availability = MomentsFinalRenderRules.availability(
                moment: activeWorkspace?.moment,
                template: template,
                balance: creditBalanceProvider.currentCreditBalance,
                latestPreview: activeWorkspace?.latestArtifact(kind: "preview"),
                storySceneCount: activeWorkspace?.storyScenes.count ?? 0
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
            if needsRenderPlan {
                statusMessage = L10n.string("workflow.final.checkingPlan")
                let plan = try await finalRenderClient.prepareRenderPlan(
                    momentId: momentId,
                    bearerToken: bearerToken,
                    template: template,
                    creationStyle: creationStyle,
                    form: form,
                    removesWatermark: removesWatermark
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

            guard let renderPlan else {
                statusMessage = L10n.string("workflow.final.checkingPlan")
                isGenerating = false
                return
            }

            statusMessage = L10n.string("workflow.final.creatingVideo")
            let confirmed = try await finalRenderClient.confirmFinalRender(
                momentId: momentId,
                bearerToken: bearerToken,
                template: template,
                creationStyle: creationStyle,
                form: form,
                removesWatermark: removesWatermark,
                planId: renderPlan.planId,
                renderOptionId: renderPlan.plan.renderOptionId,
                operationId: UUID().uuidString
            )
            self.renderPlan = confirmed.renderPlan

            guard isCurrentWorkflowGeneration(generation) else { return }

            statusMessage = L10n.string("workflow.final.savingStatus")
            let savedRenderJobId = try await saveStartedFinalRenderWithRetry(
                ownerUserId: ownerUserId,
                momentId: momentId,
                reservationId: confirmed.reservation.id,
                startedWorkflow: confirmed.workflow
            )

            guard isCurrentWorkflowGeneration(generation) else { return }

            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, momentId: momentId)
            let startedJob = MomentRenderJob(
                id: savedRenderJobId,
                kind: "final",
                status: confirmed.workflow.status,
                phase: "queued",
                progressPercent: 10,
                userMessage: L10n.string("workflow.final.creatingVideo"),
                canEditSetup: false,
                canRetry: false,
                targetDurationMs: Double(confirmed.renderPlan.plan.targetDurationMs),
                plannedAssetCount: Double(confirmed.renderPlan.plan.plannedAssetCount),
                usedAssetCount: Double(confirmed.renderPlan.plan.usedAssetCount),
                rejectedAssetCount: Double(confirmed.renderPlan.plan.rejectedAssetCount),
                rendererMode: confirmed.renderPlan.plan.rendererMode,
                workflowRunId: confirmed.workflow.workflowRunId,
                provider: "appsav-api",
                model: "moments-final-provider-async",
                providerRequestId: confirmed.workflow.renderJobId,
                errorCode: nil,
                errorMessage: nil,
                createdAt: Date().timeIntervalSince1970 * 1000,
                updatedAt: Date().timeIntervalSince1970 * 1000
            )
            latestFinalJob = startedJob
            latestFinalJobMomentId = momentId
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
        latestFinalJobMomentId = nil
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
            missingMomentMessage: L10n.string("workflow.final.missingMoment"),
            insufficientCreditsMessage: L10n.string("workflow.final.addCredits")
        ) ?? L10n.string("workflow.final.notReady")
    }

    private func saveStartedFinalRenderWithRetry(
        ownerUserId: String,
        momentId: String,
        reservationId: String,
        startedWorkflow: MomentsStartWorkflowResponse
    ) async throws -> String {
        let retryPolicy = MomentsNetworkRetryPolicy()
        var attempt = 0

        while true {
            do {
                return try await finalRenderResultSaver.saveStartedFinalRender(
                    ownerUserId: ownerUserId,
                    momentId: momentId,
                    reservationId: reservationId,
                    startedWorkflow: startedWorkflow
                )
            } catch {
                guard retryPolicy.shouldRetry(error: error, attempt: attempt) else {
                    throw error
                }

                attempt += 1
                try await Task.sleep(nanoseconds: retryPolicy.delayNanoseconds(forAttempt: attempt))
            }
        }
    }

    private var refreshMessages: RenderJobStatusRefreshMessages {
        RenderJobStatusRefreshMessages(
            signIn: L10n.string("workflow.final.refreshSignIn"),
            missingMoment: L10n.string("workflow.final.refreshMissingMoment"),
            missingJob: L10n.string("workflow.final.refreshMissingJob"),
            missingProviderRequest: MomentsRecoveryCopy.finalRenderStatusMissing(),
            success: L10n.string("workflow.final.refreshSuccess")
        )
    }
}
