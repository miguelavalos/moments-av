import Foundation

extension MomentsProjectRepository {
    func saveMediaAsset(
        ownerUserId: String,
        projectId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload
    ) async throws {
        try await remoteClient.addMediaAsset(
            ownerUserId: ownerUserId,
            projectId: projectId,
            media: media,
            preparedUpload: preparedUpload,
            uploadedAt: Date()
        )
    }
}
