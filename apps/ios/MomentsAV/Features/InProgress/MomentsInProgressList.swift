import SwiftUI

struct MomentsInProgressList: View {
    let projectSummary: InProgressMomentsSummary
    let selectedMomentId: String?
    let selectProject: (InProgressMoment) -> Void
    private var presentation: MomentsInProgressListPresentation {
        MomentsInProgressListPresentation.make(
            projectSummary: projectSummary,
            selectedMomentId: selectedMomentId
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
