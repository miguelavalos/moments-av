import AVSettingsFoundation
import SwiftUI

struct MomentsCreatePreviewCard: View {
    let summary: MomentsCreatePreviewSummary
    let canGeneratePreview: Bool
    let canRefreshPreviewStatus: Bool
    let availabilityMessage: String?
    let refreshAvailabilityMessage: String?
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void

    var body: some View {
        AVSettingsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Preview")
                    .font(.headline)
                Text("Generate a preview after the story is ready, then review status before committing the final export.")
                    .foregroundStyle(.secondary)

                if let activeProject = summary.activeProject {
                    Text(MomentsProjectFormatting.previewUsage(activeProject))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let latestPreview = summary.latestPreview {
                    Label("Preview ready", systemImage: "play.rectangle")
                    Text(latestPreview.hasWatermark == true ? "Includes a subtle Moments AV mark." : "Preview artifact is available.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let latestPreviewJob = summary.latestPreviewJob {
                    MomentsCreateRenderJobStatusRow(renderJob: latestPreviewJob)

                    Button(action: refreshPreviewStatus) {
                        Text(summary.isRefreshingStatus ? "Refreshing preview status..." : "Refresh preview status")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canRefreshPreviewStatus)

                    if let refreshAvailabilityMessage {
                        MomentsCreateAvailabilityMessage(message: refreshAvailabilityMessage)
                    }
                }

                if summary.latestPreview == nil && summary.latestPreviewJob == nil {
                    MomentsCreateEmptySectionRow(
                        systemImage: "play.rectangle",
                        message: canGeneratePreview
                            ? "Story is ready. Generate a preview to review the result."
                            : "Generate a story draft before creating a preview."
                    )
                }

                Button(action: generatePreview) {
                    Text(summary.isGenerating ? "Generating preview..." : "Generate preview")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canGeneratePreview || summary.isGenerating)

                if let availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                if let previewStatusMessage = summary.statusMessage {
                    Text(previewStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct MomentsCreateFinalExportCard: View {
    let summary: MomentsCreateFinalRenderSummary
    let canGenerateFinalRender: Bool
    let canRefreshFinalRenderStatus: Bool
    let availabilityMessage: String?
    let refreshAvailabilityMessage: String?
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void

    var body: some View {
        AVSettingsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Final export")
                    .font(.headline)
                Text("Final render commits credits after a usable export is delivered.")
                    .foregroundStyle(.secondary)

                Text("\(summary.creditCost) credits")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let finalExport = summary.finalExport {
                    Label("Export ready", systemImage: "square.and.arrow.up")
                    Text(finalExport.r2Key)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                if let latestFinalJob = summary.latestFinalJob {
                    MomentsCreateRenderJobStatusRow(renderJob: latestFinalJob)

                    Button(action: refreshFinalRenderStatus) {
                        Text(summary.isRefreshingStatus ? "Refreshing final status..." : "Refresh final status")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canRefreshFinalRenderStatus)

                    if let refreshAvailabilityMessage {
                        MomentsCreateAvailabilityMessage(message: refreshAvailabilityMessage)
                    }
                }

                if summary.finalExport == nil && summary.latestFinalJob == nil {
                    MomentsCreateEmptySectionRow(
                        systemImage: "square.and.arrow.up",
                        message: canGenerateFinalRender
                            ? "Preview is ready. Render the final export when approved."
                            : "Generate a preview before rendering the final export."
                    )
                }

                Button(action: generateFinalRender) {
                    Text(summary.isGenerating ? "Rendering final..." : "Render final")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canGenerateFinalRender || summary.isGenerating)

                if let availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                if let finalRenderStatusMessage = summary.statusMessage {
                    Text(finalRenderStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
