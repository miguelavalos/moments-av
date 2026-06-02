import Combine
import Foundation

@MainActor
final class ProjectsListWorkflow: ObservableObject {
    @Published private(set) var projectSummary = MomentsProjectListSummary()
    @Published private(set) var isDeletingProject = false
    @Published private(set) var errorMessage: String?

    private let projectsObserver: any MomentsActiveProjectsObserving
    private let workspaceSelectionWorkflow: ProjectWorkspaceSelectionWorkflow
    private let projectDeletionWorkflow: ProjectDeletionWorkflow
    private var currentOwnerUserId: String?
    private var cancellables = Set<AnyCancellable>()

    init(
        projectsObserver: any MomentsActiveProjectsObserving,
        workspaceSelectionWorkflow: ProjectWorkspaceSelectionWorkflow,
        projectDeletionWorkflow: ProjectDeletionWorkflow
    ) {
        self.projectsObserver = projectsObserver
        self.workspaceSelectionWorkflow = workspaceSelectionWorkflow
        self.projectDeletionWorkflow = projectDeletionWorkflow

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

        projectDeletionWorkflow.isDeletingProjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeleting in
                self?.isDeletingProject = isDeleting
            }
            .store(in: &cancellables)

        projectDeletionWorkflow.deletionErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.applyProjectDeletionError(message)
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

    func deleteProject(_ project: MomentDraftProject) async -> Bool {
        errorMessage = nil
        let didDelete = await projectDeletionWorkflow.deleteProject(project)
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

    private func applyProjectDeletionError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
    }

    private func clearActiveProject() {
        workspaceSelectionWorkflow.clearProjectWorkspace()
    }
}

extension ProjectsListWorkflow: MomentsInProgressViewing {
    var projectSummaryPublisher: AnyPublisher<MomentsProjectListSummary, Never> {
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

    var isDeletingProjectPublisher: AnyPublisher<Bool, Never> {
        $isDeletingProject.eraseToAnyPublisher()
    }

    var projectErrorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
}
