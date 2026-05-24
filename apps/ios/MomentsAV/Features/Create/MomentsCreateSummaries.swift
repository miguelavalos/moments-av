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

struct MomentsCreateDraftSetupPresentation: Equatable {
    var templateSummary: MomentsCreateTemplateSummaryPresentation
    var isDraftLocked = false
    var isCreatingDraft = false
    var canCreateDraft = false
    var availabilityMessage: String?
    var createdProjectId: String?
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
        createdProjectId != nil
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
    var createdProjectId: String
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
            tooFewMessage: { "Add \($0) more synced media assets." },
            tooManyMessage: { "Remove \($0) synced media assets." }
        )
    }

    var syncedMediaAssets: [MomentMediaAsset] {
        summary.syncedMediaAssets.sorted { $0.sortOrder < $1.sortOrder }
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
