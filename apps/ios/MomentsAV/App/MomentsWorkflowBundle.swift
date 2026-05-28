import Foundation

@MainActor
struct MomentsWorkflowBundle {
    let projectDeletion: ProjectDeletionWorkflow
    let projectWorkspaceSelection: ProjectWorkspaceSelectionWorkflow
    let projectsList: ProjectsListWorkflow
    let projectCreation: ProjectCreationWorkflow
    let mediaUpload: MediaUploadWorkflow
    let storyDraft: StoryDraftWorkflow
    let previewGeneration: PreviewGenerationWorkflow
    let finalRender: FinalRenderWorkflow

    init(
        accountController: AccountController,
        projectRepository: MomentsProjectRepository,
        projectsObserver: MomentsProjectsObserver,
        workspaceObserver: MomentsWorkspaceObserver,
        clients: MomentsWorkflowClients
    ) {
        projectDeletion = ProjectDeletionWorkflow(
            currentUserProvider: accountController,
            projectDeleter: projectRepository
        )
        projectWorkspaceSelection = ProjectWorkspaceSelectionWorkflow(workspaceObserver: workspaceObserver)
        projectsList = ProjectsListWorkflow(
            projectsObserver: projectsObserver,
            workspaceSelectionWorkflow: projectWorkspaceSelection,
            projectDeletionWorkflow: projectDeletion
        )
        projectCreation = ProjectCreationWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            projectCreator: projectRepository,
            projectDeleter: projectRepository,
            workspaceObserver: workspaceObserver
        )
        mediaUpload = MediaUploadWorkflow(
            currentUserProvider: accountController,
            authTokenProvider: accountController,
            mediaAssetSaver: projectRepository,
            workspaceObserver: workspaceObserver,
            uploadClient: clients.upload
        )
        storyDraft = StoryDraftWorkflow(
            currentUserProvider: accountController,
            authTokenProvider: accountController,
            storyDraftSaver: projectRepository,
            workspaceObserver: workspaceObserver,
            storyClient: clients.story
        )
        previewGeneration = PreviewGenerationWorkflow(
            currentUserProvider: accountController,
            authTokenProvider: accountController,
            creditBalanceProvider: accountController,
            previewResultSaver: projectRepository,
            workspaceObserver: workspaceObserver,
            previewClient: clients.preview,
            statusClient: clients.renderStatus
        )
        finalRender = FinalRenderWorkflow(
            currentUserProvider: accountController,
            authTokenProvider: accountController,
            creditBalanceProvider: accountController,
            finalRenderResultSaver: projectRepository,
            workspaceObserver: workspaceObserver,
            finalRenderClient: clients.finalRender,
            statusClient: clients.renderStatus
        )
    }
}

struct MomentsWorkflowClients {
    let upload: MomentsUploadClient
    let story: MomentsStoryClient
    let preview: MomentsPreviewClient
    let finalRender: MomentsFinalRenderClient
    let renderStatus: MomentsRenderStatusClient

    init(baseURLString: String) {
        upload = MomentsUploadClient(baseURLString: baseURLString, session: Self.makeUploadSession())
        story = MomentsStoryClient(baseURLString: baseURLString)
        preview = MomentsPreviewClient(baseURLString: baseURLString)
        finalRender = MomentsFinalRenderClient(baseURLString: baseURLString)
        renderStatus = MomentsRenderStatusClient(baseURLString: baseURLString)
    }

    private static func makeUploadSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpMaximumConnectionsPerHost = 3
        configuration.timeoutIntervalForRequest = 45
        configuration.timeoutIntervalForResource = 90
        configuration.waitsForConnectivity = false
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: configuration)
    }
}
