import Foundation

struct MomentsProjectProgressModel {
    let phases: [MomentsProjectProgressPhase]

    init(workspace: MomentProjectWorkspace) {
        phases = [
            MomentsProjectProgressPhase(
                title: "Draft",
                detail: MomentsProjectStatusRules.displayTitle(for: workspace.project.status),
                systemImage: "doc.text",
                state: .complete
            ),
            MomentsProjectProgressPhase(
                title: "Media",
                detail: workspace.mediaAssets.isEmpty ? "No media yet" : "\(workspace.mediaAssets.count) assets",
                systemImage: "photo.on.rectangle",
                state: workspace.mediaAssets.isEmpty ? .waiting : .complete
            ),
            MomentsProjectProgressPhase(
                title: "Story",
                detail: workspace.storyScenes.isEmpty ? "Not drafted" : "\(workspace.storyScenes.count) scenes",
                systemImage: "text.bubble",
                state: workspace.storyScenes.isEmpty ? .waiting : .complete
            ),
            MomentsProjectProgressPhase(
                title: "Preview",
                detail: Self.renderDetail(workspace: workspace, kind: "preview", fallback: "Not generated"),
                systemImage: "play.rectangle",
                state: Self.renderState(workspace: workspace, kind: "preview", artifactKind: "preview")
            ),
            MomentsProjectProgressPhase(
                title: "Final",
                detail: Self.renderDetail(workspace: workspace, kind: "final", fallback: "Not rendered"),
                systemImage: "square.and.arrow.up",
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
    ) -> MomentsProjectProgressState {
        if workspace.hasAvailableArtifact(kind: artifactKind) {
            return .complete
        }

        guard let job = workspace.latestRenderJob(kind: kind) else {
            return .waiting
        }

        return MomentsProjectProgressState(status: job.status)
    }

    private static func artifactKind(for renderKind: String) -> String {
        renderKind == "final" ? "final_export" : renderKind
    }
}

struct MomentsProjectProgressPhase: Identifiable, Equatable {
    let title: String
    let detail: String
    let systemImage: String
    let state: MomentsProjectProgressState

    var id: String {
        title
    }
}

enum MomentsProjectProgressState: Equatable {
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
