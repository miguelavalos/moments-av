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

struct MomentsCreateMediaRow: View {
    let media: MomentsSelectedMedia
    let remove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: media.kind == "video" ? "video" : "photo")
            VStack(alignment: .leading, spacing: 3) {
                Text(media.originalFilename)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text("\(media.kind.capitalized) · \(media.displaySize)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(role: .destructive, action: remove) {
                Image(systemName: "minus.circle")
            }
        }
    }
}

struct MomentsCreateSyncedMediaRow: View {
    let media: MomentMediaAsset

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: media.kind == "video" ? "video" : "photo")
                .foregroundStyle(.secondary)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(MomentsProjectStatusRules.displayKind(media.kind)) \(Int(media.sortOrder) + 1)")
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(MomentsProjectFormatting.mediaAssetDetail(media))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(MomentsTheme.brandPalette.accent)
        }
    }
}

struct MomentsCreateEmptySectionRow: View {
    let systemImage: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 18)

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.vertical, 2)
    }
}

struct MomentsCreateStorySceneRow: View {
    let index: Int
    let caption: String
    let narration: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Scene \(index + 1)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(caption)
                .font(.subheadline.weight(.medium))
            Text(narration)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct MomentsCreateRenderJobStatusRow: View {
    let renderJob: MomentRenderJob

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(MomentsProjectStatusRules.displayTitle(for: renderJob.status))
                .font(.subheadline.weight(.medium))

            if let errorMessage = renderJob.errorMessage, renderJob.status == "failed" {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if let model = renderJob.model {
                Text(model)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
