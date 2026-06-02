import Combine
import Foundation

@MainActor
final class InProgressMomentsWorkflow: ObservableObject {
    @Published private(set) var projectSummary = InProgressMomentsSummary()
    @Published private(set) var isDeletingMoment = false
    @Published private(set) var errorMessage: String?

    private let projectsObserver: any InProgressMomentsListProviding
    private let workspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow
    private let momentDeletionWorkflow: MomentDeletionWorkflow
    private var currentOwnerUserId: String?
    private var cancellables = Set<AnyCancellable>()

    init(
        projectsObserver: any InProgressMomentsListProviding,
        workspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow,
        momentDeletionWorkflow: MomentDeletionWorkflow
    ) {
        self.projectsObserver = projectsObserver
        self.workspaceSelectionWorkflow = workspaceSelectionWorkflow
        self.momentDeletionWorkflow = momentDeletionWorkflow

        projectsObserver.momentsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] moments in
                self?.apply(moments)
            }
            .store(in: &cancellables)

        projectsObserver.momentsErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.applyProjectListError(message)
            }
            .store(in: &cancellables)

        momentDeletionWorkflow.isDeletingMomentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeleting in
                self?.isDeletingMoment = isDeleting
            }
            .store(in: &cancellables)

        momentDeletionWorkflow.deletionErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.applyMomentDeletionError(message)
            }
            .store(in: &cancellables)

        workspaceSelectionWorkflow.workspaceErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.applyWorkspaceError(message)
            }
            .store(in: &cancellables)
    }

    func observeInProgressMoments(ownerUserId: String?) {
        currentOwnerUserId = ownerUserId
        projectSummary = InProgressMomentsSummary()
        errorMessage = nil
        clearActiveProject()
        projectsObserver.observeInProgressMoments(ownerUserId: ownerUserId)
    }

    func observeMomentWorkspace(ownerUserId: String?, momentId: String?) {
        errorMessage = nil
        workspaceSelectionWorkflow.observeMomentWorkspace(ownerUserId: ownerUserId, momentId: momentId)
    }

    private func applyWorkspaceError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    func clearProjectWorkspace() {
        clearActiveProject()
    }

    func deleteMoment(_ moment: InProgressMoment) async -> Bool {
        errorMessage = nil
        let didDelete = await momentDeletionWorkflow.deleteMoment(moment)
        guard didDelete else { return false }

        if workspaceSelectionWorkflow.activeProject?.id == moment.id {
            clearActiveProject()
        }
        observeInProgressMoments(ownerUserId: currentOwnerUserId)
        return true
    }

    private func apply(_ moments: [InProgressMoment]) {
        projectSummary = InProgressMomentsSummary.make(from: moments)
    }

    private func applyProjectListError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    private func applyMomentDeletionError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    private func clearActiveProject() {
        workspaceSelectionWorkflow.clearProjectWorkspace()
    }
}

extension InProgressMomentsWorkflow: InProgressMomentsViewing {
    var inProgressSummaryPublisher: AnyPublisher<InProgressMomentsSummary, Never> {
        $projectSummary.eraseToAnyPublisher()
    }

    var activeProjectPublisher: AnyPublisher<InProgressMoment?, Never> {
        workspaceSelectionWorkflow.activeProjectPublisher
    }

    var activeWorkspacePublisher: AnyPublisher<MomentWorkspace?, Never> {
        workspaceSelectionWorkflow.activeWorkspacePublisher
    }

    var isLoadingProjectWorkspacePublisher: AnyPublisher<Bool, Never> {
        workspaceSelectionWorkflow.isLoadingProjectWorkspacePublisher
    }

    var isDeletingMomentPublisher: AnyPublisher<Bool, Never> {
        $isDeletingMoment.eraseToAnyPublisher()
    }

    var inProgressErrorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
}
