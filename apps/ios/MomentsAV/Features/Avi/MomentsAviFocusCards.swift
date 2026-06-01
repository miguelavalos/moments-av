import AVAviFoundation
import SwiftUI

struct MomentsAviCurrentFocusCard: View {
    let workflowFocusTitle: String
    let workflowFocusMessage: String
    let workflowFocusSystemImage: String
    let projectSummary: MomentsProjectListSummary
    let creditBalance: MomentsCreditBalance

    var body: some View {
        AVAviGuidanceCard(
            title: MomentsL10n.string("avi.currentFocus.title"),
            detail: MomentsL10n.string("avi.currentFocus.detail")
        ) {
            AVAviInfoRow(
                title: workflowFocusTitle,
                detail: workflowFocusMessage,
                systemImage: workflowFocusSystemImage
            )

            HStack(spacing: 10) {
                AVAviStatPill(
                    title: MomentsL10n.string("avi.stat.active"),
                    value: "\(projectSummary.inProgressCount)",
                    systemImage: "clock"
                )
                AVAviStatPill(
                    title: MomentsL10n.string("projects.finished.title"),
                    value: "\(projectSummary.finishedCount)",
                    systemImage: "checkmark.circle"
                )
                AVAviStatPill(
                    title: MomentsL10n.string("credits.title"),
                    value: "\(creditBalance.spendable)",
                    systemImage: "creditcard"
                )
            }
        }
    }
}

struct MomentsAviCreditGuidanceCard: View {
    let message: String

    var body: some View {
        AVAviGuidanceCard(
            title: MomentsL10n.string("avi.creditGuidance.title"),
            detail: MomentsL10n.string("avi.creditGuidance.detail")
        ) {
            HStack(spacing: 10) {
                AVAviStatPill(title: MomentsL10n.string("avi.creditOrder.first"), value: MomentsL10n.string("credits.proMonthly.title"), systemImage: "calendar")
                AVAviStatPill(title: MomentsL10n.string("avi.creditOrder.then"), value: MomentsL10n.string("credits.purchased.title"), systemImage: "creditcard")
                AVAviStatPill(title: MomentsL10n.string("avi.creditOrder.then"), value: MomentsL10n.string("credits.other.title"), systemImage: "gift")
            }
            Text(message)
                .foregroundStyle(.secondary)
        }
    }
}
