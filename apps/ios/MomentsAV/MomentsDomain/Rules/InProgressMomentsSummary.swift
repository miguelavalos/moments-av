import Foundation

struct InProgressMomentGroups {
    let inProgress: [InProgressMoment]
    let finished: [InProgressMoment]
}

struct InProgressMomentsSummary: Equatable {
    var moments: [InProgressMoment] = []
    var groups = InProgressMomentGroups()
    var latestProject: InProgressMoment?

    var projectCount: Int {
        moments.count
    }

    var inProgressCount: Int {
        groups.inProgress.count
    }

    var finishedCount: Int {
        groups.finished.count
    }

    var hasProjects: Bool {
        !moments.isEmpty
    }

    var latestInProgressProject: InProgressMoment? {
        groups.inProgress.first
    }

    var latestInProgressContinuationRequest: MomentsContinuationRequest? {
        latestInProgressProject.map { MomentsContinuationRequest(moment: $0) }
    }

    static func make(from moments: [InProgressMoment]) -> InProgressMomentsSummary {
        InProgressMomentsSummary(
            moments: moments,
            groups: MomentStatusRules.group(moments),
            latestProject: moments.max { $0.updatedAt < $1.updatedAt }
        )
    }

    func removing(momentId: String) -> InProgressMomentsSummary {
        Self.make(from: moments.filter { $0.id != momentId })
    }
}

extension InProgressMomentGroups: Equatable {
    init() {
        self.init(inProgress: [], finished: [])
    }
}
