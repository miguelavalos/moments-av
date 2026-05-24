import Foundation

struct MomentsCreateWorkflowPresentation: Equatable {
    var createdProjectId: String?
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
        createdProjectId != nil
    }
}

struct MomentsCreateWorkspaceSummary: Equatable {
    var mediaCount = 0
    var sceneCount = 0
    var renderJobCount = 0
    var hasPreviewArtifact = false
    var hasFinalExport = false

    static func make(
        workspace: MomentProjectWorkspace?,
        latestPreview: MomentArtifact?,
        finalExport: MomentArtifact?
    ) -> MomentsCreateWorkspaceSummary {
        MomentsCreateWorkspaceSummary(
            mediaCount: workspace?.mediaAssets.count ?? 0,
            sceneCount: workspace?.storyScenes.count ?? 0,
            renderJobCount: workspace?.renderJobs.count ?? 0,
            hasPreviewArtifact: latestPreview != nil,
            hasFinalExport: finalExport != nil
        )
    }
}

struct MomentsCreateMediaSummary: Equatable {
    var selectedMedia: [MomentsSelectedMedia] = []
    var syncedMediaAssets: [MomentMediaAsset] = []
    var isImporting = false
    var statusMessage: String?

    var selectedCount: Int {
        MomentsMediaRules.selectedCount(
            localMedia: selectedMedia,
            syncedMedia: syncedMediaAssets
        )
    }

    func remainingSlots(template: MomentTemplate) -> Int {
        MomentsMediaRules.remainingSlots(template: template, selectedCount: selectedCount)
    }
}

struct MomentsCreateStorySummary: Equatable {
    var savedScenes: [MomentStoryScene] = []
    var generatedScenes: [MomentsStoryDraftScene] = []
    var isDrafting = false
    var statusMessage: String?
}

struct MomentsCreatePreviewSummary: Equatable {
    var activeProject: MomentDraftProject?
    var latestPreview: MomentArtifact?
    var latestPreviewJob: MomentRenderJob?
    var isGenerating = false
    var isRefreshingStatus = false
    var statusMessage: String?
}

struct MomentsCreateFinalRenderSummary: Equatable {
    var creditCost = 0
    var finalExport: MomentArtifact?
    var latestFinalJob: MomentRenderJob?
    var isGenerating = false
    var isRefreshingStatus = false
    var statusMessage: String?
}
