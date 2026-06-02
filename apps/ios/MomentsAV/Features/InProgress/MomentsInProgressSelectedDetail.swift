import SwiftUI

struct MomentsInProgressSelectedDetail: View {
    let selectedMomentId: String?
    let isLoadingProjectWorkspace: Bool
    let activeWorkspace: MomentProjectWorkspace?
    let isDeletingMoment: Bool
    let continueMoment: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteMoment: (MomentDraftProject) -> Void

    var body: some View {
        if isLoadingProjectWorkspace {
            Divider()
                .padding(.vertical, 8)
            MomentsInProgressLoadingDetail()
        } else if let activeWorkspace, selectedMomentId == activeWorkspace.project.id {
            Divider()
                .padding(.vertical, 8)
            MomentsInProgressWorkspaceDetail(
                workspace: activeWorkspace,
                isDeletingMoment: isDeletingMoment,
                continueMoment: continueMoment,
                requestDeleteMoment: requestDeleteMoment
            )
        }
    }
}
