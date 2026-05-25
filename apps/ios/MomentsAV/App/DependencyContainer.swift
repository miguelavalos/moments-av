import Foundation

@MainActor
final class MomentsDependencyContainer: ObservableObject {
    let accountController: AccountController
    let projectsObserver: MomentsProjectsObserver
    let workspaceObserver: MomentsWorkspaceObserver
    let projectDeletionWorkflow: ProjectDeletionWorkflow
    let projectWorkspaceSelectionWorkflow: ProjectWorkspaceSelectionWorkflow
    let projectsListWorkflow: ProjectsListWorkflow
    let projectCreationWorkflow: ProjectCreationWorkflow
    let mediaUploadWorkflow: MediaUploadWorkflow
    let storyDraftWorkflow: StoryDraftWorkflow
    let previewGenerationWorkflow: PreviewGenerationWorkflow
    let finalRenderWorkflow: FinalRenderWorkflow
    let homeViewModel: MomentsHomeViewModel
    let createViewModel: MomentsCreateViewModel
    let projectsViewModel: MomentsProjectsViewModel
    let aviViewModel: MomentsAviViewModel
    private var observedOwnerUserId: String??

    init(
        accountController: AccountController = AccountController(),
        projectRepository: MomentsProjectRepository = MomentsProjectRepository(),
        projectsObserver: MomentsProjectsObserver? = nil,
        workspaceObserver: MomentsWorkspaceObserver? = nil
    ) {
        let clients = MomentsWorkflowClients(baseURLString: AppConfig.momentsAPIBaseURL)
        self.accountController = accountController
        let resolvedProjectsObserver = projectsObserver ?? MomentsProjectsObserver(projectRepository: projectRepository)
        let resolvedWorkspaceObserver = workspaceObserver ?? MomentsWorkspaceObserver(projectRepository: projectRepository)
        self.projectsObserver = resolvedProjectsObserver
        self.workspaceObserver = resolvedWorkspaceObserver
        let workflows = MomentsWorkflowBundle(
            accountController: accountController,
            projectRepository: projectRepository,
            projectsObserver: resolvedProjectsObserver,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.projectDeletionWorkflow = workflows.projectDeletion
        self.projectWorkspaceSelectionWorkflow = workflows.projectWorkspaceSelection
        self.projectsListWorkflow = workflows.projectsList
        self.projectCreationWorkflow = workflows.projectCreation
        self.mediaUploadWorkflow = workflows.mediaUpload
        self.storyDraftWorkflow = workflows.storyDraft
        self.previewGenerationWorkflow = workflows.previewGeneration
        self.finalRenderWorkflow = workflows.finalRender
        self.homeViewModel = MomentsHomeViewModel()
        self.createViewModel = MomentsCreateViewModel()
        self.projectsViewModel = MomentsProjectsViewModel()
        self.aviViewModel = MomentsAviViewModel()

        bindViewModels()
    }

    func handleAccountChange(ownerUserId: String?) {
        guard observedOwnerUserId != .some(ownerUserId) else { return }
        observedOwnerUserId = .some(ownerUserId)
        projectsListWorkflow.observeProjects(ownerUserId: ownerUserId)
        projectsViewModel.clearSelection()
        createViewModel.clearSessionState()
    }
}

private extension MomentsDependencyContainer {
    func bindViewModels() {
        homeViewModel.bind(to: projectsListWorkflow)
        homeViewModel.bind(accountStateProvider: accountController)
        createViewModel.bind(
            accountStateProvider: accountController,
            projectCreationWorkflow: projectCreationWorkflow,
            mediaUploadWorkflow: mediaUploadWorkflow,
            storyDraftWorkflow: storyDraftWorkflow,
            previewGenerationWorkflow: previewGenerationWorkflow,
            finalRenderWorkflow: finalRenderWorkflow
        )
        projectsViewModel.bind(to: projectsListWorkflow)
        projectsViewModel.bind(accountStateProvider: accountController)
        aviViewModel.bind(to: projectsListWorkflow)
        aviViewModel.bind(accountStateProvider: accountController)
    }
}
