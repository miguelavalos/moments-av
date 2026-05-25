import AVSettingsFoundation
import SwiftUI

struct MomentsCreatePreviewCard: View {
    let presentation: MomentsCreatePreviewPresentation
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void

    var body: some View {
        AVSettingsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Preview")
                    .font(.headline)
                Text("Generate a preview after the story is ready, then review status before committing the final export.")
                    .foregroundStyle(.secondary)

                if let usageTitle = presentation.usageTitle {
                    Text(usageTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if presentation.summary.latestPreview != nil {
                    Label("Preview ready", systemImage: "play.rectangle")
                    Text(presentation.previewArtifactMessage ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                MomentsCreateRefreshableRenderJobSection(
                    renderJob: presentation.summary.latestPreviewJob,
                    refreshButtonTitle: presentation.refreshButtonTitle,
                    canRefresh: presentation.canRefreshPreviewStatus,
                    refreshAvailabilityMessage: presentation.refreshAvailabilityMessage,
                    refreshStatus: refreshPreviewStatus
                )

                if presentation.showsEmptyState {
                    MomentsCreateEmptySectionRow(
                        systemImage: "play.rectangle",
                        message: presentation.emptyMessage
                    )
                }

                Button(action: generatePreview) {
                    Text(presentation.generateButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!presentation.canGeneratePreview || presentation.summary.isGenerating)

                if let availabilityMessage = presentation.availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                if let previewStatusMessage = presentation.summary.statusMessage {
                    Text(previewStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct MomentsCreateFinalExportCard: View {
    let presentation: MomentsCreateFinalRenderPresentation
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void

    var body: some View {
        AVSettingsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Final export")
                    .font(.headline)
                Text("Final render commits credits after a usable export is delivered.")
                    .foregroundStyle(.secondary)

                Text(presentation.creditTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let finalExport = presentation.summary.finalExport {
                    Label("Export ready", systemImage: "square.and.arrow.up")
                    Text(finalExport.r2Key)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                MomentsCreateRefreshableRenderJobSection(
                    renderJob: presentation.summary.latestFinalJob,
                    refreshButtonTitle: presentation.refreshButtonTitle,
                    canRefresh: presentation.canRefreshFinalRenderStatus,
                    refreshAvailabilityMessage: presentation.refreshAvailabilityMessage,
                    refreshStatus: refreshFinalRenderStatus
                )

                if presentation.showsEmptyState {
                    MomentsCreateEmptySectionRow(
                        systemImage: "square.and.arrow.up",
                        message: presentation.emptyMessage
                    )
                }

                Button(action: generateFinalRender) {
                    Text(presentation.generateButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!presentation.canGenerateFinalRender || presentation.summary.isGenerating)

                if let availabilityMessage = presentation.availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                if let finalRenderStatusMessage = presentation.summary.statusMessage {
                    Text(finalRenderStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct MomentsCreateRefreshableRenderJobSection: View {
    let renderJob: MomentRenderJob?
    let refreshButtonTitle: String
    let canRefresh: Bool
    let refreshAvailabilityMessage: String?
    let refreshStatus: () -> Void

    @ViewBuilder
    var body: some View {
        if let renderJob {
            MomentsCreateRenderJobStatusRow(renderJob: renderJob)

            Button(action: refreshStatus) {
                Text(refreshButtonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!canRefresh)

            if let refreshAvailabilityMessage {
                MomentsCreateAvailabilityMessage(message: refreshAvailabilityMessage)
            }
        }
    }
}
