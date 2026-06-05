import Foundation

struct MomentsCreateWorkflowAvailability: Equatable {
    var canAddMedia = false
    var canPlanStory = false
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var canPrepareFinalRenderPlan = false
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
    var mediaMessage: String?
    var storyMessage: String?
    var previewMessage: String?
    var previewRefreshMessage: String?
    var finalRenderMessage: String?

    static func make(
        canAddMedia: Bool,
        canPlanStory: Bool,
        canGeneratePreview: Bool,
        canRefreshPreviewStatus: Bool,
        canPrepareFinalRenderPlan: Bool,
        canGenerateFinalRender: Bool,
        canRefreshFinalRenderStatus: Bool,
        mediaMessage: String?,
        storyMessage: String?,
        previewMessage: String?,
        previewRefreshMessage: String?,
        finalRenderMessage: String?
    ) -> MomentsCreateWorkflowAvailability {
        MomentsCreateWorkflowAvailability(
            canAddMedia: canAddMedia,
            canPlanStory: canPlanStory,
            canGeneratePreview: canGeneratePreview,
            canRefreshPreviewStatus: canRefreshPreviewStatus,
            canPrepareFinalRenderPlan: canPrepareFinalRenderPlan,
            canGenerateFinalRender: canGenerateFinalRender,
            canRefreshFinalRenderStatus: canRefreshFinalRenderStatus,
            mediaMessage: mediaMessage,
            storyMessage: storyMessage,
            previewMessage: previewMessage,
            previewRefreshMessage: previewRefreshMessage,
            finalRenderMessage: finalRenderMessage
        )
    }
}
