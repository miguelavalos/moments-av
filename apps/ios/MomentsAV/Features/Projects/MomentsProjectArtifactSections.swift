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
