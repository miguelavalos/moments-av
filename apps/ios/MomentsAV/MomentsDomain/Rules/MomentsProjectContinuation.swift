import Foundation

enum MomentsProjectContinuationFocus: Hashable {
    case review
    case media
    case story
    case preview
    case finalRender
}

struct MomentsProjectNextAction: Equatable {
    let title: String
    let message: String
    let systemImage: String
    let primaryButtonTitle: String
    let continuationFocus: MomentsProjectContinuationFocus
}

struct MomentsProjectContinuationRequest: Equatable {
    let project: MomentDraftProject
    let focus: MomentsProjectContinuationFocus

    init(project: MomentDraftProject, focus: MomentsProjectContinuationFocus = .review) {
        self.project = project
        self.focus = focus
    }
}
