import Foundation

@MainActor
final class MomentsDependencyContainer: ObservableObject {
    let accountController: AccountController
    let momentsObserver: InProgressMomentsObserver
    let workspaceObserver: MomentsWorkspaceObserver
    let momentDeletionWorkflow: MomentDeletionWorkflow
    let momentWorkspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow
    let inProgressMomentsWorkflow: InProgressMomentsWorkflow
    let momentCreationWorkflow: MomentCreationWorkflow
    let mediaUploadWorkflow: MediaUploadWorkflow
    let storyPlanWorkflow: StoryPlanWorkflow
    let finalRenderWorkflow: FinalRenderWorkflow
    let homeViewModel: MomentsHomeViewModel
    let createViewModel: MomentsCreateViewModel
    let inProgressViewModel: MomentsInProgressViewModel
    let galleryViewModel: MomentsGalleryViewModel
    let aviViewModel: MomentsAviViewModel
    private var observedOwnerUserId: ObservedOwnerUserId = .unobserved

    init(
        accountController: AccountController = AccountController(),
        momentsRepository: MomentsRepository = MomentsRepository(),
        momentsObserver: InProgressMomentsObserver? = nil,
        workspaceObserver: MomentsWorkspaceObserver? = nil
    ) {
        let clients = MomentsWorkflowClients(baseURLString: AppConfig.momentsAPIBaseURL)
        self.accountController = accountController
        let resolvedMomentsObserver = momentsObserver ?? InProgressMomentsObserver(momentsRepository: momentsRepository)
        let resolvedWorkspaceObserver = workspaceObserver ?? MomentsWorkspaceObserver(momentsRepository: momentsRepository)
        self.momentsObserver = resolvedMomentsObserver
        self.workspaceObserver = resolvedWorkspaceObserver
        let workflows = MomentsWorkflowBundle(
            accountController: accountController,
            momentsRepository: momentsRepository,
            momentsObserver: resolvedMomentsObserver,
            workspaceObserver: resolvedWorkspaceObserver,
            clients: clients
        )
        self.momentDeletionWorkflow = workflows.momentDeletion
        self.momentWorkspaceSelectionWorkflow = workflows.momentWorkspaceSelection
        self.inProgressMomentsWorkflow = workflows.inProgressMoments
        self.momentCreationWorkflow = workflows.momentCreation
        self.mediaUploadWorkflow = workflows.mediaUpload
        self.storyPlanWorkflow = workflows.storyPlan
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
        guard MomentsCreateUITestFixtures.isActive else { return }
        createViewModel.applyUITestCreateFixture()
    }
}

private enum ObservedOwnerUserId: Equatable {
    case unobserved
    case observed(String?)
}
