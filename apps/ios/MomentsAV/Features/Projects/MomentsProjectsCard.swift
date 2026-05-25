import AVSettingsFoundation
import SwiftUI

struct MomentsProjectsCard: View {
    let presentation: MomentsProjectsPresentation
    let projectSummary: MomentsProjectListSummary
    let selectedProjectId: String?
    let isLoadingProjectWorkspace: Bool
    let activeWorkspace: MomentProjectWorkspace?
    let isDeletingProject: Bool
    let statusMessage: String?
    let selectProject: (MomentDraftProject) -> Void
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        AVSettingsCard {
            Text("Projects")
                .font(.headline)

            switch presentation.availability {
            case let .signedOut(unavailable), let .empty(unavailable):
                MomentsProjectsUnavailableState(presentation: unavailable)
            case .available:
                MomentsProjectsList(
                    projectSummary: projectSummary,
                    selectedProjectId: selectedProjectId,
                    selectProject: selectProject
                )
                MomentsProjectsSelectedDetail(
                    selectedProjectId: selectedProjectId,
                    isLoadingProjectWorkspace: isLoadingProjectWorkspace,
                    activeWorkspace: activeWorkspace,
                    isDeletingProject: isDeletingProject,
                    continueProject: continueProject,
                    requestDeleteProject: requestDeleteProject
                )
                MomentsProjectsStatusMessage(message: statusMessage)
            }
        }
    }
}
