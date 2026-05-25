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
            workspaceObserver: workspaceObserver
        )
        mediaUpload = MediaUploadWorkflow(
            currentUserProvider: accountController,
            mediaAssetSaver: projectRepository,
            workspaceObserver: workspaceObserver,
            uploadClient: clients.upload
        )
        storyDraft = StoryDraftWorkflow(
            currentUserProvider: accountController,
            storyDraftSaver: projectRepository,
            workspaceObserver: workspaceObserver,
            storyClient: clients.story
        )
        previewGeneration = PreviewGenerationWorkflow(
            currentUserProvider: accountController,
            creditBalanceProvider: accountController,
            previewResultSaver: projectRepository,
            workspaceObserver: workspaceObserver,
            previewClient: clients.preview,
            statusClient: clients.renderStatus
        )
        finalRender = FinalRenderWorkflow(
            currentUserProvider: accountController,
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
        upload = MomentsUploadClient(baseURLString: baseURLString)
        story = MomentsStoryClient(baseURLString: baseURLString)
        preview = MomentsPreviewClient(baseURLString: baseURLString)
        finalRender = MomentsFinalRenderClient(baseURLString: baseURLString)
        renderStatus = MomentsRenderStatusClient(baseURLString: baseURLString)
    }
}
