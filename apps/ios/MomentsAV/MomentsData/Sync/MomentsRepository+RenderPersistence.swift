import Foundation

extension MomentsRepository {
    func savePreviewResult(
        ownerUserId: String,
        momentId: String,
        preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) async throws {
        try await saveRenderResult(
            ownerUserId: ownerUserId,
            momentId: momentId,
            request: .preview(preview, template: template)
        )
    }

    private func saveRenderResult(
        ownerUserId: String,
        momentId: String,
        request: RenderResultPersistenceRequest
    ) async throws {
        let renderJobId = try await remoteClient.createRenderJob(
            ownerUserId: ownerUserId,
            momentId: momentId,
            kind: request.renderKind,
            workflowRunId: request.workflowRunId,
            creditReservationId: request.creditReservationId,
            provider: request.provider,
            model: request.model,
            providerRequestId: request.providerRequestId
        )

        try await remoteClient.attachArtifact(
            ownerUserId: ownerUserId,
            momentId: momentId,
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
            phase: request.status == "completed" ? "completed" : nil,
            progressPercent: request.status == "completed" ? 100 : nil,
            userMessage: request.status == "completed" ? "Your video is ready." : nil,
            canEditSetup: true,
            canRetry: false,
            errorCode: nil,
            errorMessage: nil
        )
    }
}
