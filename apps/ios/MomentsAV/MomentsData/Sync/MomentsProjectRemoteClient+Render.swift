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

        let renderJobId: String? = try await client.mutation(
            "moments:createRenderJob",
            with: [
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

        let _: String? = try await client.mutation(
            "moments:attachArtifact",
            with: [
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
    }

    func updateRenderJobStatus(
        ownerUserId: String,
        renderJobId: String,
        status: String,
        errorCode: String?,
        errorMessage: String?
    ) async throws {
        let client = try requireClient()

        let _: String? = try await client.mutation(
            "moments:updateRenderJobStatus",
            with: [
                "ownerUserId": ownerUserId,
                "renderJobId": renderJobId,
                "status": status,
                "errorCode": errorCode,
                "errorMessage": errorMessage
            ]
        )
    }
}
