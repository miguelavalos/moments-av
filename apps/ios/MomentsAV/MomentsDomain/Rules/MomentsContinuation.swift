import Foundation

enum MomentsContinuationFocus: Hashable {
    case review
    case media
    case story
    case finalRender
}

struct MomentNextAction: Equatable {
    let title: String
    let message: String
    let systemImage: String
    let primaryButtonTitle: String
    let continuationFocus: MomentsContinuationFocus
}

struct MomentsContinuationRequest: Equatable {
    let moment: InProgressMoment
    let focus: MomentsContinuationFocus

    init(moment: InProgressMoment, focus: MomentsContinuationFocus = .review) {
        self.moment = moment
        self.focus = focus
    }
}
