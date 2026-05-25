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

    private func saveRenderResult(
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

        try await remoteClient.updateRenderJobStatus(
            ownerUserId: ownerUserId,
            renderJobId: renderJobId,
            status: request.status,
            errorCode: nil,
            errorMessage: nil
        )
    }
}
