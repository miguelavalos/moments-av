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
    private var observedOwnerUserId: ObservedOwnerUserId = .unobserved

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
        let viewModels = MomentsViewModelBundle(accountController: accountController, workflows: workflows)
        self.homeViewModel = viewModels.home
        self.createViewModel = viewModels.create
        self.projectsViewModel = viewModels.projects
        self.aviViewModel = viewModels.avi
    }

    func handleAccountChange(ownerUserId: String?) {
        let nextObservedOwnerUserId = ObservedOwnerUserId.observed(ownerUserId)
        guard observedOwnerUserId != nextObservedOwnerUserId else { return }
        observedOwnerUserId = nextObservedOwnerUserId
        projectsListWorkflow.observeProjects(ownerUserId: ownerUserId)
        projectsViewModel.clearSelection()
        createViewModel.clearSessionState()
        applyUITestFixturesIfNeeded()
    }

    func applyUITestFixturesIfNeeded() {
        guard MomentsUITestEnvironment.current.createFixture == "full" else { return }
        createViewModel.applyUITestFullWorkflowFixture()
    }
}

private enum ObservedOwnerUserId: Equatable {
    case unobserved
    case observed(String?)
}
