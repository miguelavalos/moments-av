import Combine
import Foundation

@MainActor
class WorkspaceObservingWorkflow: ObservableObject {
    @Published private(set) var activeWorkspace: MomentProjectWorkspace?

    let workspaceObserver: any MomentsActiveWorkspaceObserving

    private var cancellables = Set<AnyCancellable>()
    private var workflowGeneration = 0

    init(workspaceObserver: any MomentsActiveWorkspaceObserving) {
        self.workspaceObserver = workspaceObserver

        workspaceObserver.activeWorkspacePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workspace in
                self?.updateActiveWorkspace(workspace)
            }
            .store(in: &cancellables)
    }

    func clearActiveWorkspace() {
        updateActiveWorkspace(nil)
    }

    func workspaceDidChange(_ workspace: MomentProjectWorkspace?) {}

    func beginWorkflowGeneration() -> Int {
        workflowGeneration
    }

    func isCurrentWorkflowGeneration(_ generation: Int) -> Bool {
        generation == workflowGeneration
    }

    func advanceWorkflowGeneration() {
        workflowGeneration += 1
    }

    private func updateActiveWorkspace(_ workspace: MomentProjectWorkspace?) {
        activeWorkspace = workspace
        workspaceDidChange(workspace)
    }
}
