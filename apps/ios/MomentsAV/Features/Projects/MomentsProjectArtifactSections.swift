import SwiftUI

struct MomentsProjectRenderJobsSection: View {
    let renderJobs: [MomentRenderJob]

    private var presentation: MomentsProjectRenderJobsSectionPresentation {
        MomentsProjectRenderJobsSectionPresentation(renderJobs: renderJobs)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(presentation.title)
                .font(.subheadline.weight(.semibold))

            if presentation.jobs.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: presentation.emptySystemImage,
                    message: presentation.emptyMessage
                )
            } else {
                ForEach(presentation.jobs) { job in
                    MomentsProjectRenderJobRow(presentation: job)
                }
            }
        }
    }
}

struct MomentsProjectPreviewArtifactSection: View {
    let artifacts: [MomentArtifact]

    private var presentation: MomentsProjectArtifactSectionPresentation {
        MomentsProjectArtifactSectionPresentation.preview(artifacts: artifacts)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(presentation.title)
                .font(.subheadline.weight(.semibold))

            if let artifact = presentation.artifact {
                MomentsProjectArtifactDetail(presentation: artifact)
            } else {
                MomentsProjectEmptySectionRow(
                    systemImage: presentation.emptySystemImage,
                    message: presentation.emptyMessage
                )
            }
        }
    }
}

struct MomentsProjectFinalExportSection: View {
    let artifacts: [MomentArtifact]

    private var presentation: MomentsProjectArtifactSectionPresentation {
        MomentsProjectArtifactSectionPresentation.finalExport(artifacts: artifacts)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(presentation.title)
                .font(.subheadline.weight(.semibold))

            if let artifact = presentation.artifact {
                MomentsProjectArtifactDetail(presentation: artifact)
            } else {
                MomentsProjectEmptySectionRow(
                    systemImage: presentation.emptySystemImage,
                    message: presentation.emptyMessage
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
