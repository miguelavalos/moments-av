@preconcurrency import ConvexMobile
import Foundation

extension MomentsProjectRemoteClient {
    func addMediaAsset(
        ownerUserId: String,
        projectId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload,
        uploadedAt: Date = Date()
    ) async throws -> String {
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
    ) async throws -> String {
        let client = try requireClient()

        let savedId: String? = try await client.mutation(
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
        return try requireSavedMediaAssetId(savedId)
    }

    func addMediaAssets(
        ownerUserId: String,
        projectId: String,
        requests: [MediaAssetPersistenceRequest]
    ) async throws -> [String] {
        guard !requests.isEmpty else { return [] }
        let client = try requireClient()

        let savedIds: [String]? = try await client.mutation(
            "moments:addMediaAssets",
            with: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
                "mediaAssets": requests.map(mediaAssetPayload)
            ]
        )
        guard let savedIds, savedIds.count == requests.count else {
            throw MomentsProjectSyncError.unexpectedResponse
        }
        return savedIds
    }

    private func requireSavedMediaAssetId(_ savedId: String?) throws -> String {
        guard let savedId, !savedId.isEmpty else {
            throw MomentsProjectSyncError.unexpectedResponse
        }
        return savedId
    }

    private func mediaAssetPayload(_ request: MediaAssetPersistenceRequest) -> [String: ConvexEncodable?] {
        [
            "platformMediaAssetId": request.platformMediaAssetId as ConvexEncodable,
            "uploadId": request.uploadId as ConvexEncodable,
            "kind": request.kind as ConvexEncodable,
            "r2Key": request.r2Key as ConvexEncodable,
            "sortOrder": request.sortOrder as ConvexEncodable,
            "selected": request.selected as ConvexEncodable,
            "moderationStatus": request.moderationStatus as ConvexEncodable,
            "uploadedAt": milliseconds(from: request.uploadedAt) as ConvexEncodable,
            "sourceExpiresAt": expirationMilliseconds(from: request.uploadedAt) as ConvexEncodable
        ]
    }
}
