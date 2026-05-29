import Foundation

extension MomentsProjectRepository {
    func saveStartedFinalRender(
        ownerUserId: String,
        projectId: String,
        reservationId: String,
        startedWorkflow: MomentsStartWorkflowResponse
    ) async throws -> String {
        let renderJobId = try await remoteClient.createRenderJob(
            ownerUserId: ownerUserId,
            projectId: projectId,
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
            canEditDraft: false,
            canRetry: false,
            errorCode: nil,
            errorMessage: nil
        )

        return renderJobId
    }

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
            phase: request.status == "completed" ? "completed" : nil,
            progressPercent: request.status == "completed" ? 100 : nil,
            userMessage: request.status == "completed" ? "Your video is ready." : nil,
            canEditDraft: true,
            canRetry: false,
            errorCode: nil,
            errorMessage: nil
        )
    }
}
