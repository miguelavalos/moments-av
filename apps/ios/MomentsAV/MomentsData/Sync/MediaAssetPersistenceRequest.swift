import Foundation

struct MediaAssetPersistenceRequest {
    let platformMediaAssetId: String
    let uploadId: String
    let kind: String
    let r2Key: String
    let sortOrder: Double
    let selected: Bool
    let moderationStatus: String
    let uploadedAt: Date
}

extension MediaAssetPersistenceRequest {
    static func asset(
        _ media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload,
        uploadedAt: Date = Date()
    ) -> MediaAssetPersistenceRequest {
        MediaAssetPersistenceRequest(
            platformMediaAssetId: preparedUpload.mediaAssetId,
            uploadId: preparedUpload.uploadId,
            kind: media.kind,
            r2Key: preparedUpload.storageKey,
            sortOrder: Double(media.sortOrder),
            selected: media.selected,
            moderationStatus: "pending",
            uploadedAt: uploadedAt
        )
    }
}
