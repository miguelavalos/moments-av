import Foundation

struct MomentsProjectGroups {
    let inProgress: [MomentDraftProject]
    let finished: [MomentDraftProject]
}

struct MomentsProjectListSummary: Equatable {
    var projects: [MomentDraftProject] = []
    var groups = MomentsProjectGroups()
    var latestProject: MomentDraftProject?

    var projectCount: Int {
        projects.count
    }

    var inProgressCount: Int {
        groups.inProgress.count
    }

    var finishedCount: Int {
        groups.finished.count
    }

    var hasProjects: Bool {
        !projects.isEmpty
    }

    var latestInProgressProject: MomentDraftProject? {
        groups.inProgress.first
    }

    var latestInProgressContinuationRequest: MomentsProjectContinuationRequest? {
        latestInProgressProject.map { MomentsProjectContinuationRequest(project: $0) }
    }

    static func make(from projects: [MomentDraftProject]) -> MomentsProjectListSummary {
        MomentsProjectListSummary(
            projects: projects,
            groups: MomentsProjectStatusRules.group(projects),
            latestProject: projects.max { $0.updatedAt < $1.updatedAt }
        )
    }
}

enum MomentsProjectContinuationFocus: Hashable {
    case review
    case media
    case story
    case preview
    case finalRender
}

struct MomentsProjectNextAction: Equatable {
    let title: String
    let message: String
    let systemImage: String
    let primaryButtonTitle: String
    let continuationFocus: MomentsProjectContinuationFocus
}

struct MomentsProjectContinuationRequest: Equatable {
    let project: MomentDraftProject
    let focus: MomentsProjectContinuationFocus

    init(project: MomentDraftProject, focus: MomentsProjectContinuationFocus = .review) {
        self.project = project
        self.focus = focus
    }
}

extension MomentsProjectGroups: Equatable {
    init() {
        self.init(inProgress: [], finished: [])
    }
}

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
        status
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    static func displayKind(_ kind: String) -> String {
        kind
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    static func nextAction(for workspace: MomentProjectWorkspace) -> MomentsProjectNextAction {
        if let failedJob = workspace.renderJobs.latest(where: { isFailureStatus($0.status) }) {
            return MomentsProjectNextAction(
                title: "Review render issue",
                message: "\(displayKind(failedJob.kind)) failed. Return to Create and refresh or retry the render.",
                systemImage: "exclamationmark.triangle",
                primaryButtonTitle: "Review in Create",
                continuationFocus: focus(forFailedJobKind: failedJob.kind)
            )
        }

        if workspace.mediaAssets.isEmpty {
            return MomentsProjectNextAction(
                title: "Add media",
                message: "Continue in Create and add photos or clips before generating the story.",
                systemImage: "photo.badge.plus",
                primaryButtonTitle: "Add Media in Create",
                continuationFocus: .media
            )
        }

        if workspace.storyScenes.isEmpty {
            return MomentsProjectNextAction(
                title: "Generate story",
                message: "Continue in Create and ask Avi to draft the story scenes.",
                systemImage: "text.bubble",
                primaryButtonTitle: "Generate Story in Create",
                continuationFocus: .story
            )
        }

        if !workspace.artifacts.containsAvailable(kind: "preview") {
            return MomentsProjectNextAction(
                title: "Generate preview",
                message: "Create a preview to check pacing before spending credits on the final export.",
                systemImage: "play.rectangle",
                primaryButtonTitle: "Generate Preview in Create",
                continuationFocus: .preview
            )
        }

        if !workspace.artifacts.containsAvailable(kind: "final_export") {
            return MomentsProjectNextAction(
                title: "Render final export",
                message: "Preview is ready. Continue in Create to generate the final export.",
                systemImage: "square.and.arrow.up",
                primaryButtonTitle: "Render Final in Create",
                continuationFocus: .finalRender
            )
        }

        return MomentsProjectNextAction(
            title: "Finished",
            message: "Final export is available.",
            systemImage: "checkmark.circle",
            primaryButtonTitle: "Open in Create",
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
