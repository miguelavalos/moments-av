import Foundation

struct MomentsProjectWorkspaceDetailPresentation: Equatable {
    let title = L10n.string("project.workspace.detailTitle")
    let nextAction: MomentsProjectNextAction
    let continuationRequest: MomentsProjectContinuationRequest

    init(workspace: MomentProjectWorkspace) {
        nextAction = MomentsProjectStatusRules.nextAction(for: workspace)
        continuationRequest = MomentsProjectContinuationRequest(
            project: workspace.project,
            focus: nextAction.continuationFocus
        )
    }
}
