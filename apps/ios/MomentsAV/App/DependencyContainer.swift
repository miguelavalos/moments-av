import Foundation

@MainActor
final class MomentsDependencyContainer: ObservableObject {
    let accountController: AccountController
    let projectsObserver: MomentsProjectsObserver
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
    let aviViewModel: MomentsAviViewModel

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
        self.projectsListWorkflow = Self.makeProjectsListWorkflow(
            currentUserProvider: accountController,
            projectListing: projectRepository,
            projectsObserver: resolvedProjectsObserver,
            workspaceObserver: resolvedWorkspaceObserver
        )
        self.projectCreationWorkflow = Self.makeProjectCreationWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            projectCreator: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver
        )
        self.mediaUploadWorkflow = Self.makeMediaUploadWorkflow(
            currentUserProvider: accountController,
            mediaAssetSaver: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.storyDraftWorkflow = Self.makeStoryDraftWorkflow(
            currentUserProvider: accountController,
            storyDraftSaver: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.previewGenerationWorkflow = Self.makePreviewGenerationWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            previewResultSaver: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.finalRenderWorkflow = Self.makeFinalRenderWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            finalRenderResultSaver: projectRepository,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.homeViewModel = MomentsHomeViewModel()
        self.createViewModel = MomentsCreateViewModel()
        self.projectsViewModel = MomentsProjectsViewModel()
        self.aviViewModel = MomentsAviViewModel()

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
        projectListing: any MomentsProjectListing,
        projectsObserver: any MomentsActiveProjectsObserving,
        workspaceObserver: any MomentsActiveWorkspaceObserving
    ) -> ProjectsListWorkflow {
        ProjectsListWorkflow(
            currentUserProvider: currentUserProvider,
            projectListing: projectListing,
            projectsObserver: projectsObserver,
            workspaceObserver: workspaceObserver
        )
    }

    static func makeProjectCreationWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        projectCreator: any MomentsProjectCreating,
        workspaceObserver: any MomentsActiveWorkspaceObserving
    ) -> ProjectCreationWorkflow {
        ProjectCreationWorkflow(
            currentUserProvider: currentUserProvider,
            creditBalanceProvider: creditBalanceProvider,
            projectCreator: projectCreator,
            workspaceObserver: workspaceObserver
        )
    }

    static func makeMediaUploadWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        mediaAssetSaver: any MomentsMediaAssetSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        clients: MomentsWorkflowClients
    ) -> MediaUploadWorkflow {
        MediaUploadWorkflow(
            currentUserProvider: currentUserProvider,
            mediaAssetSaver: mediaAssetSaver,
            workspaceObserver: workspaceObserver,
            uploadClient: clients.upload
        )
    }

    static func makeStoryDraftWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        storyDraftSaver: any MomentsStoryDraftSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        clients: MomentsWorkflowClients
    ) -> StoryDraftWorkflow {
        StoryDraftWorkflow(
            currentUserProvider: currentUserProvider,
            storyDraftSaver: storyDraftSaver,
            workspaceObserver: workspaceObserver,
            storyClient: clients.story
        )
    }

    static func makePreviewGenerationWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        previewResultSaver: any MomentsPreviewResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        clients: MomentsWorkflowClients
    ) -> PreviewGenerationWorkflow {
        PreviewGenerationWorkflow(
            currentUserProvider: currentUserProvider,
            creditBalanceProvider: creditBalanceProvider,
            previewResultSaver: previewResultSaver,
            workspaceObserver: workspaceObserver,
            previewClient: clients.preview,
            statusClient: clients.renderStatus
        )
    }

    static func makeFinalRenderWorkflow(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        finalRenderResultSaver: any MomentsFinalRenderResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        clients: MomentsWorkflowClients
    ) -> FinalRenderWorkflow {
        FinalRenderWorkflow(
            currentUserProvider: currentUserProvider,
            creditBalanceProvider: creditBalanceProvider,
            finalRenderResultSaver: finalRenderResultSaver,
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
