import Foundation

@MainActor
final class MomentsDependencyContainer: ObservableObject {
    let accountController: AccountController
    let projectsObserver: InProgressMomentsObserver
    let workspaceObserver: MomentsWorkspaceObserver
    let momentDeletionWorkflow: MomentDeletionWorkflow
    let momentWorkspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow
    let inProgressMomentsWorkflow: InProgressMomentsWorkflow
    let momentCreationWorkflow: MomentCreationWorkflow
    let mediaUploadWorkflow: MediaUploadWorkflow
    let storyDraftWorkflow: StoryDraftWorkflow
    let previewGenerationWorkflow: PreviewGenerationWorkflow
    let finalRenderWorkflow: FinalRenderWorkflow
    let homeViewModel: MomentsHomeViewModel
    let createViewModel: MomentsCreateViewModel
    let inProgressViewModel: MomentsInProgressViewModel
    let galleryViewModel: MomentsGalleryViewModel
    let aviViewModel: MomentsAviViewModel
    private var observedOwnerUserId: ObservedOwnerUserId = .unobserved

    init(
        accountController: AccountController = AccountController(),
        projectRepository: MomentsRepository = MomentsRepository(),
        projectsObserver: InProgressMomentsObserver? = nil,
        workspaceObserver: MomentsWorkspaceObserver? = nil
    ) {
        let clients = MomentsWorkflowClients(baseURLString: AppConfig.momentsAPIBaseURL)
        self.accountController = accountController
        let resolvedProjectsObserver = projectsObserver ?? InProgressMomentsObserver(projectRepository: projectRepository)
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
        self.momentDeletionWorkflow = workflows.momentDeletion
        self.momentWorkspaceSelectionWorkflow = workflows.momentWorkspaceSelection
        self.inProgressMomentsWorkflow = workflows.inProgressMoments
        self.momentCreationWorkflow = workflows.momentCreation
        self.mediaUploadWorkflow = workflows.mediaUpload
        self.storyDraftWorkflow = workflows.storyDraft
        self.previewGenerationWorkflow = workflows.previewGeneration
        self.finalRenderWorkflow = workflows.finalRender
        let viewModels = MomentsViewModelBundle(accountController: accountController, workflows: workflows)
        self.homeViewModel = viewModels.home
        self.createViewModel = viewModels.create
        self.inProgressViewModel = viewModels.inProgress
        self.galleryViewModel = viewModels.gallery
        self.aviViewModel = viewModels.avi
    }

    func handleAccountChange(ownerUserId: String?) {
        let nextObservedOwnerUserId = ObservedOwnerUserId.observed(ownerUserId)
        guard observedOwnerUserId != nextObservedOwnerUserId else { return }
        observedOwnerUserId = nextObservedOwnerUserId
        inProgressMomentsWorkflow.observeInProgressMoments(ownerUserId: ownerUserId)
        inProgressViewModel.clearSelection()
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
