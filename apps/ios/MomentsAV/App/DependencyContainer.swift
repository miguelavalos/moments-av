import Foundation

@MainActor
final class MomentsDependencyContainer: ObservableObject {
    let accountController: AccountController
    let workspaceObserver: MomentsWorkspaceObserver
    let projectsListWorkflow: ProjectsListWorkflow
    let projectCreationWorkflow: ProjectCreationWorkflow
    let mediaUploadWorkflow: MediaUploadWorkflow
    let storyDraftWorkflow: StoryDraftWorkflow
    let previewGenerationWorkflow: PreviewGenerationWorkflow
    let finalRenderWorkflow: FinalRenderWorkflow
    let homeViewModel: MomentsHomeViewModel
    let createViewModel: MomentsCreateViewModel
    let projectsViewModel: MomentsProjectsViewModel

    init(
        accountController: AccountController = AccountController(),
        projectRepository: MomentsProjectRepository = MomentsProjectRepository(),
        workspaceObserver: MomentsWorkspaceObserver? = nil
    ) {
        let clients = MomentsWorkflowClients(baseURLString: AppConfig.momentsAPIBaseURL)
        self.accountController = accountController
        let resolvedWorkspaceObserver = workspaceObserver ?? MomentsWorkspaceObserver(projectRepository: projectRepository)
        self.workspaceObserver = resolvedWorkspaceObserver
        self.projectsListWorkflow = Self.makeProjectsListWorkflow(
            currentUserProvider: accountController,
            projectRepository: projectRepository
        )
        self.projectCreationWorkflow = Self.makeProjectCreationWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            projectRepository: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver
        )
        self.mediaUploadWorkflow = Self.makeMediaUploadWorkflow(
            currentUserProvider: accountController,
            projectRepository: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.storyDraftWorkflow = Self.makeStoryDraftWorkflow(
            currentUserProvider: accountController,
            projectRepository: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.previewGenerationWorkflow = Self.makePreviewGenerationWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            projectRepository: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.finalRenderWorkflow = Self.makeFinalRenderWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            projectRepository: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.homeViewModel = MomentsHomeViewModel()
        self.createViewModel = MomentsCreateViewModel()
        self.projectsViewModel = MomentsProjectsViewModel()

        bindViewModels()
    }

    func handleAccountChange(ownerUserId: String?) {
        projectsListWorkflow.observeProjects(ownerUserId: ownerUserId)
        projectsViewModel.clearSelection()
        createViewModel.clearSessionState()
    }
}

private extension MomentsDependencyContainer {
    static func makeProjectsListWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        projectRepository: any MomentsProjectListing
    ) -> ProjectsListWorkflow {
        ProjectsListWorkflow(
            currentUserProvider: currentUserProvider,
            projectRepository: projectRepository
        )
    }

    static func makeProjectCreationWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        projectRepository: any MomentsProjectCreating,
        workspaceObserver: any MomentsActiveWorkspaceObserving
    ) -> ProjectCreationWorkflow {
        ProjectCreationWorkflow(
            currentUserProvider: currentUserProvider,
            creditBalanceProvider: creditBalanceProvider,
            projectRepository: projectRepository,
            workspaceObserver: workspaceObserver
        )
    }

    static func makeMediaUploadWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        projectRepository: any MomentsMediaAssetSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        clients: MomentsWorkflowClients
    ) -> MediaUploadWorkflow {
        MediaUploadWorkflow(
            currentUserProvider: currentUserProvider,
            projectRepository: projectRepository,
            workspaceObserver: workspaceObserver,
            uploadClient: clients.upload
        )
    }

    static func makeStoryDraftWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        projectRepository: any MomentsStoryDraftSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        clients: MomentsWorkflowClients
    ) -> StoryDraftWorkflow {
        StoryDraftWorkflow(
            currentUserProvider: currentUserProvider,
            projectRepository: projectRepository,
            workspaceObserver: workspaceObserver,
            storyClient: clients.story
        )
    }

    static func makePreviewGenerationWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        projectRepository: any MomentsPreviewResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        clients: MomentsWorkflowClients
    ) -> PreviewGenerationWorkflow {
        PreviewGenerationWorkflow(
            currentUserProvider: currentUserProvider,
            creditBalanceProvider: creditBalanceProvider,
            projectRepository: projectRepository,
            workspaceObserver: workspaceObserver,
            previewClient: clients.preview,
            statusClient: clients.renderStatus
        )
    }

    static func makeFinalRenderWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        projectRepository: any MomentsFinalRenderResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        clients: MomentsWorkflowClients
    ) -> FinalRenderWorkflow {
        FinalRenderWorkflow(
            currentUserProvider: currentUserProvider,
            creditBalanceProvider: creditBalanceProvider,
            projectRepository: projectRepository,
            workspaceObserver: workspaceObserver,
            finalRenderClient: clients.finalRender,
            statusClient: clients.renderStatus
        )
    }

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
