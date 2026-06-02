import Foundation

struct MomentsCreatePreviewPresentation: Equatable {
    var summary: MomentsCreatePreviewSummary
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var availabilityMessage: String?
    var refreshAvailabilityMessage: String?

    var usageTitle: String? {
        summary.activeProject.map(MomentsMomentFormatting.previewUsage)
    }

    var previewArtifactMessage: String? {
        guard let latestPreview = summary.latestPreview else {
            return nil
        }
        return latestPreview.hasWatermark == true
            ? L10n.string("create.preview.artifact.readyFinalCheck")
            : L10n.string("create.preview.status.available")
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? L10n.string("create.preview.action.refreshing") : L10n.string("create.preview.action.refresh")
    }

    var generateButtonTitle: String {
        summary.isGenerating ? L10n.string("create.preview.action.reviewing") : L10n.string("create.preview.action.review")
    }

    var emptyMessage: String {
        canGeneratePreview
            ? L10n.string("create.preview.empty.ready")
            : L10n.string("create.preview.empty.prepareStory")
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
        MomentsCreditCopy.countTitle(summary.creditCost)
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? L10n.string("create.final.action.refreshing") : L10n.string("create.final.action.refresh")
    }

    var generateButtonTitle: String {
        summary.isGenerating ? L10n.string("create.final.action.creating") : L10n.string("create.final.action.create")
    }

    var emptyMessage: String {
        canGenerateFinalRender
            ? L10n.string("create.final.empty.ready")
            : L10n.string("create.final.empty.prepareStory")
    }

    var showsEmptyState: Bool {
        summary.finalExport == nil && summary.latestFinalJob == nil
    }
}
