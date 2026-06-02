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
        step: MomentsCreateNewMomentStep,
        isSetupLocked: Bool,
        setupErrorMessage: String?
    ) -> MomentsCreateAviGuidance {
        if setupErrorMessage != nil {
            return MomentsCreateAviGuidance(
                emotion: .warning,
                message: L10n.string("create.guidance.retry"),
                actionTitle: nil,
                reaction: .negative
            )
        }

        if isSetupLocked {
            return MomentsCreateAviGuidance(
                emotion: .focused,
                message: L10n.string("create.guidance.locked", selectedStyle.title),
                actionTitle: nil,
                reaction: .affirm
            )
        }

        guard isSignedIn else {
            return MomentsCreateAviGuidance(
                emotion: .curious,
                message: L10n.string("create.guidance.signIn"),
                actionTitle: L10n.string("common.signIn"),
                reaction: .selection
            )
        }

        if balance.spendable <= 0 {
            return MomentsCreateAviGuidance(
                emotion: .happy,
                message: L10n.string("create.guidance.noCredits"),
                actionTitle: L10n.string("create.action.startMoment"),
                reaction: .positive
            )
        }

        switch step {
        case .status:
            return MomentsCreateAviGuidance(
                emotion: .happy,
                message: L10n.string("create.guidance.addMedia"),
                actionTitle: L10n.string("create.action.startMoment"),
                reaction: .positive
            )
        case .style:
            return MomentsCreateAviGuidance(
                emotion: .curious,
                message: L10n.string("create.guidance.chooseTheme"),
                actionTitle: nil,
                reaction: .selection
            )
        case .summary:
            return MomentsCreateAviGuidance(
                emotion: .focused,
                message: L10n.string("create.guidance.styleSet", selectedStyle.title),
                actionTitle: nil,
                reaction: .affirm
            )
        }
    }
}
