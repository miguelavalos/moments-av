import Combine
import Foundation

@MainActor
final class InProgressMomentsObserver: ObservableObject {
    @Published private(set) var moments: [InProgressMoment] = []
    @Published private(set) var errorMessage: String?

    private let projectsObserver: any InProgressMomentsObserving
    private var projectsTask: Task<Void, Never>?
    private var observationGeneration = 0

    init(projectRepository: any InProgressMomentsObserving = MomentsRepository()) {
        projectsObserver = projectRepository
    }

    var momentsPublisher: AnyPublisher<[InProgressMoment], Never> {
        $moments.eraseToAnyPublisher()
    }

    var momentsErrorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }

    func observeInProgressMoments(ownerUserId: String?) {
        observationGeneration += 1
        let generation = observationGeneration
        projectsTask?.cancel()
        moments = []
        errorMessage = nil

        guard let ownerUserId else { return }

        do {
            let updates = try projectsObserver.observeInProgressMoments(ownerUserId: ownerUserId).values

            projectsTask = Task { [weak self] in
                do {
                    for try await moments in updates {
                        await MainActor.run {
                            guard self?.observationGeneration == generation else { return }
                            self?.moments = moments
                            self?.errorMessage = nil
                        }
                    }
                } catch {
                    await MainActor.run {
                        guard self?.observationGeneration == generation else { return }
                        self?.moments = []
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        } catch {
            guard observationGeneration == generation else { return }
            moments = []
            errorMessage = error.localizedDescription
        }
    }

    func clearInProgressMoments() {
        observationGeneration += 1
        projectsTask?.cancel()
        moments = []
        errorMessage = nil
    }

    deinit {
        projectsTask?.cancel()
    }
}

extension InProgressMomentsObserver: InProgressMomentsListProviding {}
