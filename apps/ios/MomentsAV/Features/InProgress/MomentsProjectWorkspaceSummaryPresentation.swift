import AVAppShellFoundation
import Foundation

struct MomentsProjectWorkspaceSummaryPresentation: Equatable {
    let tiles: [MomentsInProgressSummaryTilePresentation]

    var metrics: [AVAppShellMetric] {
        tiles.map {
            AVAppShellMetric(
                id: $0.id,
                title: $0.title,
                value: $0.value,
                systemImage: $0.systemImage
            )
        }
    }

    init(workspace: MomentProjectWorkspace) {
        let latestPreview = workspace.latestArtifact(kind: "preview")
        let finalExport = workspace.latestArtifact(kind: "final_export")
        let latestRenderJob = workspace.latestRenderJob()

        tiles = [
            MomentsInProgressSummaryTilePresentation(
                title: L10n.string("project.summary.status"),
                value: MomentsProjectStatusRules.displayTitle(for: workspace.project.status),
                systemImage: "circle.dashed"
            ),
            MomentsInProgressSummaryTilePresentation(
                title: L10n.string("project.kind.storyReview"),
                value: Self.summaryValue(for: latestPreview),
                systemImage: "text.bubble"
            ),
            MomentsInProgressSummaryTilePresentation(
                title: L10n.string("project.summary.final"),
                value: Self.summaryValue(for: finalExport),
                systemImage: "square.and.arrow.up"
            ),
            MomentsInProgressSummaryTilePresentation(
                title: L10n.string("project.summary.latestJob"),
                value: Self.latestJobValue(latestRenderJob),
                systemImage: "gearshape.2"
            )
        ]
    }

    private static func latestJobValue(_ latestRenderJob: MomentRenderJob?) -> String {
        guard let latestRenderJob else { return L10n.string("project.progress.notStarted") }
        return "\(MomentsProjectStatusRules.displayKind(latestRenderJob.kind)) · \(MomentsProjectStatusRules.displayTitle(for: latestRenderJob.status))"
    }

    private static func summaryValue(for artifact: MomentArtifact?) -> String {
        guard let artifact else { return L10n.string("project.progress.notReady") }
        return MomentsProjectStatusRules.displayTitle(for: artifact.status)
    }
}

struct MomentsInProgressSummaryTilePresentation: Identifiable, Equatable {
    let title: String
    let value: String
    let systemImage: String

    var id: String { title }
}
