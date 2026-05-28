import Foundation

enum FinalRenderGenerationRun {
    @MainActor
    static func perform(
        ownerUserId: String,
        bearerToken: String,
        projectId: String,
        template: MomentTemplate,
        finalRenderClient: MomentsFinalRenderClient,
        finalRenderResultSaver: any MomentsFinalRenderResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        updateStatus: (String) -> Void,
        shouldContinue: () -> Bool
    ) async throws -> MomentRenderJob {
        let operationId = UUID().uuidString
        updateStatus("Reserving 1 credit for the video.")
        let reservation = try await finalRenderClient.reserveFinalRenderCredits(
            projectId: projectId,
            bearerToken: bearerToken,
            template: template,
            operationId: operationId
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        updateStatus("Starting video creation.")
        let startedWorkflow = try await finalRenderClient.startFinalRenderWorkflow(
            projectId: projectId,
            bearerToken: bearerToken,
            template: template,
            reservationId: reservation.id,
            operationId: operationId
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        updateStatus("Saving video status.")
        let savedRenderJobId = try await saveStartedFinalRenderWithRetry(
            finalRenderResultSaver: finalRenderResultSaver,
            ownerUserId: ownerUserId,
            projectId: projectId,
            reservationId: reservation.id,
            startedWorkflow: startedWorkflow
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
        return MomentRenderJob(
            id: savedRenderJobId,
            kind: "final",
            status: startedWorkflow.status,
            workflowRunId: startedWorkflow.workflowRunId,
            provider: "appsav-api",
            model: "moments-final-provider-async",
            providerRequestId: startedWorkflow.renderJobId,
            errorCode: nil,
            errorMessage: nil,
            createdAt: Date().timeIntervalSince1970 * 1000,
            updatedAt: Date().timeIntervalSince1970 * 1000
        )
    }

    @MainActor
    private static func saveStartedFinalRenderWithRetry(
        finalRenderResultSaver: any MomentsFinalRenderResultSaving,
        ownerUserId: String,
        projectId: String,
        reservationId: String,
        startedWorkflow: MomentsStartWorkflowResponse
    ) async throws -> String {
        let retryPolicy = MomentsNetworkRetryPolicy()
        var attempt = 0

        while true {
            do {
                return try await finalRenderResultSaver.saveStartedFinalRender(
                    ownerUserId: ownerUserId,
                    projectId: projectId,
                    reservationId: reservationId,
                    startedWorkflow: startedWorkflow
                )
            } catch {
                guard retryPolicy.shouldRetry(error: error, attempt: attempt) else {
                    throw error
                }

                attempt += 1
                try await Task.sleep(nanoseconds: retryPolicy.delayNanoseconds(forAttempt: attempt))
            }
        }
    }
}
