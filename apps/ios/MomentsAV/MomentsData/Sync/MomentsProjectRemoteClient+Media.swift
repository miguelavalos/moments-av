import Foundation

extension MomentsProjectRemoteClient {
    func addMediaAsset(
        ownerUserId: String,
        projectId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload,
        uploadedAt: Date = Date()
    ) async throws {
        try await addMediaAsset(
            ownerUserId: ownerUserId,
            projectId: projectId,
            request: .asset(media, preparedUpload: preparedUpload, uploadedAt: uploadedAt)
        )
    }

    func addMediaAsset(
        ownerUserId: String,
        projectId: String,
        request: MediaAssetPersistenceRequest
    ) async throws {
        let client = try requireClient()

        let _: String? = try await client.mutation(
            "moments:addMediaAsset",
            with: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
                "platformMediaAssetId": request.platformMediaAssetId,
                "uploadId": request.uploadId,
                "kind": request.kind,
                "r2Key": request.r2Key,
                "sortOrder": request.sortOrder,
                "selected": request.selected,
                "moderationStatus": request.moderationStatus,
                "uploadedAt": milliseconds(from: request.uploadedAt),
                "sourceExpiresAt": expirationMilliseconds(from: request.uploadedAt)
            ]
        )
    }
}
