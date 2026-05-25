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
        MomentsCreditCopy.countTitle(summary.creditCost)
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
