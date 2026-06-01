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
        guard isSignedIn else { return MomentsL10n.string("avi.focus.signIn.title") }
        if projectSummary.inProgressCount > 0 { return MomentsL10n.string("avi.focus.reviewActive.title") }
        if projectSummary.finishedCount > 0 { return MomentsL10n.string("avi.focus.nextMemory.title") }
        return MomentsL10n.string("avi.focus.firstMemory.title")
    }

    private static func workflowFocusMessage(
        isSignedIn: Bool,
        projectSummary: MomentsProjectListSummary
    ) -> String {
        guard isSignedIn else {
            return MomentsL10n.string("avi.focus.signIn.message")
        }
        if projectSummary.inProgressCount > 0 {
            return MomentsL10n.string("avi.focus.inProgress.message", projectSummary.inProgressCount, inProgressProjectLabel(projectSummary))
        }
        if projectSummary.finishedCount > 0 {
            return MomentsL10n.string("avi.focus.finished.message")
        }
        return MomentsL10n.string("avi.focus.empty.message")
    }

    private static func workflowFocusSystemImage(projectSummary: MomentsProjectListSummary) -> String {
        projectSummary.inProgressCount > 0 ? "clock.badge.checkmark" : "sparkles"
    }

    private static func creditGuidanceMessage(
        isSignedIn: Bool,
        creditBalance: MomentsCreditBalance
    ) -> String {
        guard isSignedIn else {
            return MomentsL10n.string("avi.credits.signIn.message")
        }
        guard creditBalance.spendable > 0 else {
            return MomentsL10n.string("avi.credits.none.message")
        }
        return MomentsL10n.string("avi.credits.available.message", MomentsCreditCopy.countTitle(creditBalance.spendable))
    }

    private static func inProgressProjectLabel(_ projectSummary: MomentsProjectListSummary) -> String {
        projectSummary.inProgressCount == 1 ? MomentsL10n.string("moment.noun.one") : MomentsL10n.string("moment.noun.other")
    }
}
