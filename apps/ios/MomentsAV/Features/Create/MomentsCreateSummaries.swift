import Foundation

struct MomentsCreateWorkflowPresentation: Equatable {
    var activeProjectId: String?
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
        activeProjectId != nil
    }
}

struct MomentsCreateDraftSetupPresentation: Equatable {
    var templateSummary: MomentsCreateTemplateSummaryPresentation
    var isDraftLocked = false
    var isCreatingDraft = false
    var canCreateDraft = false
    var availabilityMessage: String?
    var activeProjectId: String?
    var isContinuingProject = false
    var canStartAnotherProject = false
    var draftErrorMessage: String?
    var workspaceSummary: MomentsCreateWorkspaceSummary

    var createDraftTitle: String {
        isCreatingDraft ? "Creating draft..." : "Create draft"
    }

    var activeProjectLabel: String {
        isContinuingProject ? "Continuing project" : "Draft created"
    }

    var activeProjectDetail: String {
        isContinuingProject
            ? "Create is attached to this existing project."
            : "Draft setup is locked for this project."
    }

    var showsActiveProject: Bool {
        activeProjectId != nil
    }
}

struct MomentsCreateTemplateSummaryPresentation: Equatable {
    var template: MomentTemplate
    var canAfford = false
    var spendPlanDescription: String

    var creditTitle: String {
        "\(template.creditCost) cr"
    }

    var metadataTitle: String {
        "\(template.duration) · \(template.mediaRange)"
    }
}

struct MomentsCreateMediaPresentation: Equatable {
    var activeProjectId: String
    var template: MomentTemplate
    var summary: MomentsCreateMediaSummary
    var canAddMedia = false
    var availabilityMessage: String?

    var remainingSlots: Int {
        summary.remainingSlots(template: template)
    }

    var pickerTitle: String {
        summary.isImporting ? "Importing media..." : "Add Photos or Clips"
    }

    var selectedCountTitle: String {
        "Selected \(summary.selectedCount)/\(template.mediaRange)"
    }

    var selectionMessage: String {
        MomentsMediaRules.selectionMessage(
            MomentsMediaRules.availability(template: template, selectedCount: summary.selectedCount),
            tooFewMessage: { "Add \($0) more synced \(Self.mediaAssetLabel($0))." },
            tooManyMessage: { "Remove \($0) synced \(Self.mediaAssetLabel($0))." }
        )
    }

    var syncedMediaAssets: [MomentMediaAsset] {
        summary.syncedMediaAssets.sorted { $0.sortOrder < $1.sortOrder }
    }

    private static func mediaAssetLabel(_ count: Int) -> String {
        count == 1 ? "media asset" : "media assets"
    }
}

struct MomentsCreateStoryPresentation: Equatable {
    var summary: MomentsCreateStorySummary
    var canDraftStory = false
    var availabilityMessage: String?

    var draftButtonTitle: String {
        summary.isDrafting ? "Drafting story..." : "Ask Avi for story draft"
    }

    var emptyMessage: String {
        canDraftStory
            ? "Avi can draft the first story from the synced media."
            : "Add enough synced media before generating a story draft."
    }

    var savedScenes: [MomentStoryScene] {
        summary.savedScenes.sorted { $0.sceneIndex < $1.sceneIndex }
    }
}

struct MomentsCreatePreviewPresentation: Equatable {
    var summary: MomentsCreatePreviewSummary
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var availabilityMessage: String?
    var refreshAvailabilityMessage: String?

    var usageTitle: String? {
        summary.activeProject.map(MomentsProjectFormatting.previewUsage)
    }

    var previewArtifactMessage: String? {
        guard let latestPreview = summary.latestPreview else {
            return nil
        }
        return latestPreview.hasWatermark == true
            ? "Includes a subtle Moments AV mark."
            : "Preview artifact is available."
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? "Refreshing preview status..." : "Refresh preview status"
    }

    var generateButtonTitle: String {
        summary.isGenerating ? "Generating preview..." : "Generate preview"
    }

    var emptyMessage: String {
        canGeneratePreview
            ? "Story is ready. Generate a preview to review the result."
            : "Generate a story draft before creating a preview."
    }

    var showsEmptyState: Bool {
        summary.latestPreview == nil && summary.latestPreviewJob == nil
    }
}

struct MomentsCreateFinalRenderPresentation: Equatable {
    var summary: MomentsCreateFinalRenderSummary
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
    var availabilityMessage: String?
    var refreshAvailabilityMessage: String?

    var creditTitle: String {
        "\(summary.creditCost) \(summary.creditCost == 1 ? "credit" : "credits")"
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? "Refreshing final status..." : "Refresh final status"
    }

    var generateButtonTitle: String {
        summary.isGenerating ? "Rendering final..." : "Render final"
    }

    var emptyMessage: String {
        canGenerateFinalRender
            ? "Preview is ready. Render the final export when approved."
            : "Generate a preview before rendering the final export."
    }

    var showsEmptyState: Bool {
        summary.finalExport == nil && summary.latestFinalJob == nil
    }
}

struct MomentsCreateWorkspaceSummary: Equatable {
    var mediaCount = 0
    var sceneCount = 0
    var renderJobCount = 0
    var hasPreviewArtifact = false
    var hasFinalExport = false

    var mediaDetail: String {
        "\(mediaCount) synced"
    }

    var storyDetail: String {
        Self.countTitle(sceneCount, singular: "scene", plural: "scenes")
    }

    var previewDetail: String {
        hasPreviewArtifact ? "Ready" : Self.countTitle(renderJobCount, singular: "render job", plural: "render jobs")
    }

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

    private static func countTitle(_ count: Int, singular: String, plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
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
