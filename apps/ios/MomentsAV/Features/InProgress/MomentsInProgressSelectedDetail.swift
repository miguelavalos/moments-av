import SwiftUI

struct MomentsInProgressSelectedDetail: View {
    let selectedProjectId: String?
    let isLoadingProjectWorkspace: Bool
    let activeWorkspace: MomentProjectWorkspace?
    let isDeletingProject: Bool
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        if isLoadingProjectWorkspace {
            Divider()
                .padding(.vertical, 8)
            MomentsProjectLoadingDetail()
        } else if let activeWorkspace, selectedProjectId == activeWorkspace.project.id {
            Divider()
                .padding(.vertical, 8)
            MomentsProjectWorkspaceDetail(
                workspace: activeWorkspace,
                isDeletingProject: isDeletingProject,
                continueProject: continueProject,
                requestDeleteProject: requestDeleteProject
            )
        }
    }
}
