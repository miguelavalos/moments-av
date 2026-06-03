@preconcurrency import ConvexMobile
import Foundation

extension MomentsRemoteClient {
    func createRenderJob(
        ownerUserId: String,
        momentId: String,
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
                "momentId": momentId,
                "kind": kind,
                "workflowRunId": workflowRunId,
                "creditReservationId": creditReservationId,
                "provider": provider,
                "model": model,
                "providerRequestId": providerRequestId
            ]
        )

        guard let renderJobId else {
            throw MomentsSyncError.missingRenderJob
        }

        return renderJobId
    }

    func attachArtifact(
        ownerUserId: String,
        momentId: String,
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
                "momentId": momentId,
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
            throw MomentsSyncError.unexpectedResponse
        }
    }

    func updateRenderJobStatus(
        ownerUserId: String,
        renderJobId: String,
        status: String,
        phase: String?,
        progressPercent: Int?,
        userMessage: String?,
        canEditSetup: Bool?,
        canRetry: Bool?,
        errorCode: String?,
        errorMessage: String?
    ) async throws {
        let client = try requireClient()
        var args: [String: ConvexEncodable?] = [
            "ownerUserId": ownerUserId as ConvexEncodable,
            "renderJobId": renderJobId as ConvexEncodable,
            "status": status as ConvexEncodable
        ]
        if let errorCode {
            args["errorCode"] = errorCode as ConvexEncodable
        }
        if let errorMessage {
            args["errorMessage"] = errorMessage as ConvexEncodable
        }
        if let phase {
            args["phase"] = phase as ConvexEncodable
        }
        if let progressPercent {
            args["progressPercent"] = progressPercent as ConvexEncodable
        }
        if let userMessage {
            args["userMessage"] = userMessage as ConvexEncodable
        }
        if let canEditSetup {
            args["canEditMoment"] = canEditSetup as ConvexEncodable
        }
        if let canRetry {
            args["canRetry"] = canRetry as ConvexEncodable
        }

        let updatedRenderJobId: String? = try await retryingMutation(
            client: client,
            name: "moments:updateRenderJobStatus",
            args: args
        )

        guard updatedRenderJobId != nil else {
            throw MomentsSyncError.unexpectedResponse
        }
    }
}
