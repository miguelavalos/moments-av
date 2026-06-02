import SwiftUI

struct MomentsInProgressList: View {
    let projectSummary: MomentsProjectListSummary
    let selectedProjectId: String?
    let selectProject: (MomentDraftProject) -> Void
    private var presentation: MomentsInProgressListPresentation {
        MomentsInProgressListPresentation.make(
            projectSummary: projectSummary,
            selectedProjectId: selectedProjectId
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MomentsInProgressListSummaryRow(pills: presentation.summaryPills)

            ForEach(presentation.groups) { group in
                MomentsInProgressListGroup(
                    group: group,
                    selectProject: selectProject
                )
            }
        }
    }
}
