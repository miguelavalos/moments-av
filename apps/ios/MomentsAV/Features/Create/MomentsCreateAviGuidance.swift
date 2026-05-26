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
                message: "Project started. Keep moving through media, story, preview, and final video.",
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
                emotion: .warning,
                message: "You need 1 credit to start.",
                actionTitle: "Get credits",
                reaction: .negative
            )
        }

        switch step {
        case .status:
            return MomentsCreateAviGuidance(
                emotion: .happy,
                message: "You are ready. Start with a style and I will shape the video from there.",
                actionTitle: "Start project",
                reaction: .positive
            )
        case .style:
            return MomentsCreateAviGuidance(
                emotion: .curious,
                message: "Choose the feeling of the video. The style guides the story, pace, and music.",
                actionTitle: nil,
                reaction: .selection
            )
        case .summary:
            return MomentsCreateAviGuidance(
                emotion: .focused,
                message: "\(selectedStyle.title) is ready. You can create now or add one small detail.",
                actionTitle: nil,
                reaction: .affirm
            )
        }
    }
}
