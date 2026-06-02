import Foundation

enum MomentsProjectStatusRules {
    static func isFinished(_ project: MomentDraftProject) -> Bool {
        isFinishedStatus(project.status)
    }

    static func isFinishedStatus(_ status: String) -> Bool {
        status == "completed"
    }

    static func group(_ projects: [MomentDraftProject]) -> MomentsProjectGroups {
        let sortedProjects = projects.sortedByLatestUpdate()

        return MomentsProjectGroups(
            inProgress: sortedProjects.filter { !isFinished($0) },
            finished: sortedProjects.filter(isFinished)
        )
    }

    static func displayTitle(for status: String) -> String {
        if status == "preview_ready" {
            return L10n.string("project.status.storyReady")
        }
        if status == "final_render_pending" || status == "final_render_running" {
            return L10n.string("project.status.creatingVideo")
        }
        if status == "export_ready" || status == "completed" {
            return L10n.string("project.status.videoReady")
        }
        return status
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    static func displayKind(_ kind: String) -> String {
        if kind == "preview" {
            return L10n.string("project.kind.storyReview")
        }
        return kind
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    static func nextAction(for workspace: MomentProjectWorkspace) -> MomentsProjectNextAction {
        if let failedJob = workspace.renderJobs.latest(where: { isFailureStatus($0.status) }) {
            return MomentsProjectNextAction(
                title: L10n.string("project.nextAction.videoAttention.title"),
                message: L10n.string("project.nextAction.videoAttention.message", displayKind(failedJob.kind)),
                systemImage: "exclamationmark.triangle",
                primaryButtonTitle: L10n.string("project.nextAction.reviewInCreate"),
                continuationFocus: focus(forFailedJobKind: failedJob.kind)
            )
        }

        if workspace.mediaAssets.isEmpty {
            return MomentsProjectNextAction(
                title: L10n.string("project.nextAction.addMedia.title"),
                message: L10n.string("project.nextAction.addMedia.message"),
                systemImage: "photo.badge.plus",
                primaryButtonTitle: L10n.string("project.nextAction.addMedia.button"),
                continuationFocus: .media
            )
        }

        if workspace.storyScenes.isEmpty {
            return MomentsProjectNextAction(
                title: L10n.string("project.nextAction.prepareStory.title"),
                message: L10n.string("project.nextAction.prepareStory.message"),
                systemImage: "text.bubble",
                primaryButtonTitle: L10n.string("project.nextAction.prepareStory.button"),
                continuationFocus: .story
            )
        }

        if !workspace.artifacts.containsAvailable(kind: "preview") {
            return MomentsProjectNextAction(
                title: L10n.string("project.nextAction.reviewStory.title"),
                message: L10n.string("project.nextAction.reviewStory.message"),
                systemImage: "text.bubble",
                primaryButtonTitle: L10n.string("project.nextAction.reviewStory.button"),
                continuationFocus: .preview
            )
        }

        if !workspace.artifacts.containsAvailable(kind: "final_export") {
            return MomentsProjectNextAction(
                title: L10n.string("project.nextAction.createVideo.title"),
                message: L10n.string("project.nextAction.createVideo.message"),
                systemImage: "video.fill",
                primaryButtonTitle: L10n.string("project.nextAction.createVideo.button"),
                continuationFocus: .finalRender
            )
        }

        return MomentsProjectNextAction(
            title: L10n.string("library.finished.title"),
            message: L10n.string("project.nextAction.finished.message"),
            systemImage: "checkmark.circle",
            primaryButtonTitle: L10n.string("project.nextAction.openInCreate"),
            continuationFocus: .finalRender
        )
    }

    private static func focus(forFailedJobKind kind: String) -> MomentsProjectContinuationFocus {
        switch kind {
        case "preview":
            .preview
        case "final_render":
            .finalRender
        default:
            .review
        }
    }

    private static func isFailureStatus(_ status: String) -> Bool {
        ["failed", "error", "blocked"].contains(status)
    }
}

private extension [MomentDraftProject] {
    func sortedByLatestUpdate() -> [MomentDraftProject] {
        sorted { $0.updatedAt > $1.updatedAt }
    }
}

private extension [MomentRenderJob] {
    func latest(where predicate: (MomentRenderJob) -> Bool) -> MomentRenderJob? {
        filter(predicate)
            .sorted { $0.updatedAt < $1.updatedAt }
            .last
    }
}

private extension [MomentArtifact] {
    func containsAvailable(kind: String) -> Bool {
        contains { $0.kind == kind && $0.status == "available" }
    }
}
