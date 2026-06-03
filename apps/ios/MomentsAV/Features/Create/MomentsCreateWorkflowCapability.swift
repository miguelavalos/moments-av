import Foundation

@MainActor
enum MomentsCreateWorkflowCapabilityFactory {
    static func make(
        activeMomentId: String?,
        isSignedIn: Bool,
        hasMomentWorkspace: Bool,
        isImportingMedia: Bool,
        mediaRemainingSlots: Int,
        storyPlanWorkflow: StoryPlanWorkflow?,
        previewGenerationWorkflow: PreviewGenerationWorkflow?,
        finalRenderWorkflow: FinalRenderWorkflow?,
        creditBalanceLoadState: MomentsCreditBalanceLoadState = .loaded,
        template: MomentTemplate,
        previewRefreshAvailability: RenderJobStatusRefreshAvailability,
        finalRenderRefreshAvailability: RenderJobStatusRefreshAvailability,
        latestPreview: MomentArtifact?,
        selectedMediaCount: Int
    ) -> MomentsCreateWorkflowCapability {
        MomentsCreateWorkflowCapability(
            canAddMedia: canAddMedia(
                hasMomentWorkspace: hasMomentWorkspace,
                isImportingMedia: isImportingMedia,
                mediaRemainingSlots: mediaRemainingSlots
            ),
            canPlanStory: canPlanStory(
                isSignedIn: isSignedIn,
                hasMomentWorkspace: hasMomentWorkspace,
                storyPlanWorkflow: storyPlanWorkflow,
                template: template,
                selectedMediaCount: selectedMediaCount
            ),
            canGeneratePreview: canGeneratePreview(
                activeMomentId: activeMomentId,
                previewGenerationWorkflow: previewGenerationWorkflow,
                template: template
            ),
            canRefreshPreviewStatus: previewRefreshAvailability.canRefresh,
            canPrepareFinalRenderPlan: canPrepareFinalRenderPlan(
                activeMomentId: activeMomentId,
                finalRenderWorkflow: finalRenderWorkflow
            ),
            canGenerateFinalRender: canGenerateFinalRender(
                activeMomentId: activeMomentId,
                finalRenderWorkflow: finalRenderWorkflow,
                creditBalanceLoadState: creditBalanceLoadState,
                template: template,
                latestPreview: latestPreview
            ),
            canRefreshFinalRenderStatus: finalRenderRefreshAvailability.canRefresh
        )
    }

    private static func canAddMedia(
        hasMomentWorkspace: Bool,
        isImportingMedia: Bool,
        mediaRemainingSlots: Int
    ) -> Bool {
        hasMomentWorkspace
            && !isImportingMedia
            && mediaRemainingSlots > 0
    }

    private static func canPlanStory(
        isSignedIn: Bool,
        hasMomentWorkspace: Bool,
        storyPlanWorkflow: StoryPlanWorkflow?,
        template: MomentTemplate,
        selectedMediaCount: Int
    ) -> Bool {
        guard isSignedIn else { return false }
        guard let storyPlanWorkflow, hasMomentWorkspace else { return false }
        return storyPlanWorkflow.isConfigured
            && !storyPlanWorkflow.isPlanning
            && MomentsMediaRules.availability(template: template, selectedCount: selectedMediaCount).canUseSelection
    }

    private static func canGeneratePreview(
        activeMomentId: String?,
        previewGenerationWorkflow: PreviewGenerationWorkflow?,
        template: MomentTemplate
    ) -> Bool {
        guard let previewGenerationWorkflow, activeMomentId != nil else { return false }
        return previewGenerationWorkflow.canGenerate(template: template)
    }

    private static func canPrepareFinalRenderPlan(
        activeMomentId: String?,
        finalRenderWorkflow: FinalRenderWorkflow?
    ) -> Bool {
        guard let finalRenderWorkflow, activeMomentId != nil else { return false }
        return finalRenderWorkflow.canPreparePlan()
    }

    private static func canGenerateFinalRender(
        activeMomentId: String?,
        finalRenderWorkflow: FinalRenderWorkflow?,
        creditBalanceLoadState: MomentsCreditBalanceLoadState,
        template: MomentTemplate,
        latestPreview: MomentArtifact?
    ) -> Bool {
        guard let finalRenderWorkflow, activeMomentId != nil else { return false }
        guard creditBalanceLoadState.hasLoadedBalance else { return false }
        return finalRenderWorkflow.canGenerate(
            template: template,
            latestPreview: latestPreview
        )
    }
}
