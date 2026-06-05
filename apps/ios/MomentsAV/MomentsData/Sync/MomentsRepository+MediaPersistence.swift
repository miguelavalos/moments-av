import Foundation

extension MomentsRepository {
    func saveMediaAsset(
        ownerUserId: String,
        momentId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload,
        uploadCompletion: MomentsUploadCompletion
    ) async throws -> String {
        try await remoteClient.addMediaAsset(
            ownerUserId: ownerUserId,
            momentId: momentId,
            media: media,
            preparedUpload: preparedUpload,
            uploadCompletion: uploadCompletion
        )
    }

    func saveMediaAssets(
        ownerUserId: String,
        momentId: String,
        mediaAssets: [MediaAssetPersistenceRequest]
    ) async throws -> [String] {
        do {
            return try await remoteClient.addMediaAssets(
                ownerUserId: ownerUserId,
                momentId: momentId,
                requests: mediaAssets
            )
        } catch {
            var savedIds: [String] = []
            for mediaAsset in mediaAssets {
                let savedId = try await remoteClient.addMediaAsset(
                    ownerUserId: ownerUserId,
                    momentId: momentId,
                    request: mediaAsset
                )
                savedIds.append(savedId)
            }
            return savedIds
        }
    }
}
