import Foundation

enum PreviewGenerationRun {
    @MainActor
    static func perform(
        ownerUserId: String,
        bearerToken: String,
        momentId: String,
        moment: InProgressMoment,
        template: MomentTemplate,
        form: MomentDraftForm,
        previewClient: MomentsPreviewClient,
        previewResultSaver: any MomentsPreviewResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        shouldContinue: () -> Bool
    ) async throws -> String {
        let preview = try await previewClient.generatePreview(
            momentId: momentId,
            bearerToken: bearerToken,
            template: template,
            form: form,
            previewIndex: Int(moment.previewCount) + 1
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        try await previewResultSaver.savePreviewResult(
            ownerUserId: ownerUserId,
            momentId: momentId,
            preview: preview,
            template: template
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, momentId: momentId)
        return L10n.string("create.preview.status.readyRefine")
    }
}
