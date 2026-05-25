import Foundation

struct MomentsCreateWorkflowAvailability: Equatable {
    var canAddMedia = false
    var canDraftStory = false
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
    var mediaMessage: String?
    var storyMessage: String?
    var previewMessage: String?
    var previewRefreshMessage: String?
    var finalRenderMessage: String?
    var finalRenderRefreshMessage: String?

    static func make(
        canAddMedia: Bool,
        canDraftStory: Bool,
        canGeneratePreview: Bool,
        canRefreshPreviewStatus: Bool,
        canGenerateFinalRender: Bool,
        canRefreshFinalRenderStatus: Bool,
        mediaMessage: String?,
        storyMessage: String?,
        previewMessage: String?,
        previewRefreshMessage: String?,
        finalRenderMessage: String?,
        finalRenderRefreshMessage: String?
    ) -> MomentsCreateWorkflowAvailability {
        MomentsCreateWorkflowAvailability(
            canAddMedia: canAddMedia,
            canDraftStory: canDraftStory,
            canGeneratePreview: canGeneratePreview,
            canRefreshPreviewStatus: canRefreshPreviewStatus,
            canGenerateFinalRender: canGenerateFinalRender,
            canRefreshFinalRenderStatus: canRefreshFinalRenderStatus,
            mediaMessage: mediaMessage,
            storyMessage: storyMessage,
            previewMessage: previewMessage,
            previewRefreshMessage: previewRefreshMessage,
            finalRenderMessage: finalRenderMessage,
            finalRenderRefreshMessage: finalRenderRefreshMessage
        )
    }
}

@MainActor
enum MomentsCreateWorkflowCapabilityFactory {
    static func make(
        activeProjectId: String?,
        isImportingMedia: Bool,
        isMediaUploadConfigured: Bool,
        mediaRemainingSlots: Int,
        storyDraftWorkflow: StoryDraftWorkflow?,
        previewGenerationWorkflow: PreviewGenerationWorkflow?,
        finalRenderWorkflow: FinalRenderWorkflow?,
        template: MomentTemplate,
        previewRefreshAvailability: RenderJobStatusRefreshAvailability,
        finalRenderRefreshAvailability: RenderJobStatusRefreshAvailability,
        latestPreview: MomentArtifact?
    ) -> MomentsCreateWorkflowCapability {
        MomentsCreateWorkflowCapability(
            canAddMedia: canAddMedia(
                activeProjectId: activeProjectId,
                isImportingMedia: isImportingMedia,
                isMediaUploadConfigured: isMediaUploadConfigured,
                mediaRemainingSlots: mediaRemainingSlots
            ),
            canDraftStory: canDraftStory(
                activeProjectId: activeProjectId,
                storyDraftWorkflow: storyDraftWorkflow,
                template: template
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
        activeProjectId: String?,
        isImportingMedia: Bool,
        isMediaUploadConfigured: Bool,
        mediaRemainingSlots: Int
    ) -> Bool {
        activeProjectId != nil
            && !isImportingMedia
            && isMediaUploadConfigured
            && mediaRemainingSlots > 0
    }

    private static func canDraftStory(
        activeProjectId: String?,
        storyDraftWorkflow: StoryDraftWorkflow?,
        template: MomentTemplate
    ) -> Bool {
        guard let storyDraftWorkflow, activeProjectId != nil else { return false }
        return storyDraftWorkflow.canDraft(template: template)
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

struct MomentsCreateWorkflowCapability: Equatable {
    var canAddMedia = false
    var canDraftStory = false
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
}
