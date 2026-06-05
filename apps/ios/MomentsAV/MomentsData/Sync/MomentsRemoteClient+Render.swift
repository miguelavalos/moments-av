@preconcurrency import ConvexMobile
import Foundation

extension MomentsRemoteClient {
    func createRenderJob(
        ownerUserId: String,
        momentId: String,
        kind: String,
        workflowRunId: String,
        creditReservationId: String?,
        baseCreditCost: Int? = nil,
        watermarkRemovalCreditCost: Int? = nil,
        totalCreditCost: Int? = nil,
        provider: String,
        model: String,
        providerRequestId: String,
        targetDurationMs: Int? = nil,
        plannedAssetCount: Int? = nil,
        usedAssetCount: Int? = nil,
        rejectedAssetCount: Int? = nil,
        rendererMode: String? = nil
    ) async throws -> String {
        let client = try requireClient()

        var args: [String: ConvexEncodable?] = [
            "ownerUserId": ownerUserId as ConvexEncodable,
            "momentId": momentId as ConvexEncodable,
            "kind": kind as ConvexEncodable,
            "workflowRunId": workflowRunId as ConvexEncodable,
            "creditReservationId": creditReservationId as ConvexEncodable?,
            "provider": provider as ConvexEncodable,
            "model": model as ConvexEncodable,
            "providerRequestId": providerRequestId as ConvexEncodable
        ]
        if let baseCreditCost {
            args["baseCreditCost"] = Double(baseCreditCost) as ConvexEncodable
        }
        if let watermarkRemovalCreditCost {
            args["watermarkRemovalCreditCost"] = Double(watermarkRemovalCreditCost) as ConvexEncodable
        }
        if let totalCreditCost {
            args["totalCreditCost"] = Double(totalCreditCost) as ConvexEncodable
        }
        if let targetDurationMs {
            args["targetDurationMs"] = Double(targetDurationMs) as ConvexEncodable
        }
        if let plannedAssetCount {
            args["plannedAssetCount"] = Double(plannedAssetCount) as ConvexEncodable
        }
        if let usedAssetCount {
            args["usedAssetCount"] = Double(usedAssetCount) as ConvexEncodable
        }
        if let rejectedAssetCount {
            args["rejectedAssetCount"] = Double(rejectedAssetCount) as ConvexEncodable
        }
        if let rendererMode {
            args["rendererMode"] = rendererMode as ConvexEncodable
        }

        let renderJobId: String? = try await retryingMutation(
            client: client,
            name: "moments:createRenderJob",
            args: args
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
                "durationSeconds": Double(durationSeconds),
                "creditCost": Double(creditCost),
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
            args["progressPercent"] = Double(progressPercent) as ConvexEncodable
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
