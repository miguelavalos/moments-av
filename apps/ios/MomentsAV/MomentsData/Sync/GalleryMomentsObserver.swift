import Combine
import Foundation

@MainActor
final class GalleryMomentsObserver: ObservableObject {
    @Published private(set) var moments: [InProgressMoment] = []
    @Published private(set) var errorMessage: String?

    private let momentsObserver: any GalleryMomentsObserving
    private var momentsTask: Task<Void, Never>?
    private var observationGeneration = 0

    init(momentsRepository: any GalleryMomentsObserving = MomentsRepository()) {
        momentsObserver = momentsRepository
    }

    var galleryMomentsPublisher: AnyPublisher<[InProgressMoment], Never> {
        $moments.eraseToAnyPublisher()
    }

    var galleryMomentsErrorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }

    func observeGalleryMoments(ownerUserId: String?) {
        observationGeneration += 1
        let generation = observationGeneration
        momentsTask?.cancel()
        moments = []
        errorMessage = nil

        guard let ownerUserId else { return }

        do {
            let updates = try momentsObserver.observeGalleryMoments(ownerUserId: ownerUserId).values

            momentsTask = Task { [weak self] in
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

    func clearGalleryMoments() {
        observationGeneration += 1
        momentsTask?.cancel()
        moments = []
        errorMessage = nil
    }

    deinit {
        momentsTask?.cancel()
    }
}

extension GalleryMomentsObserver: GalleryMomentsListProviding {}
