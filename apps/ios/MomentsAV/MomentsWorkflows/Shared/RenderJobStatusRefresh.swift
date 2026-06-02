import Foundation

@MainActor
struct RenderJobStatusRefresh {
    let momentId: String
    let job: MomentRenderJob
    let providerRequestId: String

    static func make(
        momentId: String?,
        job: MomentRenderJob?,
        missingProjectMessage: String,
        missingJobMessage: String,
        missingProviderRequestMessage: String
    ) throws -> RenderJobStatusRefresh {
        guard let momentId else {
            throw RenderJobStatusRefreshError(message: missingProjectMessage)
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
        usesProviderReconciliation: Bool = false,
        shouldContinue: () -> Bool
    ) async throws -> String {
        let refresh = try make(
            momentId: momentId,
            job: job,
            missingProjectMessage: messages.missingProject,
            missingJobMessage: messages.missingJob,
            missingProviderRequestMessage: messages.missingProviderRequest
        )
        try await refresh.updateStatus(
            ownerUserId: ownerUserId,
            bearerToken: bearerToken,
            statusClient: statusClient,
            statusUpdater: statusUpdater,
            usesProviderReconciliation: usesProviderReconciliation,
            shouldContinue: shouldContinue
        )
        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, momentId: refresh.momentId)
        return messages.success
    }

    func updateStatus(
        ownerUserId: String,
        bearerToken: String,
        statusClient: MomentsRenderStatusClient,
        statusUpdater: any MomentsRenderJobStatusUpdating,
        usesProviderReconciliation: Bool = false,
        shouldContinue: () -> Bool
    ) async throws {
        let status = if usesProviderReconciliation {
            try await statusClient.reconcileFinalRender(
                renderJobId: providerRequestId,
                bearerToken: bearerToken
            )
        } else {
            try await statusClient.fetchStatus(
                renderJobId: providerRequestId,
                bearerToken: bearerToken
            )
        }
        guard shouldContinue() else { throw CancellationError() }

        try await statusUpdater.updateRenderJobStatus(
            ownerUserId: ownerUserId,
            renderJobId: job.id,
            status: status.status,
            phase: status.phase,
            progressPercent: status.progressPercent,
            userMessage: status.userMessage,
            canEditDraft: status.canEditDraft,
            canRetry: status.canRetry,
            errorCode: status.errorCode,
            errorMessage: status.errorMessage
        )
        guard shouldContinue() else { throw CancellationError() }
    }
}
