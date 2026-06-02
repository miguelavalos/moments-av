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
    var canPlanStory = false
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
}

struct MomentsCreateAviCutPresentation: Equatable {
    var mediaSummary: MomentsCreateMediaSummary
    var storySummary: MomentsCreateStorySummary
    var template: MomentTemplate
    var canImproveWithAvi = false
    var availabilityMessage: String?

    var statusMessage: String {
        if storySummary.hasScenes {
            return L10n.string("create.aviCut.status.ready")
        }
        if storySummary.isPlanning {
            return storySummary.statusMessage ?? L10n.string("create.aviCut.status.improving")
        }
        if mediaCount > 0, canImproveWithAvi {
            return L10n.string("create.aviCut.status.readyToPrepare")
        }
        if mediaCount > 0 {
            return availabilityMessage ?? L10n.string("create.aviCut.status.unavailable")
        }
        return L10n.string("create.aviCut.status.needsMedia")
    }

    var modeTitle: String {
        if storySummary.isPlanning {
            return L10n.string("create.aviCut.pill.working")
        }
        if storySummary.hasScenes {
            return L10n.string("create.aviCut.pill.aviChoice")
        }
        if mediaCount > 0 {
            return L10n.string("create.aviCut.pill.ready")
        }
        return L10n.string("create.aviCut.pill.noMedia")
    }

    var mediaCountTitle: String {
        L10n.string(
            mediaCount == 1 ? "create.workflowContent.itemCount" : "create.workflowContent.itemsCount",
            mediaCount
        )
    }

    var durationTitle: String {
        template.duration
    }

    var primaryActionTitle: String {
        storySummary.hasScenes
            ? L10n.string("create.aviCut.action.improve")
            : L10n.string("create.aviCut.action.prepare")
    }

    var primaryActionIconName: String {
        storySummary.hasScenes ? "sparkles" : "wand.and.stars"
    }

    var editActionTitle: String {
        L10n.string("create.aviCut.action.edit")
    }

    var iconName: String {
        if storySummary.hasScenes { return "rectangle.stack.fill" }
        if storySummary.isPlanning { return "sparkles" }
        return "wand.and.stars"
    }

    var canRunPrimaryAction: Bool {
        !storySummary.isPlanning
            && mediaCount > 0
            && canImproveWithAvi
    }

    var canShowImproveAction: Bool {
        storySummary.hasScenes && canRunPrimaryAction
    }

    var visibleScenes: [MomentsCreateStoryReviewScene] {
        Array(storySummary.reviewScenes.prefix(2))
    }

    var remainingSceneCount: Int {
        max(storySummary.reviewScenes.count - visibleScenes.count, 0)
    }

    var remainingSceneTitle: String? {
        guard remainingSceneCount > 0 else { return nil }
        return L10n.string(
            remainingSceneCount == 1 ? "create.aviCut.moreScene" : "create.aviCut.moreScenes",
            remainingSceneCount
        )
    }

    private var mediaCount: Int {
        mediaSummary.reviewCount
    }
}
