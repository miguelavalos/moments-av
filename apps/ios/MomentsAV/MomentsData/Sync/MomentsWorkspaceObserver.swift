import Combine
import Foundation

@MainActor
final class MomentsWorkspaceObserver: ObservableObject {
    @Published private(set) var activeWorkspace: MomentProjectWorkspace?
    @Published private(set) var errorMessage: String?

    private let workspaceObserver: any MomentsWorkspaceObserving
    private var activeWorkspaceTask: Task<Void, Never>?
    private var observationGeneration = 0

    init(projectRepository: any MomentsWorkspaceObserving = MomentsProjectRepository()) {
        workspaceObserver = projectRepository
    }

    var activeWorkspacePublisher: AnyPublisher<MomentProjectWorkspace?, Never> {
        $activeWorkspace.eraseToAnyPublisher()
    }

    var workspaceErrorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }

    func observeWorkspace(ownerUserId: String?, projectId: String?) {
        observationGeneration += 1
        let generation = observationGeneration
        activeWorkspaceTask?.cancel()
        activeWorkspace = nil
        errorMessage = nil

        guard let ownerUserId, let projectId else { return }

        do {
            let updates = try workspaceObserver.observeProjectWorkspace(
                ownerUserId: ownerUserId,
                projectId: projectId
            )
            .values

            activeWorkspaceTask = Task { [weak self] in
                for await workspace in updates {
                    await MainActor.run {
                        guard self?.observationGeneration == generation else { return }
                        self?.activeWorkspace = workspace
                    }
                }
            }
        } catch {
            guard observationGeneration == generation else { return }
            activeWorkspace = nil
            errorMessage = error.localizedDescription
        }
    }

    func clearWorkspace() {
        observationGeneration += 1
        activeWorkspaceTask?.cancel()
        activeWorkspace = nil
        errorMessage = nil
    }

    deinit {
        activeWorkspaceTask?.cancel()
    }
}

extension MomentsWorkspaceObserver: MomentsActiveWorkspaceObserving {}
