import Foundation

struct MomentsProjectWorkspaceSummaryPresentation: Equatable {
    let tiles: [MomentsProjectSummaryTilePresentation]

    init(workspace: MomentProjectWorkspace) {
        let latestPreview = workspace.latestArtifact(kind: "preview")
        let finalExport = workspace.latestArtifact(kind: "final_export")
        let latestRenderJob = workspace.latestRenderJob()

        tiles = [
            MomentsProjectSummaryTilePresentation(
                title: "Status",
                value: MomentsProjectStatusRules.displayTitle(for: workspace.project.status),
                systemImage: "circle.dashed"
            ),
            MomentsProjectSummaryTilePresentation(
                title: "Preview",
                value: Self.summaryValue(for: latestPreview),
                systemImage: "play.rectangle"
            ),
            MomentsProjectSummaryTilePresentation(
                title: "Final",
                value: Self.summaryValue(for: finalExport),
                systemImage: "square.and.arrow.up"
            ),
            MomentsProjectSummaryTilePresentation(
                title: "Latest job",
                value: Self.latestJobValue(latestRenderJob),
                systemImage: "gearshape.2"
            )
        ]
    }

    private static func latestJobValue(_ latestRenderJob: MomentRenderJob?) -> String {
        guard let latestRenderJob else { return "Not started" }
        return "\(MomentsProjectStatusRules.displayKind(latestRenderJob.kind)) · \(MomentsProjectStatusRules.displayTitle(for: latestRenderJob.status))"
    }

    private static func summaryValue(for artifact: MomentArtifact?) -> String {
        guard let artifact else { return "Not ready" }
        return MomentsProjectStatusRules.displayTitle(for: artifact.status)
    }
}

struct MomentsProjectSummaryTilePresentation: Identifiable, Equatable {
    let title: String
    let value: String
    let systemImage: String

    var id: String { title }
}

