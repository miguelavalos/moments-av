import Foundation

enum PreviewGenerationRun {
    @MainActor
    static func perform(
        ownerUserId: String,
        bearerToken: String,
        projectId: String,
        project: MomentDraftProject,
        template: MomentTemplate,
        previewClient: MomentsPreviewClient,
        previewResultSaver: any MomentsPreviewResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        shouldContinue: () -> Bool
    ) async throws -> String {
        let preview = try await previewClient.generatePreview(
            projectId: projectId,
            bearerToken: bearerToken,
            template: template,
            previewIndex: Int(project.previewCount) + 1
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        try await previewResultSaver.savePreviewResult(
            ownerUserId: ownerUserId,
            projectId: projectId,
            preview: preview,
            template: template
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
        return "Story review ready. You can still refine the story before final render."
    }
}
