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

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let projectListing: any MomentsProjectListing
    private var projectListTask: Task<Void, Never>?
    private var activeProjectTask: Task<Void, Never>?
    private var projectListGeneration = 0
    private var activeProjectGeneration = 0
    private var deletionGeneration = 0

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        projectRepository: any MomentsProjectListing
    ) {
        self.currentUserProvider = currentUserProvider
        projectListing = projectRepository
    }

    func observeProjects(ownerUserId: String?) {
        projectListGeneration += 1
        let generation = projectListGeneration
        projectListTask?.cancel()
        projectSummary = MomentsProjectListSummary()
        errorMessage = nil
        clearActiveProject()

        guard let ownerUserId else { return }

        do {
            let updates = try projectListing.observeProjects(ownerUserId: ownerUserId).values

            projectListTask = Task { [weak self] in
                for await projects in updates {
                    await MainActor.run {
                        guard self?.projectListGeneration == generation else { return }
                        self?.apply(projects)
                    }
                }
            }
        } catch {
            guard projectListGeneration == generation else { return }
            errorMessage = error.localizedDescription
        }
    }

    func observeProjectWorkspace(ownerUserId: String?, projectId: String?) {
        activeProjectGeneration += 1
        let generation = activeProjectGeneration
        activeProjectTask?.cancel()
        activeProject = nil
        activeWorkspace = nil
        isLoadingProjectWorkspace = false
        errorMessage = nil

        guard let ownerUserId, let projectId else { return }

        do {
            let updates = try projectListing.observeProjectWorkspace(
                ownerUserId: ownerUserId,
                projectId: projectId
            )
            .values

            isLoadingProjectWorkspace = true
            activeProjectTask = Task { [weak self] in
                for await workspace in updates {
                    await MainActor.run {
                        guard self?.activeProjectGeneration == generation else { return }
                        self?.activeWorkspace = workspace
                        self?.activeProject = workspace?.project
                        self?.isLoadingProjectWorkspace = false
                    }
                }
            }
        } catch {
            guard activeProjectGeneration == generation else { return }
            errorMessage = error.localizedDescription
            isLoadingProjectWorkspace = false
        }
    }

    func clearProjectWorkspace() {
        clearActiveProject()
    }

    func deleteProject(_ project: MomentDraftProject) async -> Bool {
        guard !isDeletingProject else { return false }
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = "Sign in before deleting a project."
            return false
        }

        isDeletingProject = true
        errorMessage = nil
        deletionGeneration += 1
        let generation = deletionGeneration

        do {
            try await projectListing.deleteProject(ownerUserId: ownerUserId, projectId: project.id)
            guard deletionGeneration == generation else { return false }
            if activeProject?.id == project.id {
                clearActiveProject()
            }
            observeProjects(ownerUserId: ownerUserId)
            isDeletingProject = false
            return true
        } catch {
            guard deletionGeneration == generation else { return false }
            errorMessage = error.localizedDescription
            isDeletingProject = false
            return false
        }
    }

    private func apply(_ projects: [MomentDraftProject]) {
        projectSummary = MomentsProjectListSummary.make(from: projects)
    }

    private func clearActiveProject() {
        activeProjectGeneration += 1
        activeProjectTask?.cancel()
        activeProject = nil
        activeWorkspace = nil
        isLoadingProjectWorkspace = false
    }

    deinit {
        projectListTask?.cancel()
        activeProjectTask?.cancel()
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
