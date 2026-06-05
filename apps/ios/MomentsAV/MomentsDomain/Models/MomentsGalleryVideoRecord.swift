import Foundation

struct MomentsGalleryVideoRecord: Identifiable, Codable, Equatable {
    let id: String
    let momentId: String
    let artifactId: String
    let title: String
    let r2Key: String
    let localRelativePath: String
    let createdAt: Double

    init(
        id: String,
        momentId: String,
        artifactId: String,
        title: String,
        r2Key: String,
        localRelativePath: String,
        createdAt: Double
    ) {
        self.id = id
        self.momentId = momentId
        self.artifactId = artifactId
        self.title = title
        self.r2Key = r2Key
        self.localRelativePath = localRelativePath
        self.createdAt = createdAt
    }

    func renamed(_ title: String) -> MomentsGalleryVideoRecord {
        MomentsGalleryVideoRecord(
            id: id,
            momentId: momentId,
            artifactId: artifactId,
            title: title,
            r2Key: r2Key,
            localRelativePath: localRelativePath,
            createdAt: createdAt
        )
    }
}

struct MomentsGalleryVideoPresentation: Identifiable, Equatable {
    let record: MomentsGalleryVideoRecord
    let isLocalFileAvailable: Bool
    let localFileURL: URL

    var id: String { record.id }
    var title: String { record.title }
    var availabilityTitle: String {
        isLocalFileAvailable ? L10n.string("gallery.video.savedOnDevice") : L10n.string("gallery.video.localFileMissing")
    }
}
