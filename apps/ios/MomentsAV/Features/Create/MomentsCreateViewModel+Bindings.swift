import Combine
import Foundation

extension MomentsCreateViewModel {
    func bindAccount(_ accountStateProvider: any MomentsAccountStateProviding) {
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

    func bindProjectCreation(_ workflow: ProjectCreationWorkflow) {
        Publishers.CombineLatest3(
            workflow.$isCreatingDraft,
            workflow.$activeProjectId,
            workflow.$errorMessage
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCreatingDraft, activeProjectId, draftErrorMessage in
                self?.applyProjectCreationState(
                    MomentsCreateProjectCreationState(
                        isCreatingDraft: isCreatingDraft,
                        activeProjectId: activeProjectId,
                        draftErrorMessage: draftErrorMessage
                    )
                )
            }
            .store(in: &cancellables)
    }

    func bindMediaUpload(_ workflow: MediaUploadWorkflow) {
        Publishers.CombineLatest3(
            workflow.$selectedMedia,
            workflow.$statusMessage,
            workflow.$isImporting
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedMedia, statusMessage, isImporting in
                self?.applyMediaUploadState(
                    MomentsCreateMediaUploadState(
                        selectedMedia: selectedMedia,
                        statusMessage: statusMessage,
                        isImporting: isImporting
                    )
                )
            }
            .store(in: &cancellables)
    }

    func bindStoryDraft(_ workflow: StoryDraftWorkflow) {
        Publishers.CombineLatest4(
            workflow.$activeWorkspace.map { $0?.storyScenes ?? [] },
            workflow.$generatedDraft.map { $0?.scenes ?? [] },
            workflow.$statusMessage,
            workflow.$isDrafting
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] savedScenes, generatedScenes, statusMessage, isDrafting in
                self?.applyStoryDraftState(
                    MomentsCreateStoryDraftState(
                        savedScenes: savedScenes,
                        generatedScenes: generatedScenes,
                        statusMessage: statusMessage,
                        isDrafting: isDrafting
                    )
                )
            }
            .store(in: &cancellables)
    }

    func bindPreviewGeneration(_ workflow: PreviewGenerationWorkflow) {
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

    func bindFinalRender(_ workflow: FinalRenderWorkflow) {
        Publishers.CombineLatest(
            Publishers.CombineLatest3(
                workflow.$finalExport,
                workflow.$latestFinalJob,
                workflow.$statusMessage
            ),
            Publishers.CombineLatest(
                workflow.$isGenerating,
                workflow.$isRefreshingStatus
            )
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content, flags in
                let (finalExport, latestFinalJob, statusMessage) = content
                let (isGenerating, isRefreshingStatus) = flags
                self?.applyFinalRenderState(
                    MomentsCreateFinalRenderState(
                        finalExport: finalExport,
                        latestFinalJob: latestFinalJob,
                        statusMessage: statusMessage,
                        isGenerating: isGenerating,
                        isRefreshingStatus: isRefreshingStatus
                    )
                )
            }
            .store(in: &cancellables)
    }
}
