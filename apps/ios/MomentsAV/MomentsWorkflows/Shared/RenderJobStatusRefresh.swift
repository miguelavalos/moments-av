import Foundation

@MainActor
struct RenderJobStatusRefresh {
    let projectId: String
    let job: MomentRenderJob
    let providerRequestId: String

    static func make(
        projectId: String?,
        job: MomentRenderJob?,
        missingProjectMessage: String,
        missingJobMessage: String,
        missingProviderRequestMessage: String
    ) throws -> RenderJobStatusRefresh {
        guard let projectId else {
            throw RenderJobStatusRefreshError(message: missingProjectMessage)
        }
        guard let job else {
            throw RenderJobStatusRefreshError(message: missingJobMessage)
        }
        guard let providerRequestId = job.providerRequestId else {
            throw RenderJobStatusRefreshError(message: missingProviderRequestMessage)
        }

        return RenderJobStatusRefresh(
            projectId: projectId,
            job: job,
            providerRequestId: providerRequestId
        )
    }

    static func perform(
        ownerUserId: String,
        projectId: String?,
        job: MomentRenderJob?,
        messages: RenderJobStatusRefreshMessages,
        statusClient: MomentsRenderStatusClient,
        statusUpdater: any MomentsRenderJobStatusUpdating,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        shouldContinue: () -> Bool
    ) async throws -> String {
        let refresh = try make(
            projectId: projectId,
            job: job,
            missingProjectMessage: messages.missingProject,
            missingJobMessage: messages.missingJob,
            missingProviderRequestMessage: messages.missingProviderRequest
        )
        try await refresh.updateStatus(
            ownerUserId: ownerUserId,
            statusClient: statusClient,
            statusUpdater: statusUpdater,
            shouldContinue: shouldContinue
        )
        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: refresh.projectId)
        return messages.success
    }

    func updateStatus(
        ownerUserId: String,
        statusClient: MomentsRenderStatusClient,
        statusUpdater: any MomentsRenderJobStatusUpdating,
        shouldContinue: () -> Bool
    ) async throws {
        let status = try await statusClient.fetchStatus(
            renderJobId: providerRequestId,
            ownerUserId: ownerUserId
        )
        guard shouldContinue() else { throw CancellationError() }

        try await statusUpdater.updateRenderJobStatus(
            ownerUserId: ownerUserId,
            renderJobId: job.id,
            status: status.status,
            errorCode: status.errorCode,
            errorMessage: status.errorMessage
        )
        guard shouldContinue() else { throw CancellationError() }
    }
}
