import Foundation
import OSLog

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
    private let logger = Logger(subsystem: "com.avalsys.momentsav", category: "final-render")
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

    func canGenerate(template: MomentTemplate) -> Bool {
        guard activeWorkspace?.moment != nil else { return false }
        return currentUserProvider.currentUserId != nil
            && isConfigured
            && creditBalanceProvider.currentCreditBalance.spendable >= requiredCreditCost(
                template: template,
                removesWatermark: false
            )
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
        selectedMedia: [MomentsSelectedMedia],
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
        let selectedSourceLocalIdentifiers = selectedSourceLocalIdentifiersForFinalRender(from: selectedMedia)

        let needsRenderPlan = renderPlan == nil
            || renderPlan?.momentId != momentId
            || renderPlan?.watermark?.selectedRemoveWatermark != removesWatermark

        if allowPreparedStory {
            if !needsRenderPlan {
                let requiredCredits = requiredCreditCost(
                    template: template,
                    removesWatermark: removesWatermark
                )
                guard creditBalanceProvider.currentCreditBalance.spendable >= requiredCredits else {
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
                storySceneCount: activeWorkspace?.storyScenes.count ?? 0
            )
            guard availability.canGenerate else {
                statusMessage = generateBlockMessage(availability)
                return
            }
        }

        let generation = beginWorkflowGeneration()
        isGenerating = true
        if needsRenderPlan {
            renderPlan = nil
        }
        statusMessage = L10n.string("workflow.final.preparing")

        do {
            if needsRenderPlan {
                statusMessage = L10n.string("workflow.final.checkingPlan")
                logger.info("Preparing final render plan momentId=\(momentId, privacy: .public)")
                let plan = try await prepareRenderPlanWithUploadVisibilityRetry(
                    momentId: momentId,
                    bearerToken: bearerToken,
                    template: template,
                    creationStyle: creationStyle,
                    form: form,
                    removesWatermark: removesWatermark,
                    selectedSourceLocalIdentifiers: selectedSourceLocalIdentifiers
                )
                guard plan.canCreateVideo else {
                    renderPlan = plan
                    statusMessage = L10n.string("workflow.final.needsUsableMedia")
                    isGenerating = false
                    return
                }
                renderPlan = plan
                logger.info("Final render plan ready momentId=\(momentId, privacy: .public) planId=\(plan.planId, privacy: .public) cost=\(plan.plan.totalCreditCost, privacy: .public)")
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
            logger.info("Confirming final render momentId=\(momentId, privacy: .public) planId=\(renderPlan.planId, privacy: .public) cost=\(renderPlan.plan.totalCreditCost, privacy: .public) selectedMedia=\(selectedSourceLocalIdentifiers.count, privacy: .public)")
            let confirmed = try await finalRenderClient.confirmFinalRender(
                momentId: momentId,
                bearerToken: bearerToken,
                template: template,
                creationStyle: creationStyle,
                form: form,
                removesWatermark: removesWatermark,
                selectedSourceLocalIdentifiers: selectedSourceLocalIdentifiers,
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
        } catch let error as MomentsAPIError {
            guard isCurrentWorkflowGeneration(generation) else { return }
            logger.error("Final render API error code=\(error.code, privacy: .public) message=\(error.message, privacy: .public) momentId=\(momentId, privacy: .public)")
            if error.code == "moments_render_plan_stale" {
                renderPlan = nil
            }
            statusMessage = error.localizedDescription
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = MomentsRecoveryCopy.renderStartFailure()
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        isGenerating = false
    }

    private func prepareRenderPlanWithUploadVisibilityRetry(
        momentId: String,
        bearerToken: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentSetupForm,
        removesWatermark: Bool,
        selectedSourceLocalIdentifiers: [String]
    ) async throws -> MomentsRenderPlanResponse {
        var attempt = 0

        while true {
            do {
                return try await finalRenderClient.prepareRenderPlan(
                    momentId: momentId,
                    bearerToken: bearerToken,
                    template: template,
                    creationStyle: creationStyle,
                    form: form,
                    removesWatermark: removesWatermark,
                    selectedSourceLocalIdentifiers: selectedSourceLocalIdentifiers
                )
            } catch let error as MomentsAPIError where error.isRetryableMediaVisibilityError && attempt < 2 {
                attempt += 1
                try await Task.sleep(nanoseconds: UInt64(attempt) * 750_000_000)
            }
        }
    }

    func selectedSourceLocalIdentifiersForFinalRender(from selectedMedia: [MomentsSelectedMedia]) -> [String] {
        selectedSourceLocalIdentifiersForFinalRender(
            from: selectedMedia,
            workspaceMedia: activeWorkspace?.mediaAssets ?? []
        )
    }

    func selectedSourceLocalIdentifiersForFinalRender(
        from selectedMedia: [MomentsSelectedMedia],
        workspaceMedia: [MomentMediaAsset]
    ) -> [String] {
        let localSelection = selectedMedia
            .filter(\.selected)
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(\.sourceLocalIdentifier)

        if !localSelection.isEmpty {
            return localSelection
        }

        let selectedWorkspaceMedia = workspaceMedia.filter(\.selected)
        return (selectedWorkspaceMedia.isEmpty ? workspaceMedia : selectedWorkspaceMedia)
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { $0.platformMediaAssetId ?? $0.id }
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
            let refresh = try RenderJobStatusRefresh.make(
                momentId: activeWorkspace?.moment.id,
                job: latestFinalJob,
                missingMomentMessage: refreshMessages.missingMoment,
                missingJobMessage: refreshMessages.missingJob,
                missingProviderRequestMessage: refreshMessages.missingProviderRequest
            )
            let status = try await refresh.fetchStatus(
                bearerToken: bearerToken,
                statusClient: statusClient,
                usesProviderReconciliation: true
            )
            guard isCurrentWorkflowGeneration(generation) else { return }

            let didAttachFinalArtifact = try await refresh.saveCompletedFinalArtifactIfNeeded(
                ownerUserId: ownerUserId,
                status: status,
                workspace: activeWorkspace,
                statusUpdater: finalRenderResultSaver
            )
            guard isCurrentWorkflowGeneration(generation) else { return }

            do {
                try await refresh.saveStatus(
                    ownerUserId: ownerUserId,
                    status: status,
                    statusUpdater: finalRenderResultSaver
                )
            } catch {
                guard didAttachFinalArtifact else { throw error }
                logger.error("Final render status update failed after artifact attach momentId=\(refresh.momentId, privacy: .public) renderJobId=\(refresh.job.id, privacy: .public) reason=\(String(describing: error), privacy: .public)")
            }

            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, momentId: refresh.momentId)
            statusMessage = status.userMessage ?? refreshMessages.success
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = MomentsRecoveryCopy.renderRefreshFailure()
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        isRefreshingStatus = false
    }

    private func requiredCreditCost(template: MomentTemplate, removesWatermark: Bool) -> Int {
        renderPlan?.plan.totalCreditCost
            ?? MomentsCreditGate.finalRenderCreditCost(
                template: template,
                removesWatermark: removesWatermark,
                balance: creditBalanceProvider.currentCreditBalance
            )
    }

    func clearRenderPlan() {
        guard !isGenerating else { return }
        renderPlan = nil
        statusMessage = nil
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

private extension MomentsAPIError {
    var isRetryableMediaVisibilityError: Bool {
        code == "insufficient_allowed_media"
            || code == "moments_final_render_source_media_required"
            || code == "moments_render_timeline_duration_required"
    }
}
