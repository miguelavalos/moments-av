import Foundation

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
            ? "Story review is ready for your final check."
            : "Story review is available."
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? "Refreshing story review..." : "Refresh story review"
    }

    var generateButtonTitle: String {
        summary.isGenerating ? "Reviewing story..." : "Review story"
    }

    var emptyMessage: String {
        canGeneratePreview
            ? "Story is ready. Review it before creating the final video."
            : "Prepare the story before reviewing it."
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
        summary.isRefreshingStatus ? "Refreshing final video..." : "Refresh final video"
    }

    var generateButtonTitle: String {
        summary.isGenerating ? "Creating final video..." : "Create final video"
    }

    var emptyMessage: String {
        canGenerateFinalRender
            ? "The story plan is ready. Create the final video when you are ready."
            : "Prepare the story before creating the final video."
    }

    var showsEmptyState: Bool {
        summary.finalExport == nil && summary.latestFinalJob == nil
    }
}
