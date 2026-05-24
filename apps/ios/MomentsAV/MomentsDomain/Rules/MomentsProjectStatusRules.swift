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
        MomentsProjectGroups(
            inProgress: projects.filter { !isFinished($0) },
            finished: projects.filter(isFinished)
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
}
