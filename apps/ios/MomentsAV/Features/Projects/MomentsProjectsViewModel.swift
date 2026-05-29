import Combine
import Foundation

@MainActor
final class MomentsProjectsViewModel: ObservableObject {
    @Published private(set) var projectSummary = MomentsProjectListSummary()
    @Published private(set) var isSignedIn = false
    @Published private(set) var currentUserId: String?
    @Published private(set) var activeProject: MomentDraftProject?
    @Published private(set) var activeWorkspace: MomentProjectWorkspace?
    @Published private(set) var selectedProjectId: String?
    @Published private(set) var isLoadingProjectWorkspace = false
    @Published private(set) var isDeletingProject = false
    @Published private(set) var statusMessage: String?

    private var workflow: (any MomentsProjectsViewing)?
    private var workflowCancellables = Set<AnyCancellable>()
    private var accountCancellables = Set<AnyCancellable>()
    private var deletionTask: Task<Void, Never>?

    func bind(to workflow: any MomentsProjectsViewing) {
        self.workflow = workflow
        workflowCancellables.removeAll()

        workflow.projectSummaryPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] projectSummary in
                self?.projectSummary = projectSummary
            }
            .store(in: &workflowCancellables)

        workflow.activeProjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] project in
                self?.activeProject = project
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

        workflow.isDeletingProjectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeleting in
                self?.isDeletingProject = isDeleting
            }
            .store(in: &workflowCancellables)

        workflow.projectErrorMessagePublisher
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

    func selectProject(_ project: MomentDraftProject) {
        if selectedProjectId == project.id {
            selectedProjectId = nil
            workflow?.clearProjectWorkspace()
            return
        }

        selectedProjectId = project.id
        workflow?.observeProjectWorkspace(ownerUserId: currentUserId, projectId: project.id)
    }

    func isSelected(_ project: MomentDraftProject) -> Bool {
        selectedProjectId == project.id
    }

    func clearSelection() {
        deletionTask?.cancel()
        deletionTask = nil
        selectedProjectId = nil
        statusMessage = nil
        workflow?.clearProjectWorkspace()
    }

    func deleteProject(_ project: MomentDraftProject) {
        guard let workflow else { return }

        deletionTask?.cancel()
        deletionTask = Task { [weak self] in
            let didDelete = await workflow.deleteProject(project)
            guard !Task.isCancelled else { return }
            if didDelete {
                self?.selectedProjectId = nil
                self?.activeProject = nil
                self?.activeWorkspace = nil
                self?.projectSummary = self?.projectSummary.removing(projectId: project.id) ?? MomentsProjectListSummary()
                self?.statusMessage = "Project deleted."
            }
            self?.deletionTask = nil
        }
    }
}
