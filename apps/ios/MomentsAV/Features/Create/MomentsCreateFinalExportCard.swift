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
                    title: L10n.string("moment.artifact.final.title"),
                    detail: L10n.string("create.final.detail")
                )

                Text(presentation.creditTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let finalExport = presentation.summary.finalExport {
                    MomentsCreateArtifactStatusCard(
                        title: L10n.string("create.final.ready"),
                        systemImage: "square.and.arrow.up",
                        artifact: finalExport,
                        detail: nil
                    )
                }

                if presentation.summary.pendingGalleryVideo != nil {
                    MomentsCreateEmptySectionRow(
                        systemImage: "rectangle.stack.badge.play.fill",
                        message: L10n.string("create.final.saved")
                    )

                    AVAppShellPrimaryButton(
                        L10n.string("create.final.finishGallery"),
                        systemImage: "checkmark.circle.fill",
                        action: finishFinalVideoToGallery
                    )

                    Button(action: createAnotherFinalVideoVersion) {
                        Label(L10n.string("create.final.createAnother"), systemImage: "plus.rectangle.on.rectangle")
                    }
                    .buttonStyle(MomentsCreateNeutralInlineButtonStyle())
                } else if presentation.summary.canRetryFinalVideoDownload {
                    AVAppShellPrimaryButton(
                        L10n.string("create.final.retryDownload"),
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
