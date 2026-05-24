import Foundation

extension MomentsProjectRepository {
    func saveRenderResult(
        ownerUserId: String,
        projectId: String,
        request: RenderResultPersistenceRequest
    ) async throws {
        let renderJobId = try await remoteClient.createRenderJob(
            ownerUserId: ownerUserId,
            projectId: projectId,
            kind: request.renderKind,
            workflowRunId: request.workflowRunId,
            creditReservationId: request.creditReservationId,
            provider: request.provider,
            model: request.model,
            providerRequestId: request.providerRequestId
        )

        try await remoteClient.attachArtifact(
            ownerUserId: ownerUserId,
            projectId: projectId,
            renderJobId: renderJobId,
            kind: request.artifactKind,
            r2Key: request.r2Key,
            durationSeconds: request.durationSeconds,
            creditCost: request.creditCost,
            hasWatermark: request.hasWatermark
        )

        try await updateRenderJobStatus(
            ownerUserId: ownerUserId,
            renderJobId: renderJobId,
            status: request.status,
            errorCode: nil,
            errorMessage: nil
        )
    }
}

struct RenderResultPersistenceRequest {
    let renderKind: String
    let artifactKind: String
    let workflowRunId: String
    let creditReservationId: String?
    let provider: String
    let model: String
    let providerRequestId: String
    let r2Key: String
    let durationSeconds: Int
    let creditCost: Int
    let hasWatermark: Bool
    let status: String
}
