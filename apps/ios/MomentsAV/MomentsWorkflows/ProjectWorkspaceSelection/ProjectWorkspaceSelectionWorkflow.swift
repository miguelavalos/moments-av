import Combine
import Foundation

@MainActor
final class ProjectWorkspaceSelectionWorkflow: ObservableObject {
    @Published private(set) var activeProject: MomentDraftProject?
    @Published private(set) var activeWorkspace: MomentProjectWorkspace?
    @Published private(set) var isLoadingProjectWorkspace = false
    @Published private(set) var errorMessage: String?

    private let workspaceObserver: any MomentsActiveWorkspaceObserving
    private var cancellables = Set<AnyCancellable>()

    init(workspaceObserver: any MomentsActiveWorkspaceObserving) {
        self.workspaceObserver = workspaceObserver

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

    var activeProjectPublisher: AnyPublisher<MomentDraftProject?, Never> {
        $activeProject.eraseToAnyPublisher()
    }

    var activeWorkspacePublisher: AnyPublisher<MomentProjectWorkspace?, Never> {
        $activeWorkspace.eraseToAnyPublisher()
    }

    var isLoadingProjectWorkspacePublisher: AnyPublisher<Bool, Never> {
        $isLoadingProjectWorkspace.eraseToAnyPublisher()
    }

    var workspaceErrorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
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

    func clearProjectWorkspace() {
        workspaceObserver.clearWorkspace()
        activeProject = nil
        activeWorkspace = nil
        isLoadingProjectWorkspace = false
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
}
