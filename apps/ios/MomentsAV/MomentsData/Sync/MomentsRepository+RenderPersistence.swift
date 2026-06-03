import Foundation

extension MomentsRepository {
    func saveStartedFinalRender(
        ownerUserId: String,
        momentId: String,
        reservationId: String,
        startedWorkflow: MomentsStartWorkflowResponse
    ) async throws -> String {
        let renderJobId = try await remoteClient.createRenderJob(
            ownerUserId: ownerUserId,
            momentId: momentId,
            kind: "final",
            workflowRunId: startedWorkflow.workflowRunId,
            creditReservationId: reservationId,
            provider: "appsav-api",
            model: "moments-final-provider-async",
            providerRequestId: startedWorkflow.renderJobId
        )

        try await remoteClient.updateRenderJobStatus(
            ownerUserId: ownerUserId,
            renderJobId: renderJobId,
            status: startedWorkflow.status,
            phase: "queued",
            progressPercent: 10,
            userMessage: "Avi has started creating the video.",
            canEditSetup: false,
            canRetry: false,
            errorCode: nil,
            errorMessage: nil
        )

        return renderJobId
    }

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

    func saveFinalRenderResult(
        ownerUserId: String,
        momentId: String,
        finalRender: MomentsFinalRenderResponse,
        template: MomentTemplate
    ) async throws {
        try await saveRenderResult(
            ownerUserId: ownerUserId,
            momentId: momentId,
            request: .finalRender(finalRender, template: template)
        )
    }

    func saveCompletedFinalRenderStatusArtifact(
        ownerUserId: String,
        momentId: String,
        renderJobId: String,
        status: MomentsRenderStatusResponse
    ) async throws {
        guard status.status == "completed",
              status.artifactKind == "final_export",
              status.artifactStatus == "available",
              let r2Key = status.artifactR2Key,
              !r2Key.isEmpty else {
            return
        }

        try await remoteClient.attachArtifact(
            ownerUserId: ownerUserId,
            momentId: momentId,
            renderJobId: renderJobId,
            kind: "final_export",
            r2Key: r2Key,
            durationSeconds: max(1, status.artifactDurationSeconds ?? 1),
            creditCost: max(0, status.artifactCreditCost ?? 0),
            hasWatermark: status.artifactHasWatermark ?? true
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
