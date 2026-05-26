import Foundation

struct MomentsCreateMediaPresentation: Equatable {
    var activeProjectId: String?
    var template: MomentTemplate
    var summary: MomentsCreateMediaSummary
    var canAddMedia = false
    var availabilityMessage: String?

    var remainingSlots: Int {
        summary.remainingSlots(template: template)
    }

    var pickerTitle: String {
        summary.isImporting ? "Adding media..." : "Add Photos or Clips"
    }

    var selectedCountTitle: String {
        "Selected \(summary.selectedCount)/\(template.mediaRange)"
    }

    var selectionMessage: String {
        MomentsMediaRules.selectionMessage(
            MomentsMediaRules.availability(template: template, selectedCount: summary.selectedCount),
            readyMessage: "Ready for story.",
            tooFewMessage: { "Add \($0) more \(Self.mediaAssetLabel($0))." },
            tooManyMessage: { "Remove \($0) \(Self.mediaAssetLabel($0))." }
        )
    }

    var syncedMediaAssets: [MomentMediaAsset] {
        summary.syncedMediaAssets.sorted { $0.sortOrder < $1.sortOrder }
    }

    private static func mediaAssetLabel(_ count: Int) -> String {
        count == 1 ? "photo or clip" : "photos or clips"
    }
}

struct MomentsCreateStoryPresentation: Equatable {
    var summary: MomentsCreateStorySummary
    var canDraftStory = false
    var availabilityMessage: String?

    var draftButtonTitle: String {
        summary.isDrafting ? "Preparing story..." : "Prepare story"
    }

    var emptyMessage: String {
        canDraftStory
            ? "Avi can prepare a story plan from your photos and clips."
            : "Add enough photos or clips before preparing the story."
    }

    var savedScenes: [MomentStoryScene] {
        summary.savedScenes.sorted { $0.sceneIndex < $1.sceneIndex }
    }
}
