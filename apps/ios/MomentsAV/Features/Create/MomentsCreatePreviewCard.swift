import AVAppShellFoundation
import SwiftUI

struct MomentsCreatePreviewCard: View {
    let presentation: MomentsCreatePreviewPresentation
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 14) {
                AVAppShellContentHeader(
                    title: "Preview",
                    detail: "Generate a preview after the story is ready, then review status before committing the final export."
                )

                if let usageTitle = presentation.usageTitle {
                    Text(usageTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let latestPreview = presentation.summary.latestPreview {
                    MomentsCreateArtifactStatusCard(
                        title: "Preview ready",
                        systemImage: "play.rectangle",
                        artifact: latestPreview,
                        detail: presentation.previewArtifactMessage
                    )
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

                AVAppShellPrimaryButton(
                    presentation.generateButtonTitle,
                    systemImage: "play.rectangle.fill",
                    isDisabled: !presentation.canGeneratePreview || presentation.summary.isGenerating,
                    action: generatePreview
                )

                if presentation.showsEmptyState, let availabilityMessage = presentation.availabilityMessage {
                    AVAppShellInlineMessage(message: availabilityMessage)
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
