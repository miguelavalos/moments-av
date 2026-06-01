import AVAppShellFoundation
import SwiftUI

struct MomentsCreateFinalExportCard: View {
    let presentation: MomentsCreateFinalRenderPresentation
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void
    let retryFinalVideoDownload: () -> Void
    let finishFinalVideoToGallery: () -> Void
    let createAnotherFinalVideoVersion: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 14) {
                AVAppShellContentHeader(
                    title: "Final video",
                    detail: "Create the finished video file. This uses 1 credit."
                )

                Text(presentation.creditTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let finalExport = presentation.summary.finalExport {
                    MomentsCreateArtifactStatusCard(
                        title: "Export ready",
                        systemImage: "square.and.arrow.up",
                        artifact: finalExport,
                        detail: nil
                    )
                }

                if presentation.summary.pendingGalleryVideo != nil {
                    MomentsCreateEmptySectionRow(
                        systemImage: "rectangle.stack.badge.play.fill",
                        message: "The final video is saved on this device. Choose where this Moment goes next."
                    )

                    AVAppShellPrimaryButton(
                        "Finish and move to Gallery",
                        systemImage: "checkmark.circle.fill",
                        action: finishFinalVideoToGallery
                    )

                    Button(action: createAnotherFinalVideoVersion) {
                        Label("Create another version", systemImage: "plus.rectangle.on.rectangle")
                    }
                    .buttonStyle(MomentsCreateNeutralInlineButtonStyle())
                } else if presentation.summary.canRetryFinalVideoDownload {
                    AVAppShellPrimaryButton(
                        "Retry final video download",
                        systemImage: "arrow.down.circle.fill",
                        action: retryFinalVideoDownload
                    )
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

                AVAppShellPrimaryButton(
                    presentation.generateButtonTitle,
                    systemImage: "square.and.arrow.up.fill",
                    isDisabled: !presentation.canGenerateFinalRender || presentation.summary.isGenerating,
                    action: generateFinalRender
                )

                if presentation.showsEmptyState, let availabilityMessage = presentation.availabilityMessage {
                    AVAppShellInlineMessage(message: availabilityMessage)
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
