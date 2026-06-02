import Foundation

struct MomentsGalleryVideoRecord: Identifiable, Codable, Equatable {
    let id: String
    let projectId: String
    let artifactId: String
    let title: String
    let r2Key: String
    let localRelativePath: String
    let createdAt: Double

    init(
        id: String,
        projectId: String,
        artifactId: String,
        title: String,
        r2Key: String,
        localRelativePath: String,
        createdAt: Double
    ) {
        self.id = id
        self.projectId = projectId
        self.artifactId = artifactId
        self.title = title
        self.r2Key = r2Key
        self.localRelativePath = localRelativePath
        self.createdAt = createdAt
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
