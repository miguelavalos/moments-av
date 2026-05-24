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

    static func make(from projects: [MomentDraftProject]) -> MomentsProjectListSummary {
        MomentsProjectListSummary(
            projects: projects,
            groups: MomentsProjectStatusRules.group(projects),
            latestProject: projects.max { $0.updatedAt < $1.updatedAt }
        )
    }
}

struct MomentsProjectNextAction: Equatable {
    let title: String
    let message: String
    let systemImage: String
    let primaryButtonTitle: String
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
                primaryButtonTitle: "Review in Create"
            )
        }

        if workspace.mediaAssets.isEmpty {
            return MomentsProjectNextAction(
                title: "Add media",
                message: "Continue in Create and add photos or clips before generating the story.",
                systemImage: "photo.badge.plus",
                primaryButtonTitle: "Add Media in Create"
            )
        }

        if workspace.storyScenes.isEmpty {
            return MomentsProjectNextAction(
                title: "Generate story",
                message: "Continue in Create and ask Avi to draft the story scenes.",
                systemImage: "text.bubble",
                primaryButtonTitle: "Generate Story in Create"
            )
        }

        if !workspace.artifacts.containsAvailable(kind: "preview") {
            return MomentsProjectNextAction(
                title: "Generate preview",
                message: "Create a preview to check pacing before spending credits on the final export.",
                systemImage: "play.rectangle",
                primaryButtonTitle: "Generate Preview in Create"
            )
        }

        if !workspace.artifacts.containsAvailable(kind: "final_export") {
            return MomentsProjectNextAction(
                title: "Render final export",
                message: "Preview is ready. Continue in Create to generate the final export.",
                systemImage: "square.and.arrow.up",
                primaryButtonTitle: "Render Final in Create"
            )
        }

        return MomentsProjectNextAction(
            title: "Finished",
            message: "Final export is available.",
            systemImage: "checkmark.circle",
            primaryButtonTitle: "Open in Create"
        )
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
