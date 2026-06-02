import Foundation

struct MomentsCreateMediaPresentation: Equatable {
    var activeMomentId: String?
    var template: MomentTemplate
    var summary: MomentsCreateMediaSummary
    var canAddMedia = false
    var availabilityMessage: String?

    var remainingSlots: Int {
        summary.remainingSlots(template: template)
    }

    var pickerTitle: String {
        summary.isImporting ? L10n.string("create.media.action.adding") : L10n.string("create.media.action.add")
    }

    var selectedCountTitle: String {
        L10n.string("create.media.selectedCount", summary.selectedCount)
    }

    var selectionMessage: String {
        MomentsMediaRules.selectionMessage(
            MomentsMediaRules.availability(template: template, selectedCount: summary.selectedCount),
            readyMessage: "",
            tooFewMessage: { L10n.string("create.media.selection.tooFew", $0, Self.mediaAssetLabel($0)) },
            tooManyMessage: { _ in L10n.string("create.media.selection.tooMany") }
        )
    }

    var syncedMediaAssets: [MomentMediaAsset] {
        summary.syncedMediaAssets.sorted { $0.sortOrder < $1.sortOrder }
    }

    private static func mediaAssetLabel(_ count: Int) -> String {
        count == 1 ? L10n.string("create.media.asset.singular") : L10n.string("create.media.asset.plural")
    }
}

struct MomentsCreateStoryPresentation: Equatable {
    var summary: MomentsCreateStorySummary
    var balance: MomentsCreditBalance
    var canPlanStory = false
    var isBuyingReviewBundle = false
    var availabilityMessage: String?

    var planButtonTitle: String {
        summary.isPlanning ? L10n.string("create.story.action.preparing") : L10n.string("create.story.action.prepare")
    }

    var emptyMessage: String {
        canPlanStory
            ? L10n.string("create.story.empty.ready")
            : L10n.string("create.story.empty.needsMedia")
    }

    var savedScenes: [MomentStoryScene] {
        summary.savedScenes.sorted { $0.sceneIndex < $1.sceneIndex }
    }

    var reviewBundleButtonTitle: String {
        isBuyingReviewBundle
            ? L10n.string("create.reviewBundle.action.adding")
            : L10n.string(
                "create.reviewBundle.action.add",
                balance.reviewBundleReviewCount,
                MomentsCreditCopy.countTitle(balance.reviewBundleCreditCost)
            )
    }

    var canBuyReviewBundle: Bool {
        balance.canBuyReviewBundle && !isBuyingReviewBundle
    }
}
