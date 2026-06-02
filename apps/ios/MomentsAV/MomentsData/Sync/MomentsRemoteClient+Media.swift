@preconcurrency import ConvexMobile
import Foundation

extension MomentsRemoteClient {
    func addMediaAsset(
        ownerUserId: String,
        momentId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload,
        uploadedAt: Date = Date()
    ) async throws -> String {
        try await addMediaAsset(
            ownerUserId: ownerUserId,
            momentId: momentId,
            request: .asset(media, preparedUpload: preparedUpload, uploadedAt: uploadedAt)
        )
    }

    func addMediaAsset(
        ownerUserId: String,
        momentId: String,
        request: MediaAssetPersistenceRequest
    ) async throws -> String {
        let client = try requireClient()

        let savedId: String? = try await retryingMutation(
            client: client,
            name: "moments:addMediaAsset",
            args: mediaAssetPayload(request, ownerUserId: ownerUserId, momentId: momentId)
        )
        return try requireSavedMediaAssetId(savedId)
    }

    func addMediaAssets(
        ownerUserId: String,
        momentId: String,
        requests: [MediaAssetPersistenceRequest]
    ) async throws -> [String] {
        guard !requests.isEmpty else { return [] }
        let client = try requireClient()

        let savedIds: [String]? = try await retryingMutation(
            client: client,
            name: "moments:addMediaAssets",
            args: [
                "ownerUserId": ownerUserId,
                "momentId": momentId,
                "mediaAssets": requests.map { mediaAssetPayload($0) }
            ]
        )
        guard let savedIds, savedIds.count == requests.count else {
            throw MomentsSyncError.unexpectedResponse
        }
        return savedIds
    }

    private func requireSavedMediaAssetId(_ savedId: String?) throws -> String {
        guard let savedId, !savedId.isEmpty else {
            throw MomentsSyncError.unexpectedResponse
        }
        return savedId
    }

    private func mediaAssetPayload(
        _ request: MediaAssetPersistenceRequest,
        ownerUserId: String? = nil,
        momentId: String? = nil
    ) -> [String: ConvexEncodable?] {
        var payload: [String: ConvexEncodable?] = [
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
        if let ownerUserId {
            payload["ownerUserId"] = ownerUserId as ConvexEncodable
        }
        if let momentId {
            payload["momentId"] = momentId as ConvexEncodable
        }
        if let thumbnailR2Key = request.thumbnailR2Key, !thumbnailR2Key.isEmpty {
            payload["thumbnailR2Key"] = thumbnailR2Key as ConvexEncodable
        }
        return payload
    }
}
