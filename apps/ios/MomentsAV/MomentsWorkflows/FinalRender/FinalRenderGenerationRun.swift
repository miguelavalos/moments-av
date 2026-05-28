import Foundation

enum FinalRenderGenerationRun {
    @MainActor
    static func perform(
        ownerUserId: String,
        bearerToken: String,
        projectId: String,
        template: MomentTemplate,
        finalRenderClient: MomentsFinalRenderClient,
        finalRenderResultSaver: any MomentsFinalRenderResultSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        shouldContinue: () -> Bool
    ) async throws -> String {
        let finalRender = try await finalRenderClient.generateFinalRender(
            projectId: projectId,
            bearerToken: bearerToken,
            template: template
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        try await finalRenderResultSaver.saveFinalRenderResult(
            ownerUserId: ownerUserId,
            projectId: projectId,
            finalRender: finalRender,
            template: template
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
        return "Export ready. Credits were committed for the delivered render."
    }
}
