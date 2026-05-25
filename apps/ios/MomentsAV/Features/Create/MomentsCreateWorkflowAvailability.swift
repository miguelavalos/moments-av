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

