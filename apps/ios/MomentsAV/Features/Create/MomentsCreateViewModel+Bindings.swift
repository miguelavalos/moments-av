import Combine
import Foundation

extension MomentsCreateViewModel {
    func bindWorkflowState(
        accountStateProvider: any MomentsAccountStateProviding,
        momentCreationWorkflow: MomentCreationWorkflow,
        mediaUploadWorkflow: MediaUploadWorkflow,
        storyPlanWorkflow: StoryPlanWorkflow,
        previewGenerationWorkflow: PreviewGenerationWorkflow,
        finalRenderWorkflow: FinalRenderWorkflow
    ) {
        bindAccount(accountStateProvider)
        bindMomentCreation(momentCreationWorkflow)
        bindMediaUpload(mediaUploadWorkflow)
        bindStoryPlan(storyPlanWorkflow)
        bindPreviewGeneration(previewGenerationWorkflow)
        bindFinalRender(finalRenderWorkflow)
    }

    private func bindAccount(_ accountStateProvider: any MomentsAccountStateProviding) {
        Publishers.CombineLatest(
            accountStateProvider.isSignedInPublisher,
            accountStateProvider.creditBalancePublisher
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSignedIn, balance in
                self?.applyAccountState(
                    MomentsCreateAccountState(isSignedIn: isSignedIn, balance: balance)
                )
            }
            .store(in: &cancellables)
    }

    private func bindMomentCreation(_ workflow: MomentCreationWorkflow) {
        Publishers.CombineLatest3(
            workflow.$isCreatingMoment,
            workflow.$activeMomentId,
            workflow.$errorMessage
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCreatingMoment, activeMomentId, setupErrorMessage in
                self?.applyMomentCreationState(
                    MomentsCreateMomentCreationState(
                        isCreatingMoment: isCreatingMoment,
                        activeMomentId: activeMomentId,
                        setupErrorMessage: setupErrorMessage
                    )
                )
            }
            .store(in: &cancellables)
    }

    private func bindMediaUpload(_ workflow: MediaUploadWorkflow) {
        Publishers.CombineLatest4(
            workflow.$selectedMedia,
            workflow.$statusMessage,
            workflow.$isImporting,
            workflow.$importProgress
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedMedia, statusMessage, isImporting, importProgress in
                self?.applyMediaUploadState(
                    MomentsCreateMediaUploadState(
                        selectedMedia: selectedMedia,
                        statusMessage: statusMessage,
                        isImporting: isImporting,
                        importProgress: importProgress
                    )
                )
            }
            .store(in: &cancellables)
    }

    private func bindStoryPlan(_ workflow: StoryPlanWorkflow) {
        Publishers.CombineLatest4(
            workflow.$activeWorkspace.map { $0?.storyScenes ?? [] },
            workflow.$generatedPlan.map { $0?.scenes ?? [] },
            workflow.$statusMessage,
            workflow.$isPlanning
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] savedScenes, generatedScenes, statusMessage, isPlanning in
                self?.applyStoryPlanState(
                    MomentsCreateStoryPlanState(
                        savedScenes: savedScenes,
                        generatedScenes: generatedScenes,
                        statusMessage: statusMessage,
                        isPlanning: isPlanning
                    )
                )
            }
            .store(in: &cancellables)
    }

    private func bindPreviewGeneration(_ workflow: PreviewGenerationWorkflow) {
        Publishers.CombineLatest(
            Publishers.CombineLatest4(
                workflow.$activeWorkspace,
                workflow.$latestPreview,
                workflow.$latestPreviewJob,
                workflow.$statusMessage
            ),
            Publishers.CombineLatest(
                workflow.$isGenerating,
                workflow.$isRefreshingStatus
            )
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content, flags in
                let (activeWorkspace, latestPreview, latestPreviewJob, statusMessage) = content
                let (isGenerating, isRefreshingStatus) = flags
                self?.applyPreviewGenerationState(
                    MomentsCreatePreviewGenerationState(
                        activeWorkspace: activeWorkspace,
                        latestPreview: latestPreview,
                        latestPreviewJob: latestPreviewJob,
                        statusMessage: statusMessage,
                        isGenerating: isGenerating,
                        isRefreshingStatus: isRefreshingStatus
                    )
                )
            }
            .store(in: &cancellables)
    }

    private func bindFinalRender(_ workflow: FinalRenderWorkflow) {
        Publishers.CombineLatest4(
            Publishers.CombineLatest4(
                workflow.$finalExport,
                workflow.$latestFinalJob,
                workflow.$renderPlan,
                workflow.$pendingGalleryVideo
            ),
            Publishers.CombineLatest(
                workflow.$isGenerating,
                workflow.$isRefreshingStatus
            ),
            workflow.$statusMessage,
            workflow.$canRetryFinalVideoDownload
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content, flags, statusMessage, canRetryFinalVideoDownload in
                let (finalExport, latestFinalJob, renderPlan, pendingGalleryVideo) = content
                let (isGenerating, isRefreshingStatus) = flags
                self?.applyFinalRenderState(
                    MomentsCreateFinalRenderState(
                        finalExport: finalExport,
                        latestFinalJob: latestFinalJob,
                        renderPlan: renderPlan,
                        pendingGalleryVideo: pendingGalleryVideo,
                        canRetryFinalVideoDownload: canRetryFinalVideoDownload,
                        statusMessage: statusMessage,
                        isGenerating: isGenerating,
                        isRefreshingStatus: isRefreshingStatus
                    )
                )
            }
            .store(in: &cancellables)
    }
}
