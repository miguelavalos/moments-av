import Foundation

struct MomentsCreateWorkflowPresentation: Equatable {
    var activeProjectId: String?
    var isSignedIn = false
    var hasMomentWorkspace = false
    var template: MomentTemplate
    var mediaSummary: MomentsCreateMediaSummary
    var storySummary: MomentsCreateStorySummary
    var previewSummary: MomentsCreatePreviewSummary
    var finalRenderSummary: MomentsCreateFinalRenderSummary
    var canAddMedia = false
    var canDraftStory = false
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
    var mediaAvailabilityMessage: String?
    var storyAvailabilityMessage: String?
    var previewAvailabilityMessage: String?
    var previewRefreshAvailabilityMessage: String?
    var finalRenderAvailabilityMessage: String?
    var finalRenderRefreshAvailabilityMessage: String?

    var showsWorkflowCards: Bool {
        hasMomentWorkspace
    }

    var showsMediaFirstWorkspace: Bool {
        hasMomentWorkspace
            || mediaSummary.selectedCount > 0
            || !mediaSummary.syncedMediaAssets.isEmpty
            || previewSummary.latestPreview != nil
            || finalRenderSummary.finalExport != nil
    }

    var currentStage: MomentsCreateCurrentStage {
        if finalRenderSummary.finalExport != nil {
            return .finalVideo
        }

        if previewSummary.latestPreview != nil || previewSummary.latestPreviewJob != nil {
            return .finalVideo
        }

        if !storySummary.savedScenes.isEmpty || !storySummary.generatedScenes.isEmpty {
            return .finalVideo
        }

        if canDraftStory {
            return .story
        }

        return .media
    }

    static func make(
        activeProjectId: String?,
        isSignedIn: Bool,
        hasMomentWorkspace: Bool,
        template: MomentTemplate,
        mediaSummary: MomentsCreateMediaSummary,
        storySummary: MomentsCreateStorySummary,
        previewSummary: MomentsCreatePreviewSummary,
        finalRenderSummary: MomentsCreateFinalRenderSummary,
        availability: MomentsCreateWorkflowAvailability
    ) -> MomentsCreateWorkflowPresentation {
        MomentsCreateWorkflowPresentation(
            activeProjectId: activeProjectId,
            isSignedIn: isSignedIn,
            hasMomentWorkspace: hasMomentWorkspace,
            template: template,
            mediaSummary: mediaSummary,
            storySummary: storySummary,
            previewSummary: previewSummary,
            finalRenderSummary: finalRenderSummary,
            canAddMedia: availability.canAddMedia,
            canDraftStory: availability.canDraftStory,
            canGeneratePreview: availability.canGeneratePreview,
            canRefreshPreviewStatus: availability.canRefreshPreviewStatus,
            canGenerateFinalRender: availability.canGenerateFinalRender,
            canRefreshFinalRenderStatus: availability.canRefreshFinalRenderStatus,
            mediaAvailabilityMessage: availability.mediaMessage,
            storyAvailabilityMessage: availability.storyMessage,
            previewAvailabilityMessage: availability.previewMessage,
            previewRefreshAvailabilityMessage: availability.previewRefreshMessage,
            finalRenderAvailabilityMessage: availability.finalRenderMessage,
            finalRenderRefreshAvailabilityMessage: availability.finalRenderRefreshMessage
        )
    }
}

enum MomentsCreateCurrentStage: Equatable {
    case media
    case story
    case preview
    case finalVideo
}
