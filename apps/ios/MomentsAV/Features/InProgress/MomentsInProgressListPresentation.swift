import Foundation

struct MomentsInProgressListPresentation: Equatable {
    let summaryPills: [MomentsProjectListSummaryPresentation]
    let groups: [MomentsInProgressListGroupPresentation]

    static func make(
        projectSummary: MomentsProjectListSummary,
        selectedProjectId: String?
    ) -> MomentsInProgressListPresentation {
        MomentsInProgressListPresentation(
            summaryPills: [
                MomentsProjectListSummaryPresentation(
                    title: L10n.string("inProgress.summary.total"),
                    value: projectSummary.projectCount,
                    systemImage: "rectangle.stack"
                ),
                MomentsProjectListSummaryPresentation(
                    title: L10n.string("inProgress.summary.active"),
                    value: projectSummary.inProgressCount,
                    systemImage: "clock"
                ),
                MomentsProjectListSummaryPresentation(
                    title: L10n.string("inProgress.summary.done"),
                    value: projectSummary.finishedCount,
                    systemImage: "checkmark.circle"
                )
            ],
            groups: [
                MomentsInProgressListGroupPresentation(
                    title: L10n.string("inProgress.group.inProgress"),
                    rows: projectSummary.groups.inProgress.map {
                        MomentsInProgressListRowPresentation(project: $0, isSelected: selectedProjectId == $0.id)
                    }
                ),
                MomentsInProgressListGroupPresentation(
                    title: L10n.string("inProgress.group.finished"),
                    rows: projectSummary.groups.finished.map {
                        MomentsInProgressListRowPresentation(project: $0, isSelected: selectedProjectId == $0.id)
                    }
                )
            ].filter { !$0.rows.isEmpty }
        )
    }
}

struct MomentsProjectListSummaryPresentation: Identifiable, Equatable {
    let title: String
    let value: Int
    let systemImage: String

    var id: String { title }
}

struct MomentsInProgressListGroupPresentation: Identifiable, Equatable {
    let title: String
    let rows: [MomentsInProgressListRowPresentation]

    var id: String { title }
    var count: Int { rows.count }
}

struct MomentsInProgressListRowPresentation: Identifiable, Equatable {
    let project: MomentDraftProject
    let title: String
    let statusSystemImage: String
    let isFinished: Bool
    let metadata: [MomentsInProgressListMetadataPresentation]
    let statusTitle: String
    let creditCostTitle: String
    let accessorySystemImage: String
    let isSelected: Bool

    var id: String { project.id }

    init(project: MomentDraftProject, isSelected: Bool) {
        self.project = project
        self.title = project.title
        self.isFinished = MomentsProjectStatusRules.isFinished(project)
        self.statusSystemImage = isFinished ? "checkmark.circle.fill" : "circle.dashed"
        self.metadata = [
            MomentsInProgressListMetadataPresentation(
                systemImage: "clock",
                text: MomentsMomentFormatting.updatedAt(project)
            ),
            MomentsInProgressListMetadataPresentation(
                systemImage: "text.bubble",
                text: MomentsMomentFormatting.previewUsage(project)
            )
        ]
        self.statusTitle = MomentsMomentFormatting.statusTitle(project)
        self.creditCostTitle = Self.creditCostTitle(project.creditCost)
        self.accessorySystemImage = isSelected ? "chevron.up.circle.fill" : "chevron.right.circle"
        self.isSelected = isSelected
    }

    private static func creditCostTitle(_ creditCost: Double) -> String {
        let count = Int(creditCost)
        return "\(count) \(count == 1 ? "credit" : "credits")"
    }
}

struct MomentsInProgressListMetadataPresentation: Identifiable, Equatable {
    let systemImage: String
    let text: String

    var id: String { "\(systemImage)-\(text)" }
}
