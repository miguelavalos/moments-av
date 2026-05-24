import Foundation

extension MomentsProjectRemoteClient {
    func addMediaAsset(
        ownerUserId: String,
        projectId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload,
        uploadedAt: Date = Date()
    ) async throws {
        let client = try requireClient()

        let _: String? = try await client.mutation(
            "moments:addMediaAsset",
            with: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
                "platformMediaAssetId": preparedUpload.mediaAssetId,
                "uploadId": preparedUpload.uploadId,
                "kind": media.kind,
                "r2Key": preparedUpload.storageKey,
                "sortOrder": media.sortOrder,
                "selected": media.selected,
                "moderationStatus": "pending",
                "uploadedAt": milliseconds(from: uploadedAt),
                "sourceExpiresAt": expirationMilliseconds(from: uploadedAt)
            ]
        )
    }
}
