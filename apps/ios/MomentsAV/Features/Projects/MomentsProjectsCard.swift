import AVAppShellFoundation
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
    let startProject: () -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        AVAppShellCard {
            switch presentation.availability {
            case let .signedOut(unavailable):
                MomentsProjectsUnavailableState(presentation: unavailable)
            case let .empty(unavailable):
                MomentsProjectsEmptyState(
                    presentation: unavailable,
                    startProject: startProject
                )
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
