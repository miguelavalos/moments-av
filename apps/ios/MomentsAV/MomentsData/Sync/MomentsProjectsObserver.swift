import Combine
import Foundation

@MainActor
final class MomentsProjectsObserver: ObservableObject {
    @Published private(set) var projects: [MomentDraftProject] = []
    @Published private(set) var errorMessage: String?

    private let projectsObserver: any MomentsProjectsObserving
    private var projectsTask: Task<Void, Never>?
    private var observationGeneration = 0

    init(projectRepository: any MomentsProjectsObserving = MomentsProjectRepository()) {
        projectsObserver = projectRepository
    }

    var projectsPublisher: AnyPublisher<[MomentDraftProject], Never> {
        $projects.eraseToAnyPublisher()
    }

    var projectsErrorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }

    func observeProjects(ownerUserId: String?) {
        observationGeneration += 1
        let generation = observationGeneration
        projectsTask?.cancel()
        projects = []
        errorMessage = nil

        guard let ownerUserId else { return }

        do {
            let updates = try projectsObserver.observeProjects(ownerUserId: ownerUserId).values

            projectsTask = Task { [weak self] in
                for await projects in updates {
                    await MainActor.run {
                        guard self?.observationGeneration == generation else { return }
                        self?.projects = projects
                    }
                }
            }
        } catch {
            guard observationGeneration == generation else { return }
            projects = []
            errorMessage = error.localizedDescription
        }
    }

    func clearProjects() {
        observationGeneration += 1
        projectsTask?.cancel()
        projects = []
        errorMessage = nil
    }

    deinit {
        projectsTask?.cancel()
    }
}

extension MomentsProjectsObserver: MomentsActiveProjectsObserving {}
