import Foundation

extension MomentsProjectRepository {
    func savePreviewResult(
        ownerUserId: String,
        projectId: String,
        preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) async throws {
        try await saveRenderResult(
            ownerUserId: ownerUserId,
            projectId: projectId,
            request: .preview(preview, template: template)
        )
    }

    func saveFinalRenderResult(
        ownerUserId: String,
        projectId: String,
        finalRender: MomentsFinalRenderResponse,
        template: MomentTemplate
    ) async throws {
        try await saveRenderResult(
            ownerUserId: ownerUserId,
            projectId: projectId,
            request: .finalRender(finalRender, template: template)
        )
    }

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

extension RenderResultPersistenceRequest {
    static func preview(
        _ preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) -> RenderResultPersistenceRequest {
        RenderResultPersistenceRequest(
            renderKind: "preview",
            artifactKind: "preview",
            workflowRunId: preview.workflowRunId,
            creditReservationId: nil,
            provider: preview.provider,
            model: preview.model,
            providerRequestId: preview.renderJobId,
            r2Key: preview.r2Key,
            durationSeconds: template.durationSeconds,
            creditCost: 0,
            hasWatermark: preview.hasWatermark,
            status: preview.status
        )
    }

    static func finalRender(
        _ finalRender: MomentsFinalRenderResponse,
        template: MomentTemplate
    ) -> RenderResultPersistenceRequest {
        RenderResultPersistenceRequest(
            renderKind: "final",
            artifactKind: "final_export",
            workflowRunId: finalRender.workflowRunId,
            creditReservationId: finalRender.reservationId,
            provider: finalRender.provider,
            model: finalRender.model,
            providerRequestId: finalRender.renderJobId,
            r2Key: finalRender.r2Key,
            durationSeconds: template.durationSeconds,
            creditCost: finalRender.creditsCommitted,
            hasWatermark: false,
            status: finalRender.status
        )
    }
}
