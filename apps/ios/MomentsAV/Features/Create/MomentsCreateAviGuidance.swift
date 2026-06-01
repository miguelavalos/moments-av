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
                message: "Something needs another try. You can retry when you are ready.",
                actionTitle: nil,
                reaction: .negative
            )
        }

        if isDraftLocked {
            return MomentsCreateAviGuidance(
                emotion: .focused,
                message: "\(selectedStyle.title) is ready. Add photos or clips.",
                actionTitle: nil,
                reaction: .affirm
            )
        }

        guard isSignedIn else {
            return MomentsCreateAviGuidance(
                emotion: .curious,
                message: "Connect your account to start your first memory video.",
                actionTitle: "Sign in",
                reaction: .selection
            )
        }

        if balance.spendable <= 0 {
            return MomentsCreateAviGuidance(
                emotion: .happy,
                message: "Add photos or clips now. Credits are needed before creating the final video.",
                actionTitle: "Start project",
                reaction: .positive
            )
        }

        switch step {
        case .status:
            return MomentsCreateAviGuidance(
                emotion: .happy,
                message: "Add photos or clips. Avi will prepare the first story.",
                actionTitle: "Start project",
                reaction: .positive
            )
        case .style:
            return MomentsCreateAviGuidance(
                emotion: .curious,
                message: "Choose a theme. Moments AV will open your workspace right after.",
                actionTitle: nil,
                reaction: .selection
            )
        case .summary:
            return MomentsCreateAviGuidance(
                emotion: .focused,
                message: "\(selectedStyle.title) is set. Add photos or clips next.",
                actionTitle: nil,
                reaction: .affirm
            )
        }
    }
}
