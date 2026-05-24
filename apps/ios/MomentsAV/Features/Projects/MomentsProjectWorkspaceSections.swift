import SwiftUI

struct MomentsProjectMediaSection: View {
    let mediaAssets: [MomentMediaAsset]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Media")
                .font(.subheadline.weight(.semibold))

            if mediaAssets.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: "photo.badge.plus",
                    message: "Add photos or clips from Create to unlock story drafting."
                )
            } else {
                ForEach(mediaAssets.sorted { $0.sortOrder < $1.sortOrder }) { media in
                    MomentsProjectMediaAssetRow(media: media)
                }
            }
        }
    }
}

struct MomentsProjectStorySection: View {
    let storyScenes: [MomentStoryScene]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Story")
                .font(.subheadline.weight(.semibold))

            if storyScenes.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: "text.bubble",
                    message: "Generate a story draft after the project has enough media."
                )
            } else {
                ForEach(storyScenes.sorted { $0.sceneIndex < $1.sceneIndex }) { scene in
                    MomentsProjectStorySceneRow(scene: scene)
                }
            }
        }
    }
}

struct MomentsProjectRenderJobsSection: View {
    let renderJobs: [MomentRenderJob]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Render jobs")
                .font(.subheadline.weight(.semibold))

            if renderJobs.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: "gearshape.2",
                    message: "Preview and final render jobs will appear here."
                )
            } else {
                ForEach(renderJobs.sorted { $0.updatedAt > $1.updatedAt }) { renderJob in
                    MomentsProjectRenderJobRow(renderJob: renderJob)
                }
            }
        }
    }
}

struct MomentsProjectPreviewArtifactSection: View {
    let artifacts: [MomentArtifact]

    private var preview: MomentArtifact? {
        artifacts.last { $0.kind == "preview" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Preview")
                .font(.subheadline.weight(.semibold))

            if let preview {
                MomentsProjectArtifactDetail(artifact: preview)
            } else {
                MomentsProjectEmptySectionRow(
                    systemImage: "play.rectangle",
                    message: "Generate a preview after the story draft is ready."
                )
            }
        }
    }
}

struct MomentsProjectFinalExportSection: View {
    let artifacts: [MomentArtifact]

    private var finalExport: MomentArtifact? {
        artifacts.last { $0.kind == "final_export" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Final export")
                .font(.subheadline.weight(.semibold))

            if let finalExport {
                MomentsProjectArtifactDetail(artifact: finalExport)
            } else {
                MomentsProjectEmptySectionRow(
                    systemImage: "square.and.arrow.up",
                    message: "Render the final export after approving a preview."
                )
            }
        }
    }
}

private struct MomentsProjectEmptySectionRow: View {
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

struct MomentsProjectArtifactRow: View {
    let title: String
    let artifact: MomentArtifact

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            MomentsProjectArtifactDetail(artifact: artifact)
        }
    }
}

private struct MomentsProjectArtifactDetail: View {
    let artifact: MomentArtifact

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                MomentsProjectArtifactStatusBadge(status: artifact.status)

                Text(MomentsProjectStatusRules.displayKind(artifact.kind))
                    .font(.caption.weight(.semibold))

                Spacer(minLength: 0)
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                alignment: .leading,
                spacing: 8
            ) {
                MomentsProjectArtifactMetadataItem(
                    title: "Watermark",
                    value: artifact.hasWatermark == true ? "Included" : "None"
                )
                MomentsProjectArtifactMetadataItem(
                    title: "Expires",
                    value: MomentsDateFormatting.formattedDate(milliseconds: artifact.expiresAt)
                )
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Storage key")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(artifact.r2Key)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct MomentsProjectArtifactStatusBadge: View {
    let status: String

    var body: some View {
        Text(MomentsProjectStatusRules.displayTitle(for: status))
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.14), in: Capsule())
            .foregroundStyle(statusColor)
    }

    private var statusColor: Color {
        switch status {
        case "available", "completed":
            .green
        case "failed", "error", "blocked":
            .red
        case "processing", "queued", "rendering":
            .orange
        default:
            .secondary
        }
    }
}

private struct MomentsProjectArtifactMetadataItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct MomentsProjectMediaAssetRow: View {
    let media: MomentMediaAsset

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: media.kind == "video" ? "video" : "photo")
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(MomentsProjectStatusRules.displayKind(media.kind)) \(Int(media.sortOrder) + 1)")
                    .font(.caption.weight(.semibold))
                Text(MomentsProjectFormatting.mediaAssetDetail(media))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

struct MomentsProjectStorySceneRow: View {
    let scene: MomentStoryScene

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Scene \(Int(scene.sceneIndex) + 1)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(scene.caption)
                .font(.caption)
        }
    }
}

struct MomentsProjectRenderJobRow: View {
    let renderJob: MomentRenderJob

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(MomentsProjectStatusRules.displayKind(renderJob.kind)) · \(MomentsProjectStatusRules.displayTitle(for: renderJob.status))")
                .font(.caption.weight(.semibold))
            if let model = renderJob.model {
                Text(model)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
