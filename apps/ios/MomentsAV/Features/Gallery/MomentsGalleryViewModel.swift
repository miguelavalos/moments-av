import Combine
import Foundation

@MainActor
final class MomentsGalleryViewModel: ObservableObject {
    @Published private(set) var videos: [MomentsGalleryVideoPresentation] = []

    private var galleryCancellables = Set<AnyCancellable>()
    private let galleryStore: any MomentsGalleryStoring

    init(galleryStore: any MomentsGalleryStoring = MomentsGalleryStore()) {
        self.galleryStore = galleryStore
        refreshVideos()
        NotificationCenter.default.publisher(for: MomentsGalleryStore.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshVideos()
            }
            .store(in: &galleryCancellables)
    }

    func refreshVideos() {
        videos = galleryStore
            .loadRecords()
            .sorted { $0.createdAt > $1.createdAt }
            .map { record in
                MomentsGalleryVideoPresentation(
                    record: record,
                    isLocalFileAvailable: galleryStore.localFileExists(for: record),
                    localFileURL: galleryStore.localFileURL(for: record)
                )
            }
    }

    func deleteVideo(_ video: MomentsGalleryVideoPresentation) {
        galleryStore.deleteRecord(video.record, deleteLocalFile: true)
        refreshVideos()
    }
}
