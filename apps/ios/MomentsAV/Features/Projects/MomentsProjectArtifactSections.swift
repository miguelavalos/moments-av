import SwiftUI

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
        MomentsProjectDiagnosticCard {
            HStack(alignment: .center, spacing: 8) {
                MomentsProjectDiagnosticStatusBadge(status: artifact.status)

                Text(MomentsProjectStatusRules.displayKind(artifact.kind))
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
                    value: artifact.hasWatermark == true ? "Included" : "None"
                )
                MomentsProjectDiagnosticMetadataItem(
                    title: "Expires",
                    value: MomentsDateFormatting.formattedDate(milliseconds: artifact.expiresAt)
                )
            }

            MomentsProjectDiagnosticIdentifierRow(
                title: "Storage key",
                value: artifact.r2Key,
                lineLimit: 3
            )
        }
    }
}

struct MomentsProjectRenderJobRow: View {
    let renderJob: MomentRenderJob

    var body: some View {
        MomentsProjectDiagnosticCard {
            HStack(alignment: .center, spacing: 8) {
                MomentsProjectDiagnosticStatusBadge(status: renderJob.status)

                Text(MomentsProjectStatusRules.displayKind(renderJob.kind))
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
                    value: renderJob.provider ?? "Unknown"
                )
                MomentsProjectDiagnosticMetadataItem(
                    title: "Model",
                    value: renderJob.model ?? "Unknown"
                )
                MomentsProjectDiagnosticMetadataItem(
                    title: "Created",
                    value: MomentsDateFormatting.formattedDate(milliseconds: renderJob.createdAt)
                )
                MomentsProjectDiagnosticMetadataItem(
                    title: "Updated",
                    value: MomentsDateFormatting.formattedDate(milliseconds: renderJob.updatedAt)
                )
            }

            if let errorMessage = renderJob.errorMessage, !errorMessage.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    Text(renderJob.errorCode ?? "Render error")
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

            VStack(alignment: .leading, spacing: 6) {
                MomentsProjectDiagnosticIdentifierRow(title: "Job ID", value: renderJob.id)
                MomentsProjectDiagnosticIdentifierRow(title: "Workflow", value: renderJob.workflowRunId)
                MomentsProjectDiagnosticIdentifierRow(title: "Provider request", value: renderJob.providerRequestId)
            }
        }
    }
}
