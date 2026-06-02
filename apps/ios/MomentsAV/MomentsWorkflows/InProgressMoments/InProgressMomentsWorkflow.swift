import Combine
import Foundation

@MainActor
final class InProgressMomentsWorkflow: ObservableObject {
    @Published private(set) var projectSummary = MomentsProjectListSummary()
    @Published private(set) var isDeletingMoment = false
    @Published private(set) var errorMessage: String?

    private let projectsObserver: any MomentsActiveProjectsObserving
    private let workspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow
    private let momentDeletionWorkflow: MomentDeletionWorkflow
    private var currentOwnerUserId: String?
    private var cancellables = Set<AnyCancellable>()

    init(
        projectsObserver: any MomentsActiveProjectsObserving,
        workspaceSelectionWorkflow: MomentWorkspaceSelectionWorkflow,
        momentDeletionWorkflow: MomentDeletionWorkflow
    ) {
        self.projectsObserver = projectsObserver
        self.workspaceSelectionWorkflow = workspaceSelectionWorkflow
        self.momentDeletionWorkflow = momentDeletionWorkflow

        projectsObserver.projectsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] projects in
                self?.apply(projects)
            }
            .store(in: &cancellables)

        projectsObserver.projectsErrorPublisher
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

    func observeProjects(ownerUserId: String?) {
        currentOwnerUserId = ownerUserId
        projectSummary = MomentsProjectListSummary()
        errorMessage = nil
        clearActiveProject()
        projectsObserver.observeProjects(ownerUserId: ownerUserId)
    }

    func observeProjectWorkspace(ownerUserId: String?, projectId: String?) {
        errorMessage = nil
        workspaceSelectionWorkflow.observeProjectWorkspace(ownerUserId: ownerUserId, projectId: projectId)
    }

    private func applyWorkspaceError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    func clearProjectWorkspace() {
        clearActiveProject()
    }

    func deleteMoment(_ project: MomentDraftProject) async -> Bool {
        errorMessage = nil
        let didDelete = await momentDeletionWorkflow.deleteMoment(project)
        guard didDelete else { return false }

        if workspaceSelectionWorkflow.activeProject?.id == project.id {
            clearActiveProject()
        }
        observeProjects(ownerUserId: currentOwnerUserId)
        return true
    }

    private func apply(_ projects: [MomentDraftProject]) {
        projectSummary = MomentsProjectListSummary.make(from: projects)
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

extension InProgressMomentsWorkflow: MomentsInProgressViewing {
    var inProgressSummaryPublisher: AnyPublisher<MomentsProjectListSummary, Never> {
        $projectSummary.eraseToAnyPublisher()
    }

    var activeProjectPublisher: AnyPublisher<MomentDraftProject?, Never> {
        workspaceSelectionWorkflow.activeProjectPublisher
    }

    var activeWorkspacePublisher: AnyPublisher<MomentProjectWorkspace?, Never> {
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
