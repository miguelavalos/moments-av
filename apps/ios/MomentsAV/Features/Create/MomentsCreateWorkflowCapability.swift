import Foundation

@MainActor
enum MomentsCreateWorkflowCapabilityFactory {
    static func make(
        activeProjectId: String?,
        hasMomentWorkspace: Bool,
        isImportingMedia: Bool,
        isMediaUploadConfigured: Bool,
        mediaRemainingSlots: Int,
        storyDraftWorkflow: StoryDraftWorkflow?,
        previewGenerationWorkflow: PreviewGenerationWorkflow?,
        finalRenderWorkflow: FinalRenderWorkflow?,
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
                isMediaUploadConfigured: isMediaUploadConfigured,
                mediaRemainingSlots: mediaRemainingSlots
            ),
            canDraftStory: canDraftStory(
                hasMomentWorkspace: hasMomentWorkspace,
                storyDraftWorkflow: storyDraftWorkflow,
                template: template,
                selectedMediaCount: selectedMediaCount
            ),
            canGeneratePreview: canGeneratePreview(
                activeProjectId: activeProjectId,
                previewGenerationWorkflow: previewGenerationWorkflow,
                template: template
            ),
            canRefreshPreviewStatus: previewRefreshAvailability.canRefresh,
            canGenerateFinalRender: canGenerateFinalRender(
                activeProjectId: activeProjectId,
                finalRenderWorkflow: finalRenderWorkflow,
                template: template,
                latestPreview: latestPreview
            ),
            canRefreshFinalRenderStatus: finalRenderRefreshAvailability.canRefresh
        )
    }

    private static func canAddMedia(
        hasMomentWorkspace: Bool,
        isImportingMedia: Bool,
        isMediaUploadConfigured: Bool,
        mediaRemainingSlots: Int
    ) -> Bool {
        hasMomentWorkspace
            && !isImportingMedia
            && isMediaUploadConfigured
            && mediaRemainingSlots > 0
    }

    private static func canDraftStory(
        hasMomentWorkspace: Bool,
        storyDraftWorkflow: StoryDraftWorkflow?,
        template: MomentTemplate,
        selectedMediaCount: Int
    ) -> Bool {
        guard let storyDraftWorkflow, hasMomentWorkspace else { return false }
        return storyDraftWorkflow.isConfigured
            && !storyDraftWorkflow.isDrafting
            && MomentsMediaRules.availability(template: template, selectedCount: selectedMediaCount).canUseSelection
    }

    private static func canGeneratePreview(
        activeProjectId: String?,
        previewGenerationWorkflow: PreviewGenerationWorkflow?,
        template: MomentTemplate
    ) -> Bool {
        guard let previewGenerationWorkflow, activeProjectId != nil else { return false }
        return previewGenerationWorkflow.canGenerate(template: template)
    }

    private static func canGenerateFinalRender(
        activeProjectId: String?,
        finalRenderWorkflow: FinalRenderWorkflow?,
        template: MomentTemplate,
        latestPreview: MomentArtifact?
    ) -> Bool {
        guard let finalRenderWorkflow, activeProjectId != nil else { return false }
        return finalRenderWorkflow.canGenerate(
            template: template,
            latestPreview: latestPreview
        )
    }
}
