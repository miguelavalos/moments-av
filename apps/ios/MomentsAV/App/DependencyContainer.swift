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
        self.projectDeletionWorkflow = ProjectDeletionWorkflow(
            currentUserProvider: accountController,
            projectDeleter: projectRepository
        )
        self.projectWorkspaceSelectionWorkflow = ProjectWorkspaceSelectionWorkflow(workspaceObserver: resolvedWorkspaceObserver)
        self.projectsListWorkflow = ProjectsListWorkflow(
            projectsObserver: resolvedProjectsObserver,
            workspaceSelectionWorkflow: projectWorkspaceSelectionWorkflow,
            projectDeletionWorkflow: projectDeletionWorkflow
        )
        self.projectCreationWorkflow = ProjectCreationWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            projectCreator: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver
        )
        self.mediaUploadWorkflow = MediaUploadWorkflow(
            currentUserProvider: accountController,
            mediaAssetSaver: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            uploadClient: clients.upload
        )
        self.storyDraftWorkflow = StoryDraftWorkflow(
            currentUserProvider: accountController,
            storyDraftSaver: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            storyClient: clients.story
        )
        self.previewGenerationWorkflow = PreviewGenerationWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            previewResultSaver: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            previewClient: clients.preview,
            statusClient: clients.renderStatus
        )
        self.finalRenderWorkflow = FinalRenderWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            finalRenderResultSaver: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            finalRenderClient: clients.finalRender,
            statusClient: clients.renderStatus
        )
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

private struct MomentsWorkflowClients {
    let upload: MomentsUploadClient
    let story: MomentsStoryClient
    let preview: MomentsPreviewClient
    let finalRender: MomentsFinalRenderClient
    let renderStatus: MomentsRenderStatusClient

    init(baseURLString: String) {
        upload = MomentsUploadClient(baseURLString: baseURLString)
        story = MomentsStoryClient(baseURLString: baseURLString)
        preview = MomentsPreviewClient(baseURLString: baseURLString)
        finalRender = MomentsFinalRenderClient(baseURLString: baseURLString)
        renderStatus = MomentsRenderStatusClient(baseURLString: baseURLString)
    }
}
