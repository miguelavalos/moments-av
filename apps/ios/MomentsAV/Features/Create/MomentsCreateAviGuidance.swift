import AVAviFoundation
import Foundation

enum MomentsCreateAviEmotion: Equatable {
    case curious
    case focused
    case happy
    case thinking
    case warning
    case celebrate
}

struct MomentsCreateAviGuidance: Equatable {
    let emotion: MomentsCreateAviEmotion
    let message: String
    let actionTitle: String?
    let reaction: AVAviActionReaction
}

enum MomentsCreateAviGuidanceResolver {
    static func make(
        isSignedIn: Bool,
        balance: MomentsCreditBalance,
        selectedStyle: MomentCreationStyle,
        step: MomentsCreateNewProjectStep,
        isDraftLocked: Bool,
        draftErrorMessage: String?
    ) -> MomentsCreateAviGuidance {
        if draftErrorMessage != nil {
            return MomentsCreateAviGuidance(
                emotion: .warning,
                message: MomentsL10n.string("create.guidance.retry"),
                actionTitle: nil,
                reaction: .negative
            )
        }

        if isDraftLocked {
            return MomentsCreateAviGuidance(
                emotion: .focused,
                message: MomentsL10n.string("create.guidance.locked", selectedStyle.title),
                actionTitle: nil,
                reaction: .affirm
            )
        }

        guard isSignedIn else {
            return MomentsCreateAviGuidance(
                emotion: .curious,
                message: MomentsL10n.string("create.guidance.signIn"),
                actionTitle: MomentsL10n.string("common.signIn"),
                reaction: .selection
            )
        }

        if balance.spendable <= 0 {
            return MomentsCreateAviGuidance(
                emotion: .happy,
                message: MomentsL10n.string("create.guidance.noCredits"),
                actionTitle: MomentsL10n.string("create.action.startProject"),
                reaction: .positive
            )
        }

        switch step {
        case .status:
            return MomentsCreateAviGuidance(
                emotion: .happy,
                message: MomentsL10n.string("create.guidance.addMedia"),
                actionTitle: MomentsL10n.string("create.action.startProject"),
                reaction: .positive
            )
        case .style:
            return MomentsCreateAviGuidance(
                emotion: .curious,
                message: MomentsL10n.string("create.guidance.chooseTheme"),
                actionTitle: nil,
                reaction: .selection
            )
        case .summary:
            return MomentsCreateAviGuidance(
                emotion: .focused,
                message: MomentsL10n.string("create.guidance.styleSet", selectedStyle.title),
                actionTitle: nil,
                reaction: .affirm
            )
        }
    }
}
