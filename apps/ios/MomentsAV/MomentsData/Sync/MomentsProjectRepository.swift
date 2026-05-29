import Combine
import Foundation

struct MomentsProjectRepository {
    let remoteClient: MomentsProjectRemoteClient

    @MainActor
    init() {
        self.init(deploymentURL: AppConfig.momentsConvexURL)
    }

    init(deploymentURL: String) {
        remoteClient = MomentsProjectRemoteClient(deploymentURL: deploymentURL)
    }

    var isConfigured: Bool {
        remoteClient.isConfigured
    }

    func observeProjects(ownerUserId: String) throws -> AnyPublisher<[MomentDraftProject], Error> {
        try remoteClient.observeProjects(ownerUserId: ownerUserId)
    }

    func observeProjectWorkspace(
        ownerUserId: String,
        projectId: String
    ) throws -> AnyPublisher<MomentProjectWorkspace?, Error> {
        try remoteClient.observeProjectWorkspace(
            ownerUserId: ownerUserId,
            projectId: projectId
        )
    }

    func createDraft(ownerUserId: String, form: MomentDraftForm) async throws -> String {
        guard form.canCreateDraft else {
            throw MomentsProjectSyncError.invalidForm
        }

        return try await remoteClient.createDraftProject(
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
        canEditDraft: Bool?,
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
            canEditDraft: canEditDraft,
            canRetry: canRetry,
            errorCode: errorCode,
            errorMessage: errorMessage
        )
    }

    func deleteProject(ownerUserId: String, projectId: String) async throws {
        try await remoteClient.deleteProjectTree(
            ownerUserId: ownerUserId,
            projectId: projectId
        )
    }
}
