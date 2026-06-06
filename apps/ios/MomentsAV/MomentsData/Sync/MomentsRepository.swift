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

    func observeGalleryMoments(ownerUserId: String) throws -> AnyPublisher<[InProgressMoment], Error> {
        try remoteClient.observeGalleryMoments(ownerUserId: ownerUserId)
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

    func updateMomentSetup(ownerUserId: String, momentId: String, form: MomentSetupForm) async throws {
        guard form.canCreateMoment else {
            throw MomentsSyncError.invalidForm
        }

        try await remoteClient.updateMomentSetup(
            ownerUserId: ownerUserId,
            momentId: momentId,
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

    func updateMomentTitle(ownerUserId: String, momentId: String, title: String) async throws {
        try await remoteClient.updateMomentTitle(
            ownerUserId: ownerUserId,
            momentId: momentId,
            title: title
        )
    }

    func markMomentMovedToGallery(ownerUserId: String, momentId: String) async throws {
        try await remoteClient.markMomentMovedToGallery(
            ownerUserId: ownerUserId,
            momentId: momentId
        )
    }
}
