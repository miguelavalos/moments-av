import Foundation

extension MomentsProjectRepository {
    func savePreviewResult(
        ownerUserId: String,
        projectId: String,
        preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) async throws {
        try await renderResultPersistenceClient.saveRenderResult(
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
        try await renderResultPersistenceClient.saveRenderResult(
            ownerUserId: ownerUserId,
            projectId: projectId,
            request: .finalRender(finalRender, template: template)
        )
    }

    private var renderResultPersistenceClient: RenderResultPersistenceClient {
        RenderResultPersistenceClient(remoteClient: remoteClient)
    }
}
