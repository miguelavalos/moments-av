import SwiftUI

struct MomentsCreateAvailabilityMessage: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "info.circle")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct MomentsCreateWorkspaceProgress: View {
    let summary: MomentsCreateWorkspaceSummary
    let minimumMediaCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workspace progress")
                .font(.subheadline.weight(.semibold))
            MomentsCreateProgressRow(
                title: "Media",
                detail: summary.mediaDetail,
                isComplete: summary.mediaCount >= minimumMediaCount,
                systemImage: "photo.on.rectangle"
            )
            MomentsCreateProgressRow(
                title: "Story",
                detail: summary.storyDetail,
                isComplete: summary.sceneCount > 0,
                systemImage: "text.bubble"
            )
            MomentsCreateProgressRow(
                title: "Preview",
                detail: summary.previewDetail,
                isComplete: summary.hasPreviewArtifact,
                systemImage: "play.rectangle"
            )
            MomentsCreateProgressRow(
                title: "Final export",
                detail: summary.hasFinalExport ? "Ready" : "Not rendered",
                isComplete: summary.hasFinalExport,
                systemImage: "square.and.arrow.up"
            )
        }
    }
}

struct MomentsCreateProgressRow: View {
    let title: String
    let detail: String
    let isComplete: Bool
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : systemImage)
                .foregroundStyle(isComplete ? MomentsTheme.brandPalette.accent : .secondary)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}
