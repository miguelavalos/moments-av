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

extension MomentsProjectGroups: Equatable {
    init() {
        self.init(inProgress: [], finished: [])
    }
}
