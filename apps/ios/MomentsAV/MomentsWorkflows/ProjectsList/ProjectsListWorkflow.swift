import Combine
import Foundation

@MainActor
final class ProjectsListWorkflow: ObservableObject {
    @Published private(set) var projectSummary = MomentsProjectListSummary()
    @Published private(set) var activeProject: MomentDraftProject?
    @Published private(set) var activeWorkspace: MomentProjectWorkspace?
    @Published private(set) var isLoadingProjectWorkspace = false
    @Published private(set) var isDeletingProject = false
    @Published private(set) var errorMessage: String?

    private let projectsObserver: any MomentsActiveProjectsObserving
    private let workspaceObserver: any MomentsActiveWorkspaceObserving
    private let projectDeletionWorkflow: ProjectDeletionWorkflow
    private var currentOwnerUserId: String?
    private var cancellables = Set<AnyCancellable>()

    init(
        projectsObserver: any MomentsActiveProjectsObserving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        projectDeletionWorkflow: ProjectDeletionWorkflow
    ) {
        self.projectsObserver = projectsObserver
        self.workspaceObserver = workspaceObserver
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

        workspaceObserver.activeWorkspacePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workspace in
                self?.apply(workspace: workspace)
            }
            .store(in: &cancellables)

        workspaceObserver.workspaceErrorPublisher
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
        activeProject = nil
        activeWorkspace = nil
        isLoadingProjectWorkspace = false
        errorMessage = nil

        guard let ownerUserId, let projectId else {
            workspaceObserver.clearWorkspace()
            return
        }

        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
        isLoadingProjectWorkspace = true
    }

    private func apply(workspace: MomentProjectWorkspace?) {
        activeWorkspace = workspace
        activeProject = workspace?.project
        isLoadingProjectWorkspace = false
    }

    private func applyWorkspaceError(_ message: String?) {
        guard let message else { return }
        errorMessage = message
        isLoadingProjectWorkspace = false
    }

    func clearProjectWorkspace() {
        clearActiveProject()
    }

    func deleteProject(_ project: MomentDraftProject) async -> Bool {
        errorMessage = nil
        let didDelete = await projectDeletionWorkflow.deleteProject(project)
        guard didDelete else { return false }

        if activeProject?.id == project.id {
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
        workspaceObserver.clearWorkspace()
        activeProject = nil
        activeWorkspace = nil
        isLoadingProjectWorkspace = false
    }
}

extension ProjectsListWorkflow: MomentsProjectsViewing {
    var projectSummaryPublisher: AnyPublisher<MomentsProjectListSummary, Never> {
        $projectSummary.eraseToAnyPublisher()
    }

    var activeProjectPublisher: AnyPublisher<MomentDraftProject?, Never> {
        $activeProject.eraseToAnyPublisher()
    }

    var activeWorkspacePublisher: AnyPublisher<MomentProjectWorkspace?, Never> {
        $activeWorkspace.eraseToAnyPublisher()
    }

    var isLoadingProjectWorkspacePublisher: AnyPublisher<Bool, Never> {
        $isLoadingProjectWorkspace.eraseToAnyPublisher()
    }

    var isDeletingProjectPublisher: AnyPublisher<Bool, Never> {
        $isDeletingProject.eraseToAnyPublisher()
    }

    var projectErrorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
}
