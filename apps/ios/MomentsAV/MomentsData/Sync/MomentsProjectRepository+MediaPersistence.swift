import Foundation

extension MomentsProjectRepository {
    func saveMediaAsset(
        ownerUserId: String,
        projectId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload
    ) async throws -> String {
        try await remoteClient.addMediaAsset(
            ownerUserId: ownerUserId,
            projectId: projectId,
            media: media,
            preparedUpload: preparedUpload
        )
    }

    func saveMediaAssets(
        ownerUserId: String,
        projectId: String,
        mediaAssets: [MediaAssetPersistenceRequest]
    ) async throws -> [String] {
        do {
            return try await remoteClient.addMediaAssets(
                ownerUserId: ownerUserId,
                projectId: projectId,
                requests: mediaAssets
            )
        } catch {
            var savedIds: [String] = []
            for mediaAsset in mediaAssets {
                let savedId = try await remoteClient.addMediaAsset(
                    ownerUserId: ownerUserId,
                    projectId: projectId,
                    request: mediaAsset
                )
                savedIds.append(savedId)
            }
            return savedIds
        }
    }
}
