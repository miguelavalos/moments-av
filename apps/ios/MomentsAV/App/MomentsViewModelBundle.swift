import Foundation

@MainActor
struct MomentsViewModelBundle {
    let home: MomentsHomeViewModel
    let create: MomentsCreateViewModel
    let inProgress: MomentsInProgressViewModel
    let gallery: MomentsGalleryViewModel
    let avi: MomentsAviViewModel

    init(accountController: AccountController, workflows: MomentsWorkflowBundle) {
        home = MomentsHomeViewModel()
        create = MomentsCreateViewModel()
        inProgress = MomentsInProgressViewModel()
        gallery = MomentsGalleryViewModel()
        avi = MomentsAviViewModel()

        home.bind(to: workflows.projectsList)
        home.bind(accountStateProvider: accountController)
        create.bind(
            accountStateProvider: accountController,
            projectCreationWorkflow: workflows.projectCreation,
            mediaUploadWorkflow: workflows.mediaUpload,
            storyDraftWorkflow: workflows.storyDraft,
            previewGenerationWorkflow: workflows.previewGeneration,
            finalRenderWorkflow: workflows.finalRender
        )
        inProgress.bind(to: workflows.projectsList)
        inProgress.bind(accountStateProvider: accountController)
        avi.bind(to: workflows.projectsList)
        avi.bind(accountStateProvider: accountController)
    }
}
