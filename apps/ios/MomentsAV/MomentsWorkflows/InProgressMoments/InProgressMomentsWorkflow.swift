import Combine
import Foundation
import OSLog

@MainActor
final class InProgressMomentsWorkflow: ObservableObject {
    @Published private(set) var momentsSummary = InProgressMomentsSummary()
    @Published private(set) var isDeletingMoment = false
    @Published private(set) var errorMessage: String?

    private let momentsObserver: any InProgressMomentsListProviding
    private let workspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow
    private let momentDeletionWorkflow: MomentDeletionWorkflow
    private let currentUserProvider: any MomentsCurrentUserProviding
    private let logger = Logger(subsystem: "com.avalsys.momentsav", category: "in-progress")
    private var currentOwnerUserId: String?
    private var cancellables = Set<AnyCancellable>()

    init(
        momentsObserver: any InProgressMomentsListProviding,
        workspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow,
        momentDeletionWorkflow: MomentDeletionWorkflow,
        currentUserProvider: any MomentsCurrentUserProviding
    ) {
        self.momentsObserver = momentsObserver
        self.workspaceSelectionWorkflow = workspaceSelectionWorkflow
        self.momentDeletionWorkflow = momentDeletionWorkflow
        self.currentUserProvider = currentUserProvider

        momentsObserver.momentsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] moments in
                self?.apply(moments)
            }
            .store(in: &cancellables)

        momentsObserver.momentsErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.applyMomentListError(message)
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
        momentsSummary = InProgressMomentsSummary()
        errorMessage = nil
        clearActiveMoment()
        momentsObserver.observeInProgressMoments(ownerUserId: ownerUserId)
    }

    func observeMomentWorkspace(ownerUserId: String?, momentId: String?) {
        errorMessage = nil
        workspaceSelectionWorkflow.observeMomentWorkspace(ownerUserId: ownerUserId, momentId: momentId)
    }

    private func applyWorkspaceError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    func clearMomentWorkspace() {
        clearActiveMoment()
    }

    func refreshActiveFinalRenderStatusIfNeeded() async {
        logger.debug("Final render status refresh is backend-owned; waiting for Convex realtime updates.")
    }

    func deleteMoment(_ moment: InProgressMoment) async -> Bool {
        errorMessage = nil
        let didDelete = await momentDeletionWorkflow.deleteMoment(moment)
        guard didDelete else { return false }

        if workspaceSelectionWorkflow.activeMoment?.id == moment.id {
            clearActiveMoment()
        }
        observeInProgressMoments(ownerUserId: currentOwnerUserId)
        return true
    }

    private func apply(_ moments: [InProgressMoment]) {
        momentsSummary = InProgressMomentsSummary.make(from: moments)
    }

    private func applyMomentListError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    private func applyMomentDeletionError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    private func clearActiveMoment() {
        workspaceSelectionWorkflow.clearMomentWorkspace()
    }

}

extension InProgressMomentsWorkflow: InProgressMomentsViewing {
    var inProgressSummaryPublisher: AnyPublisher<InProgressMomentsSummary, Never> {
        $momentsSummary.eraseToAnyPublisher()
    }

    var activeMomentPublisher: AnyPublisher<InProgressMoment?, Never> {
        workspaceSelectionWorkflow.activeMomentPublisher
    }

    var activeWorkspacePublisher: AnyPublisher<MomentWorkspace?, Never> {
        workspaceSelectionWorkflow.activeWorkspacePublisher
    }

    var isLoadingMomentWorkspacePublisher: AnyPublisher<Bool, Never> {
        workspaceSelectionWorkflow.isLoadingMomentWorkspacePublisher
    }

    var isDeletingMomentPublisher: AnyPublisher<Bool, Never> {
        $isDeletingMoment.eraseToAnyPublisher()
    }

    var inProgressErrorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
}
