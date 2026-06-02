import Combine
import Foundation

struct MomentsRepository {
    let remoteClient: MomentsRemoteClient

    @MainActor
    init() {
        self.init(deploymentURL: AppConfig.momentsConvexURL)
    }

    init(deploymentURL: String) {
        remoteClient = MomentsRemoteClient(deploymentURL: deploymentURL)
    }

    var isConfigured: Bool {
        remoteClient.isConfigured
    }

    func observeInProgressMoments(ownerUserId: String) throws -> AnyPublisher<[InProgressMoment], Error> {
        try remoteClient.observeInProgressMoments(ownerUserId: ownerUserId)
    }

    func observeMomentWorkspace(
        ownerUserId: String,
        momentId: String
    ) throws -> AnyPublisher<MomentWorkspace?, Error> {
        try remoteClient.observeMomentWorkspace(
            ownerUserId: ownerUserId,
            momentId: momentId
        )
    }

    func createMoment(ownerUserId: String, form: MomentSetupForm) async throws -> String {
        guard form.canCreateMoment else {
            throw MomentsSyncError.invalidForm
        }

        return try await remoteClient.createMoment(
            ownerUserId: ownerUserId,
            form: form
        )
    }

    func updateRenderJobStatus(
        ownerUserId: String,
        renderJobId: String,
        status: String,
        phase: String?,
        progressPercent: Int?,
        userMessage: String?,
        canEditSetup: Bool?,
        canRetry: Bool?,
        errorCode: String?,
        errorMessage: String?
    ) async throws {
        try await remoteClient.updateRenderJobStatus(
            ownerUserId: ownerUserId,
            renderJobId: renderJobId,
            status: status,
            phase: phase,
            progressPercent: progressPercent,
            userMessage: userMessage,
            canEditSetup: canEditSetup,
            canRetry: canRetry,
            errorCode: errorCode,
            errorMessage: errorMessage
        )
    }

    func deleteMoment(ownerUserId: String, momentId: String) async throws {
        try await remoteClient.deleteMomentTree(
            ownerUserId: ownerUserId,
            momentId: momentId
        )
    }
}
