import Foundation

struct MomentsAviPresentation: Equatable {
    let workflowFocusTitle: String
    let workflowFocusMessage: String
    let workflowFocusSystemImage: String
    let creditGuidanceMessage: String

    static func make(
        isSignedIn: Bool,
        projectSummary: InProgressMomentsSummary,
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
        projectSummary: InProgressMomentsSummary
    ) -> String {
        guard isSignedIn else { return L10n.string("avi.focus.signIn.title") }
        if projectSummary.inProgressCount > 0 { return L10n.string("avi.focus.reviewActive.title") }
        if projectSummary.finishedCount > 0 { return L10n.string("avi.focus.nextMemory.title") }
        return L10n.string("avi.focus.firstMemory.title")
    }

    private static func workflowFocusMessage(
        isSignedIn: Bool,
        projectSummary: InProgressMomentsSummary
    ) -> String {
        guard isSignedIn else {
            return L10n.string("avi.focus.signIn.message")
        }
        if projectSummary.inProgressCount > 0 {
            return L10n.string("avi.focus.inProgress.message", projectSummary.inProgressCount, inProgressProjectLabel(projectSummary))
        }
        if projectSummary.finishedCount > 0 {
            return L10n.string("avi.focus.finished.message")
        }
        return L10n.string("avi.focus.empty.message")
    }

    private static func workflowFocusSystemImage(projectSummary: InProgressMomentsSummary) -> String {
        projectSummary.inProgressCount > 0 ? "clock.badge.checkmark" : "sparkles"
    }

    private static func creditGuidanceMessage(
        isSignedIn: Bool,
        creditBalance: MomentsCreditBalance
    ) -> String {
        guard isSignedIn else {
            return L10n.string("avi.credits.signIn.message")
        }
        guard creditBalance.spendable > 0 else {
            return L10n.string("avi.credits.none.message")
        }
        return L10n.string("avi.credits.available.message", MomentsCreditCopy.countTitle(creditBalance.spendable))
    }

    private static func inProgressProjectLabel(_ projectSummary: InProgressMomentsSummary) -> String {
        projectSummary.inProgressCount == 1 ? L10n.string("moment.noun.one") : L10n.string("moment.noun.other")
    }
}
