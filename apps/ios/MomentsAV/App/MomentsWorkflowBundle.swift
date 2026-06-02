import Foundation

@MainActor
struct MomentsWorkflowBundle {
    let momentDeletion: MomentDeletionWorkflow
    let momentWorkspaceSelection: MomentWorkspaceSelectionWorkflow
    let inProgressMoments: InProgressMomentsWorkflow
    let momentCreation: MomentCreationWorkflow
    let mediaUpload: MediaUploadWorkflow
    let storyDraft: StoryDraftWorkflow
    let previewGeneration: PreviewGenerationWorkflow
    let finalRender: FinalRenderWorkflow

    init(
        accountController: AccountController,
        projectRepository: MomentsRepository,
        projectsObserver: InProgressMomentsObserver,
        workspaceObserver: MomentsWorkspaceObserver,
        clients: MomentsWorkflowClients
    ) {
        momentDeletion = MomentDeletionWorkflow(
            currentUserProvider: accountController,
            projectDeleter: projectRepository
        )
        momentWorkspaceSelection = MomentWorkspaceSelectionWorkflow(workspaceObserver: workspaceObserver)
        inProgressMoments = InProgressMomentsWorkflow(
            projectsObserver: projectsObserver,
            workspaceSelectionWorkflow: momentWorkspaceSelection,
            momentDeletionWorkflow: momentDeletion
        )
        momentCreation = MomentCreationWorkflow(
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
