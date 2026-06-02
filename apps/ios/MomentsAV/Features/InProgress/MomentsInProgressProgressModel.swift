import Foundation

struct MomentsInProgressProgressModel {
    let phases: [MomentsInProgressProgressPhase]

    init(workspace: MomentProjectWorkspace) {
        phases = [
            MomentsInProgressProgressPhase(
                title: L10n.string("moment.progress.project"),
                detail: MomentsProjectStatusRules.displayTitle(for: workspace.project.status),
                systemImage: "doc.text",
                state: .complete
            ),
            MomentsInProgressProgressPhase(
                title: L10n.string("moment.progress.media"),
                detail: workspace.mediaAssets.isEmpty ? L10n.string("moment.progress.noMedia") : L10n.string("moment.progress.assets", workspace.mediaAssets.count),
                systemImage: "photo.on.rectangle",
                state: workspace.mediaAssets.isEmpty ? .waiting : .complete
            ),
            MomentsInProgressProgressPhase(
                title: L10n.string("moment.progress.story"),
                detail: workspace.storyScenes.isEmpty ? L10n.string("moment.progress.notReady") : L10n.string("moment.progress.scenes", workspace.storyScenes.count),
                systemImage: "text.bubble",
                state: workspace.storyScenes.isEmpty ? .waiting : .complete
            ),
            MomentsInProgressProgressPhase(
                title: L10n.string("moment.kind.storyReview"),
                detail: Self.renderDetail(workspace: workspace, kind: "preview", fallback: L10n.string("moment.progress.notReviewed")),
                systemImage: "text.bubble",
                state: Self.renderState(workspace: workspace, kind: "preview", artifactKind: "preview")
            ),
            MomentsInProgressProgressPhase(
                title: L10n.string("moment.progress.createVideo"),
                detail: Self.renderDetail(workspace: workspace, kind: "final", fallback: L10n.string("moment.progress.notCreated")),
                systemImage: "video.fill",
                state: Self.renderState(workspace: workspace, kind: "final", artifactKind: "final_export")
            )
        ]
    }

    private static func renderDetail(workspace: MomentProjectWorkspace, kind: String, fallback: String) -> String {
        if let artifact = workspace.latestArtifact(kind: artifactKind(for: kind)) {
            return MomentsProjectStatusRules.displayTitle(for: artifact.status)
        }

        guard let job = workspace.latestRenderJob(kind: kind) else {
            return fallback
        }

        return MomentsProjectStatusRules.displayTitle(for: job.status)
    }

    private static func renderState(
        workspace: MomentProjectWorkspace,
        kind: String,
        artifactKind: String
    ) -> MomentsInProgressProgressState {
        if workspace.hasAvailableArtifact(kind: artifactKind) {
            return .complete
        }

        guard let job = workspace.latestRenderJob(kind: kind) else {
            return .waiting
        }

        return MomentsInProgressProgressState(status: job.status)
    }

    private static func artifactKind(for renderKind: String) -> String {
        renderKind == "final" ? "final_export" : renderKind
    }
}

struct MomentsInProgressProgressPhase: Identifiable, Equatable {
    let title: String
    let detail: String
    let systemImage: String
    let state: MomentsInProgressProgressState

    var id: String {
        title
    }
}

enum MomentsInProgressProgressState: Equatable {
    case complete
    case active
    case waiting
    case failed

    init(status: String) {
        switch status {
        case "completed", "available", "succeeded":
            self = .complete
        case "failed", "error", "blocked":
            self = .failed
        case "queued", "running", "processing", "pending":
            self = .active
        default:
            self = .active
        }
    }

    var systemImage: String {
        switch self {
        case .complete: "checkmark.circle.fill"
        case .active: "clock.fill"
        case .waiting: "circle"
        case .failed: "exclamationmark.circle.fill"
        }
    }

}
