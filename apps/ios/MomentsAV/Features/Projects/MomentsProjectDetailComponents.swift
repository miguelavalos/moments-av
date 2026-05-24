import SwiftUI

struct MomentsProjectWorkspaceSummary: View {
    let workspace: MomentProjectWorkspace

    private var latestPreview: MomentArtifact? {
        workspace.artifacts.last { $0.kind == "preview" }
    }

    private var finalExport: MomentArtifact? {
        workspace.artifacts.last { $0.kind == "final_export" }
    }

    private var latestRenderJob: MomentRenderJob? {
        workspace.renderJobs.sorted { $0.updatedAt < $1.updatedAt }.last
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            alignment: .leading,
            spacing: 8
        ) {
            MomentsProjectSummaryTile(
                title: "Status",
                value: MomentsProjectStatusRules.displayTitle(for: workspace.project.status),
                systemImage: "circle.dashed"
            )
            MomentsProjectSummaryTile(
                title: "Preview",
                value: summaryValue(for: latestPreview),
                systemImage: "play.rectangle"
            )
            MomentsProjectSummaryTile(
                title: "Final",
                value: summaryValue(for: finalExport),
                systemImage: "square.and.arrow.up"
            )
            MomentsProjectSummaryTile(
                title: "Latest job",
                value: latestJobValue,
                systemImage: "gearshape.2"
            )
        }
    }

    private var latestJobValue: String {
        guard let latestRenderJob else { return "Not started" }
        return "\(MomentsProjectStatusRules.displayKind(latestRenderJob.kind)) · \(MomentsProjectStatusRules.displayTitle(for: latestRenderJob.status))"
    }

    private func summaryValue(for artifact: MomentArtifact?) -> String {
        guard let artifact else { return "Not ready" }
        return MomentsProjectStatusRules.displayTitle(for: artifact.status)
    }
}

private struct MomentsProjectSummaryTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MomentsTheme.brandPalette.accent)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .topLeading)
        .padding(10)
        .background(MomentsTheme.brandPalette.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}
