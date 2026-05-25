import Foundation

@MainActor
struct MomentsViewModelBundle {
    let home: MomentsHomeViewModel
    let create: MomentsCreateViewModel
    let projects: MomentsProjectsViewModel
    let avi: MomentsAviViewModel

    init(accountController: AccountController, workflows: MomentsWorkflowBundle) {
        home = MomentsHomeViewModel()
        create = MomentsCreateViewModel()
        projects = MomentsProjectsViewModel()
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
        projects.bind(to: workflows.projectsList)
        projects.bind(accountStateProvider: accountController)
        avi.bind(to: workflows.projectsList)
        avi.bind(accountStateProvider: accountController)
    }
}
