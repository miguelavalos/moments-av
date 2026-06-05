import Foundation

@MainActor
struct RenderJobStatusRefresh {
    let momentId: String
    let job: MomentRenderJob
    let providerRequestId: String

    static func make(
        momentId: String?,
        job: MomentRenderJob?,
        missingMomentMessage: String,
        missingJobMessage: String,
        missingProviderRequestMessage: String
    ) throws -> RenderJobStatusRefresh {
        guard let momentId else {
            throw RenderJobStatusRefreshError(message: missingMomentMessage)
        }
        guard let job else {
            throw RenderJobStatusRefreshError(message: missingJobMessage)
        }
        guard let providerRequestId = job.providerRequestId else {
            throw RenderJobStatusRefreshError(message: missingProviderRequestMessage)
        }

        return RenderJobStatusRefresh(
            momentId: momentId,
            job: job,
            providerRequestId: providerRequestId
        )
    }

    static func perform(
        ownerUserId: String,
        bearerToken: String,
        momentId: String?,
        job: MomentRenderJob?,
        messages: RenderJobStatusRefreshMessages,
        statusClient: MomentsRenderStatusClient,
        statusUpdater: any MomentsRenderJobStatusUpdating,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        shouldContinue: () -> Bool
    ) async throws -> String {
        let refresh = try make(
            momentId: momentId,
            job: job,
            missingMomentMessage: messages.missingMoment,
            missingJobMessage: messages.missingJob,
            missingProviderRequestMessage: messages.missingProviderRequest
        )
        try await refresh.updateStatus(
            ownerUserId: ownerUserId,
            bearerToken: bearerToken,
            statusClient: statusClient,
            statusUpdater: statusUpdater,
            shouldContinue: shouldContinue
        )
        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, momentId: refresh.momentId)
        return messages.success
    }

    @discardableResult
    func updateStatus(
        ownerUserId: String,
        bearerToken: String,
        statusClient: MomentsRenderStatusClient,
        statusUpdater: any MomentsRenderJobStatusUpdating,
        shouldContinue: () -> Bool
    ) async throws -> MomentsRenderStatusResponse {
        let status = try await fetchStatus(
            bearerToken: bearerToken,
            statusClient: statusClient
        )
        guard shouldContinue() else { throw CancellationError() }

        try await saveStatus(
            ownerUserId: ownerUserId,
            status: status,
            statusUpdater: statusUpdater
        )
        guard shouldContinue() else { throw CancellationError() }

        return status
    }

    func fetchStatus(
        bearerToken: String,
        statusClient: MomentsRenderStatusClient
    ) async throws -> MomentsRenderStatusResponse {
        try await statusClient.fetchStatus(
            renderJobId: providerRequestId,
            bearerToken: bearerToken
        )
    }

    func saveStatus(
        ownerUserId: String,
        status: MomentsRenderStatusResponse,
        statusUpdater: any MomentsRenderJobStatusUpdating
    ) async throws {
        try await statusUpdater.updateRenderJobStatus(
            ownerUserId: ownerUserId,
            renderJobId: job.id,
            status: status.status,
            phase: status.phase,
            progressPercent: status.progressPercent,
            userMessage: status.userMessage,
            canEditSetup: status.canEditSetup,
            canRetry: status.canRetry,
            errorCode: status.errorCode,
            errorMessage: status.errorMessage
        )
    }

}
