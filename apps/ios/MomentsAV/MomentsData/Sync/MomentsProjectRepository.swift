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

    func observeProjects(ownerUserId: String) throws -> AnyPublisher<[MomentDraftProject], Never> {
        try remoteClient.observeProjects(ownerUserId: ownerUserId)
    }

    func observeProjectWorkspace(
        ownerUserId: String,
        projectId: String
    ) throws -> AnyPublisher<MomentProjectWorkspace?, Never> {
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

    func savePreviewResult(
        ownerUserId: String,
        projectId: String,
        preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) async throws {
        try await saveRenderResult(
            ownerUserId: ownerUserId,
            projectId: projectId,
            request: RenderResultPersistenceRequest(
                renderKind: "preview",
                artifactKind: "preview",
                workflowRunId: preview.workflowRunId,
                creditReservationId: nil,
                provider: preview.provider,
                model: preview.model,
                providerRequestId: preview.renderJobId,
                r2Key: preview.r2Key,
                durationSeconds: template.durationSeconds,
                creditCost: 0,
                hasWatermark: preview.hasWatermark,
                status: preview.status
            )
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
            request: RenderResultPersistenceRequest(
                renderKind: "final",
                artifactKind: "final_export",
                workflowRunId: finalRender.workflowRunId,
                creditReservationId: finalRender.reservationId,
                provider: finalRender.provider,
                model: finalRender.model,
                providerRequestId: finalRender.renderJobId,
                r2Key: finalRender.r2Key,
                durationSeconds: template.durationSeconds,
                creditCost: finalRender.creditsCommitted,
                hasWatermark: false,
                status: finalRender.status
            )
        )
    }

    func updateRenderJobStatus(
        ownerUserId: String,
        renderJobId: String,
        status: String,
        errorCode: String?,
        errorMessage: String?
    ) async throws {
        try await remoteClient.updateRenderJobStatus(
            ownerUserId: ownerUserId,
            renderJobId: renderJobId,
            status: status,
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
