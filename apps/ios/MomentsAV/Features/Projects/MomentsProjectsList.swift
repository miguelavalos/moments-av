import SwiftUI

struct MomentsProjectsList: View {
    let projectSummary: MomentsProjectListSummary
    let selectedProjectId: String?
    let selectProject: (MomentDraftProject) -> Void
    private var presentation: MomentsProjectsListPresentation {
        MomentsProjectsListPresentation.make(
            projectSummary: projectSummary,
            selectedProjectId: selectedProjectId
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MomentsProjectsListSummaryRow(pills: presentation.summaryPills)

            ForEach(presentation.groups) { group in
                MomentsProjectsListGroup(
                    group: group,
                    selectProject: selectProject
                )
            }
        }
    }
}
