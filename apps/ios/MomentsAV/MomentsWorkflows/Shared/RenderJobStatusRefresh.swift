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

struct RenderJobStatusRefreshAvailability {
    let projectId: String?
    let job: MomentRenderJob?
    let isAvailable: Bool
    let isConfigured: Bool
    let isRefreshing: Bool
    let unavailableMessage: String
    let notConfiguredMessage: String
    let missingProjectMessage: String
    let missingJobMessage: String
    let missingProviderRequestMessage: String

    var message: String? {
        guard projectId != nil else { return missingProjectMessage }
        if !isAvailable { return unavailableMessage }
        if isRefreshing { return nil }
        if !isConfigured { return notConfiguredMessage }
        guard let job else { return missingJobMessage }
        if job.providerRequestId == nil { return missingProviderRequestMessage }
        return nil
    }

    var canRefresh: Bool {
        projectId != nil
            && !isRefreshing
            && isAvailable
            && isConfigured
            && job?.providerRequestId != nil
    }
}

struct RenderJobStatusRefreshError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}
