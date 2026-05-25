import Foundation

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
