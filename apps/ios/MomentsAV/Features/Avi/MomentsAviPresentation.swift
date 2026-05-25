import Foundation

struct MomentsAviPresentation: Equatable {
    let workflowFocusTitle: String
    let workflowFocusMessage: String
    let workflowFocusSystemImage: String
    let creditGuidanceMessage: String

    static func make(
        isSignedIn: Bool,
        projectSummary: MomentsProjectListSummary,
        creditBalance: MomentsCreditBalance
    ) -> MomentsAviPresentation {
        MomentsAviPresentation(
            workflowFocusTitle: workflowFocusTitle(
                isSignedIn: isSignedIn,
                projectSummary: projectSummary
            ),
            workflowFocusMessage: workflowFocusMessage(
                isSignedIn: isSignedIn,
                projectSummary: projectSummary
            ),
            workflowFocusSystemImage: workflowFocusSystemImage(projectSummary: projectSummary),
            creditGuidanceMessage: creditGuidanceMessage(
                isSignedIn: isSignedIn,
                creditBalance: creditBalance
            )
        )
    }

    private static func workflowFocusTitle(
        isSignedIn: Bool,
        projectSummary: MomentsProjectListSummary
    ) -> String {
        guard isSignedIn else { return "Sign in first" }
        if projectSummary.inProgressCount > 0 { return "Review active work" }
        if projectSummary.finishedCount > 0 { return "Start the next memory" }
        return "Create the first memory"
    }

    private static func workflowFocusMessage(
        isSignedIn: Bool,
        projectSummary: MomentsProjectListSummary
    ) -> String {
        guard isSignedIn else {
            return "Avi guidance unlocks after sign in because projects and credits are tied to the account."
        }
        if projectSummary.inProgressCount > 0 {
            return "There \(projectSummary.inProgressCount == 1 ? "is" : "are") \(projectSummary.inProgressCount) \(inProgressProjectLabel(projectSummary)) in progress. Check Projects for the next render or story step."
        }
        if projectSummary.finishedCount > 0 {
            return "Finished exports stay in Projects. Start a new draft in Create when the next occasion is ready."
        }
        return "Start in Create with one occasion and a tight media set. Avi can help turn that into story scenes."
    }

    private static func workflowFocusSystemImage(projectSummary: MomentsProjectListSummary) -> String {
        projectSummary.inProgressCount > 0 ? "clock.badge.checkmark" : "sparkles"
    }

    private static func creditGuidanceMessage(
        isSignedIn: Bool,
        creditBalance: MomentsCreditBalance
    ) -> String {
        guard isSignedIn else {
            return "Credits appear here after sign in."
        }
        guard creditBalance.spendable > 0 else {
            return "No spendable credits are available. Final exports require credits after preview review."
        }
        return "\(MomentsCreditCopy.countTitle(creditBalance.spendable)) \(creditBalance.spendable == 1 ? "is" : "are") spendable for final exports. Monthly credits are used before promotional and purchased credits."
    }

    private static func inProgressProjectLabel(_ projectSummary: MomentsProjectListSummary) -> String {
        projectSummary.inProgressCount == 1 ? "project" : "projects"
    }
}
