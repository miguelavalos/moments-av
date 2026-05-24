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

                if let latestPreviewJob = presentation.summary.latestPreviewJob {
                    MomentsCreateRenderJobStatusRow(renderJob: latestPreviewJob)

                    Button(action: refreshPreviewStatus) {
                        Text(presentation.refreshButtonTitle)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!presentation.canRefreshPreviewStatus)

                    if let refreshAvailabilityMessage = presentation.refreshAvailabilityMessage {
                        MomentsCreateAvailabilityMessage(message: refreshAvailabilityMessage)
                    }
                }

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

                if let latestFinalJob = presentation.summary.latestFinalJob {
                    MomentsCreateRenderJobStatusRow(renderJob: latestFinalJob)

                    Button(action: refreshFinalRenderStatus) {
                        Text(presentation.refreshButtonTitle)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!presentation.canRefreshFinalRenderStatus)

                    if let refreshAvailabilityMessage = presentation.refreshAvailabilityMessage {
                        MomentsCreateAvailabilityMessage(message: refreshAvailabilityMessage)
                    }
                }

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
