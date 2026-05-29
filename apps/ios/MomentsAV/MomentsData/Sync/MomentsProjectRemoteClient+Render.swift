import Foundation

extension MomentsProjectRemoteClient {
    func createRenderJob(
        ownerUserId: String,
        projectId: String,
        kind: String,
        workflowRunId: String,
        creditReservationId: String?,
        provider: String,
        model: String,
        providerRequestId: String
    ) async throws -> String {
        let client = try requireClient()

        let renderJobId: String? = try await retryingMutation(
            client: client,
            name: "moments:createRenderJob",
            args: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
                "kind": kind,
                "workflowRunId": workflowRunId,
                "creditReservationId": creditReservationId,
                "provider": provider,
                "model": model,
                "providerRequestId": providerRequestId
            ]
        )

        guard let renderJobId else {
            throw MomentsProjectSyncError.missingRenderJob
        }

        return renderJobId
    }

    func attachArtifact(
        ownerUserId: String,
        projectId: String,
        renderJobId: String,
        kind: String,
        r2Key: String,
        durationSeconds: Int,
        creditCost: Int,
        hasWatermark: Bool
    ) async throws {
        let client = try requireClient()

        let artifactId: String? = try await retryingMutation(
            client: client,
            name: "moments:attachArtifact",
            args: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
                "renderJobId": renderJobId,
                "kind": kind,
                "r2Key": r2Key,
                "status": "available",
                "durationSeconds": durationSeconds,
                "creditCost": creditCost,
                "hasWatermark": hasWatermark,
                "expiresAt": expirationMilliseconds()
            ]
        )

        guard artifactId != nil else {
            throw MomentsProjectSyncError.unexpectedResponse
        }
    }

    func updateRenderJobStatus(
        ownerUserId: String,
        renderJobId: String,
        status: String,
        errorCode: String?,
        errorMessage: String?
    ) async throws {
        let client = try requireClient()
        var args = [
            "ownerUserId": ownerUserId,
            "renderJobId": renderJobId,
            "status": status
        ]
        if let errorCode {
            args["errorCode"] = errorCode
        }
        if let errorMessage {
            args["errorMessage"] = errorMessage
        }

        let updatedRenderJobId: String? = try await retryingMutation(
            client: client,
            name: "moments:updateRenderJobStatus",
            args: args
        )

        guard updatedRenderJobId != nil else {
            throw MomentsProjectSyncError.unexpectedResponse
        }
    }
}
