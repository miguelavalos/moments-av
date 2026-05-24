import SwiftUI

struct MomentsProjectRenderJobsSection: View {
    let renderJobs: [MomentRenderJob]

    private var presentations: [MomentsProjectRenderJobPresentation] {
        MomentsProjectRenderJobPresentation.sorted(renderJobs)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Render jobs")
                .font(.subheadline.weight(.semibold))

            if presentations.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: "gearshape.2",
                    message: "Preview and final render jobs will appear here."
                )
            } else {
                ForEach(presentations) { presentation in
                    MomentsProjectRenderJobRow(presentation: presentation)
                }
            }
        }
    }
}

struct MomentsProjectPreviewArtifactSection: View {
    let artifacts: [MomentArtifact]

    private var preview: MomentsProjectArtifactPresentation? {
        MomentsProjectArtifactPresentation.preview(in: artifacts)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Preview")
                .font(.subheadline.weight(.semibold))

            if let preview {
                MomentsProjectArtifactDetail(presentation: preview)
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

    private var finalExport: MomentsProjectArtifactPresentation? {
        MomentsProjectArtifactPresentation.finalExport(in: artifacts)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Final export")
                .font(.subheadline.weight(.semibold))

            if let finalExport {
                MomentsProjectArtifactDetail(presentation: finalExport)
            } else {
                MomentsProjectEmptySectionRow(
                    systemImage: "square.and.arrow.up",
                    message: "Render the final export after approving a preview."
                )
            }
        }
    }
}

struct MomentsProjectArtifactRow: View {
    let title: String
    let artifact: MomentArtifact

    private var presentation: MomentsProjectArtifactPresentation {
        MomentsProjectArtifactPresentation(artifact: artifact)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            MomentsProjectArtifactDetail(presentation: presentation)
        }
    }
}

private struct MomentsProjectArtifactDetail: View {
    let presentation: MomentsProjectArtifactPresentation

    var body: some View {
        MomentsProjectDiagnosticCard {
            HStack(alignment: .center, spacing: 8) {
                MomentsProjectDiagnosticStatusBadge(status: presentation.status)

                Text(presentation.kindTitle)
                    .font(.caption.weight(.semibold))

                Spacer(minLength: 0)
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                alignment: .leading,
                spacing: 8
            ) {
                MomentsProjectDiagnosticMetadataItem(
                    title: "Watermark",
                    value: presentation.watermarkTitle
                )
                MomentsProjectDiagnosticMetadataItem(
                    title: "Expires",
                    value: presentation.expiresAtTitle
                )
            }

            MomentsProjectDiagnosticIdentifierRow(
                title: "Storage key",
                value: presentation.storageKey,
                lineLimit: 3
            )
        }
    }
}

struct MomentsProjectRenderJobRow: View {
    let presentation: MomentsProjectRenderJobPresentation

    var body: some View {
        MomentsProjectDiagnosticCard {
            HStack(alignment: .center, spacing: 8) {
                MomentsProjectDiagnosticStatusBadge(status: presentation.status)

                Text(presentation.kindTitle)
                    .font(.caption.weight(.semibold))

                Spacer(minLength: 0)
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                alignment: .leading,
                spacing: 8
            ) {
                MomentsProjectDiagnosticMetadataItem(
                    title: "Provider",
                    value: presentation.providerTitle
                )
                MomentsProjectDiagnosticMetadataItem(
                    title: "Model",
                    value: presentation.modelTitle
                )
                MomentsProjectDiagnosticMetadataItem(
                    title: "Created",
                    value: presentation.createdAtTitle
                )
                MomentsProjectDiagnosticMetadataItem(
                    title: "Updated",
                    value: presentation.updatedAtTitle
                )
            }

            MomentsProjectRenderJobErrorBlock(
                errorCode: presentation.errorCode,
                errorMessage: presentation.errorMessage
            )

            VStack(alignment: .leading, spacing: 6) {
                MomentsProjectDiagnosticIdentifierRow(title: "Job ID", value: presentation.id)
                MomentsProjectDiagnosticIdentifierRow(title: "Workflow", value: presentation.workflowRunId)
                MomentsProjectDiagnosticIdentifierRow(title: "Provider request", value: presentation.providerRequestId)
            }
        }
    }
}

private struct MomentsProjectRenderJobErrorBlock: View {
    let errorCode: String?
    let errorMessage: String?

    var body: some View {
        if let errorMessage, !errorMessage.isEmpty {
            VStack(alignment: .leading, spacing: 3) {
                Text(errorCode ?? "Render error")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.red)
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(8)
            .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}
