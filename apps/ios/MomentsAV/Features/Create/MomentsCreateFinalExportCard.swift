import AVAppShellFoundation
import SwiftUI

struct MomentsCreateFinalExportCard: View {
    let presentation: MomentsCreateFinalRenderPresentation
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void

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
