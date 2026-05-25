import Foundation

enum PreviewGenerationRun {
    @MainActor
    static func perform(
        ownerUserId: String,
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
            ownerUserId: ownerUserId,
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
        return "Preview ready. You can still refine the story before final render."
    }
}
