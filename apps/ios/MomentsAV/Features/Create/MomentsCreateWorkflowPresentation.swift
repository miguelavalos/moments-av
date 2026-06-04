import Foundation

struct MomentsCreateWorkflowPresentation: Equatable {
    var activeMomentId: String?
    var isSignedIn = false
    var isCreatingMoment = false
    var hasMomentWorkspace = false
    var hasUnsavedLocalMoment = false
    var template: MomentTemplate
    var creationStyleTitle = ""
    var toneTitle = ""
    var tempoTitle = ""
    var occasionTitle = ""
    var balance: MomentsCreditBalance
    var creditBalanceLoadState = MomentsCreditBalanceLoadState.loaded
    var mediaSummary: MomentsCreateMediaSummary
    var storySummary: MomentsCreateStorySummary
    var previewSummary: MomentsCreatePreviewSummary
    var finalRenderSummary: MomentsCreateFinalRenderSummary
    var canAddMedia = false
    var canPlanStory = false
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var canPrepareFinalRenderPlan = false
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
            || hasUnsavedLocalMoment
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

        if canPlanStory {
            return .story
        }

        return .media
    }

    var showsBlockingPreparation: Bool {
        isCreatingMoment
            || mediaSummary.isImporting
            || storySummary.isPlanning
            || previewSummary.isGenerating
            || finalRenderSummary.isGenerating
    }

    var isFinalRenderEditingLocked: Bool {
        guard let latestFinalJob = finalRenderSummary.latestFinalJob,
              latestFinalJob.isActiveRender else {
            return false
        }
        return latestFinalJob.canEditSetup != true
    }

    static func make(
        activeMomentId: String?,
        isSignedIn: Bool,
        isCreatingMoment: Bool,
        hasMomentWorkspace: Bool,
        hasUnsavedLocalMoment: Bool,
        template: MomentTemplate,
        creationStyleTitle: String,
        toneTitle: String,
        tempoTitle: String,
        occasionTitle: String,
        balance: MomentsCreditBalance,
        creditBalanceLoadState: MomentsCreditBalanceLoadState = .loaded,
        mediaSummary: MomentsCreateMediaSummary,
        storySummary: MomentsCreateStorySummary,
        previewSummary: MomentsCreatePreviewSummary,
        finalRenderSummary: MomentsCreateFinalRenderSummary,
        availability: MomentsCreateWorkflowAvailability
    ) -> MomentsCreateWorkflowPresentation {
        MomentsCreateWorkflowPresentation(
            activeMomentId: activeMomentId,
            isSignedIn: isSignedIn,
            isCreatingMoment: isCreatingMoment,
            hasMomentWorkspace: hasMomentWorkspace,
            hasUnsavedLocalMoment: hasUnsavedLocalMoment,
            template: template,
            creationStyleTitle: creationStyleTitle,
            toneTitle: toneTitle,
            tempoTitle: tempoTitle,
            occasionTitle: occasionTitle,
            balance: balance,
            creditBalanceLoadState: creditBalanceLoadState,
            mediaSummary: mediaSummary,
            storySummary: storySummary,
            previewSummary: previewSummary,
            finalRenderSummary: finalRenderSummary,
            canAddMedia: availability.canAddMedia,
            canPlanStory: availability.canPlanStory,
            canGeneratePreview: availability.canGeneratePreview,
            canRefreshPreviewStatus: availability.canRefreshPreviewStatus,
            canPrepareFinalRenderPlan: availability.canPrepareFinalRenderPlan,
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
