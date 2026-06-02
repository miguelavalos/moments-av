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

        home.bind(to: workflows.inProgressMoments)
        home.bind(accountStateProvider: accountController)
        create.bind(
            accountStateProvider: accountController,
            momentCreationWorkflow: workflows.momentCreation,
            mediaUploadWorkflow: workflows.mediaUpload,
            storyPlanWorkflow: workflows.storyPlan,
            previewGenerationWorkflow: workflows.previewGeneration,
            finalRenderWorkflow: workflows.finalRender
        )
        inProgress.bind(to: workflows.inProgressMoments)
        inProgress.bind(accountStateProvider: accountController)
        avi.bind(to: workflows.inProgressMoments)
        avi.bind(accountStateProvider: accountController)
    }
}
