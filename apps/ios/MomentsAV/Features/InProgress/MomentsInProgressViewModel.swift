import Combine
import Foundation

@MainActor
final class MomentsInProgressViewModel: ObservableObject {
    @Published private(set) var projectSummary = InProgressMomentsSummary()
    @Published private(set) var isSignedIn = false
    @Published private(set) var currentUserId: String?
    @Published private(set) var activeProject: InProgressMoment?
    @Published private(set) var activeWorkspace: MomentWorkspace?
    @Published private(set) var selectedMomentId: String?
    @Published private(set) var isLoadingProjectWorkspace = false
    @Published private(set) var isDeletingMoment = false
    @Published private(set) var statusMessage: String?

    private var workflow: (any InProgressMomentsViewing)?
    private var workflowCancellables = Set<AnyCancellable>()
    private var accountCancellables = Set<AnyCancellable>()
    private var deletionTask: Task<Void, Never>?

    init() {}

    func bind(to workflow: any InProgressMomentsViewing) {
        self.workflow = workflow
        workflowCancellables.removeAll()

        workflow.inProgressSummaryPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] projectSummary in
                self?.projectSummary = projectSummary
            }
            .store(in: &workflowCancellables)

        workflow.activeProjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] moment in
                self?.activeProject = moment
            }
            .store(in: &workflowCancellables)

        workflow.activeWorkspacePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workspace in
                self?.activeWorkspace = workspace
            }
            .store(in: &workflowCancellables)

        workflow.isLoadingProjectWorkspacePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoadingProjectWorkspace = isLoading
            }
            .store(in: &workflowCancellables)

        workflow.isDeletingMomentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeleting in
                self?.isDeletingMoment = isDeleting
            }
            .store(in: &workflowCancellables)

        workflow.inProgressErrorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.statusMessage = errorMessage
            }
            .store(in: &workflowCancellables)
    }

    func bind(accountStateProvider: any MomentsAccountStateProviding) {
        accountCancellables.removeAll()

        Publishers.CombineLatest(
            accountStateProvider.isSignedInPublisher,
            accountStateProvider.currentUserIdPublisher
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isSignedIn, currentUserId in
            self?.isSignedIn = isSignedIn
            self?.currentUserId = currentUserId
        }
        .store(in: &accountCancellables)
    }

    func selectProject(_ moment: InProgressMoment) {
        if selectedMomentId == moment.id {
            selectedMomentId = nil
            workflow?.clearProjectWorkspace()
            return
        }

        selectedMomentId = moment.id
        workflow?.observeMomentWorkspace(ownerUserId: currentUserId, momentId: moment.id)
    }

    func isSelected(_ moment: InProgressMoment) -> Bool {
        selectedMomentId == moment.id
    }

    func clearSelection() {
        deletionTask?.cancel()
        deletionTask = nil
        selectedMomentId = nil
        statusMessage = nil
        workflow?.clearProjectWorkspace()
    }

    func deleteMoment(_ moment: InProgressMoment) {
        guard let workflow else { return }

        deletionTask?.cancel()
        deletionTask = Task { [weak self] in
            let didDelete = await workflow.deleteMoment(moment)
            guard !Task.isCancelled else { return }
            if didDelete {
                self?.selectedMomentId = nil
                self?.activeProject = nil
                self?.activeWorkspace = nil
                self?.projectSummary = self?.projectSummary.removing(momentId: moment.id) ?? InProgressMomentsSummary()
                self?.statusMessage = L10n.string("inProgress.status.momentDeleted")
            }
            self?.deletionTask = nil
        }
    }
}
