import Foundation

struct MomentsProjectsListPresentation: Equatable {
    let summaryPills: [MomentsProjectsListSummaryPresentation]
    let groups: [MomentsProjectsListGroupPresentation]

    static func make(
        projectSummary: MomentsProjectListSummary,
        selectedProjectId: String?
    ) -> MomentsProjectsListPresentation {
        MomentsProjectsListPresentation(
            summaryPills: [
                MomentsProjectsListSummaryPresentation(
                    title: "Total",
                    value: projectSummary.projectCount,
                    systemImage: "rectangle.stack"
                ),
                MomentsProjectsListSummaryPresentation(
                    title: "Active",
                    value: projectSummary.inProgressCount,
                    systemImage: "clock"
                ),
                MomentsProjectsListSummaryPresentation(
                    title: "Done",
                    value: projectSummary.finishedCount,
                    systemImage: "checkmark.circle"
                )
            ],
            groups: [
                MomentsProjectsListGroupPresentation(
                    title: "In progress",
                    rows: projectSummary.groups.inProgress.map {
                        MomentsProjectsListRowPresentation(project: $0, isSelected: selectedProjectId == $0.id)
                    }
                ),
                MomentsProjectsListGroupPresentation(
                    title: "Finished",
                    rows: projectSummary.groups.finished.map {
                        MomentsProjectsListRowPresentation(project: $0, isSelected: selectedProjectId == $0.id)
                    }
                )
            ].filter { !$0.rows.isEmpty }
        )
    }
}

struct MomentsProjectsListSummaryPresentation: Identifiable, Equatable {
    let title: String
    let value: Int
    let systemImage: String

    var id: String { title }
}

struct MomentsProjectsListGroupPresentation: Identifiable, Equatable {
    let title: String
    let rows: [MomentsProjectsListRowPresentation]

    var id: String { title }
    var count: Int { rows.count }
}

struct MomentsProjectsListRowPresentation: Identifiable, Equatable {
    let project: MomentDraftProject
    let title: String
    let statusSystemImage: String
    let isFinished: Bool
    let metadata: [MomentsProjectsListMetadataPresentation]
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
            MomentsProjectsListMetadataPresentation(
                systemImage: "clock",
                text: MomentsProjectFormatting.updatedAt(project)
            ),
            MomentsProjectsListMetadataPresentation(
                systemImage: "play.rectangle",
                text: MomentsProjectFormatting.previewUsage(project)
            )
        ]
        self.statusTitle = MomentsProjectFormatting.statusTitle(project)
        self.creditCostTitle = "\(Int(project.creditCost)) credits"
        self.accessorySystemImage = isSelected ? "chevron.up.circle.fill" : "chevron.right.circle"
        self.isSelected = isSelected
    }
}

struct MomentsProjectsListMetadataPresentation: Identifiable, Equatable {
    let systemImage: String
    let text: String

    var id: String { "\(systemImage)-\(text)" }
}
