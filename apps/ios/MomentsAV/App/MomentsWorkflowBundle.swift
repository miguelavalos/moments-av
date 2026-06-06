import Foundation

@MainActor
struct MomentsWorkflowBundle {
    let momentDeletion: MomentDeletionWorkflow
    let momentWorkspaceSelection: MomentWorkspaceSelectionWorkflow
    let inProgressMoments: InProgressMomentsWorkflow
    let momentCreation: MomentCreationWorkflow
    let mediaUpload: MediaUploadWorkflow
    let story: StoryWorkflow
    let finalRender: FinalRenderWorkflow

    init(
        accountController: AccountController,
        momentsRepository: MomentsRepository,
        momentsObserver: InProgressMomentsObserver,
        workspaceObserver: MomentsWorkspaceObserver,
        clients: MomentsWorkflowClients
    ) {
        momentDeletion = MomentDeletionWorkflow(
            currentUserProvider: accountController,
            momentDeleter: momentsRepository
        )
        momentWorkspaceSelection = MomentWorkspaceSelectionWorkflow(workspaceObserver: workspaceObserver)
        inProgressMoments = InProgressMomentsWorkflow(
            momentsObserver: momentsObserver,
            workspaceSelectionWorkflow: momentWorkspaceSelection,
            momentDeletionWorkflow: momentDeletion,
            momentTitleUpdater: momentsRepository,
            currentUserProvider: accountController
        )
        momentCreation = MomentCreationWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            momentCreator: momentsRepository,
            momentDeleter: momentsRepository,
            workspaceObserver: workspaceObserver
        )
        mediaUpload = MediaUploadWorkflow(
            currentUserProvider: accountController,
            authTokenProvider: accountController,
            mediaAssetSaver: momentsRepository,
            workspaceObserver: workspaceObserver,
            uploadClient: clients.upload
        )
        story = StoryWorkflow(
            currentUserProvider: accountController,
            authTokenProvider: accountController,
            storySaver: momentsRepository,
            workspaceObserver: workspaceObserver,
            storyClient: clients.story
        )
        finalRender = FinalRenderWorkflow(
            currentUserProvider: accountController,
            authTokenProvider: accountController,
            creditBalanceProvider: accountController,
            workspaceObserver: workspaceObserver,
            finalRenderClient: clients.finalRender,
            momentGalleryMarker: momentsRepository
        )
    }
}

struct MomentsWorkflowClients {
    let upload: MomentsUploadClient
    let story: MomentsStoryClient
    let finalRender: MomentsFinalRenderClient

    init(baseURLString: String) {
        upload = MomentsUploadClient(baseURLString: baseURLString, session: Self.makeUploadSession())
        story = MomentsStoryClient(baseURLString: baseURLString)
        finalRender = MomentsFinalRenderClient(baseURLString: baseURLString)
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
