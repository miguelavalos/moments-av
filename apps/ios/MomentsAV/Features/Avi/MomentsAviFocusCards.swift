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
            title: "Current focus",
            detail: "Avi watches the active workflow, project mix, and available credits."
        ) {
            AVAviInfoRow(
                title: workflowFocusTitle,
                detail: workflowFocusMessage,
                systemImage: workflowFocusSystemImage
            )

            HStack(spacing: 10) {
                AVAviStatPill(
                    title: "Active",
                    value: "\(projectSummary.inProgressCount)",
                    systemImage: "clock"
                )
                AVAviStatPill(
                    title: "Finished",
                    value: "\(projectSummary.finishedCount)",
                    systemImage: "checkmark.circle"
                )
                AVAviStatPill(
                    title: "Credits",
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
            title: "Credit guidance",
            detail: "Wallet details use the same credit groups across Moments AV."
        ) {
            HStack(spacing: 10) {
                AVAviStatPill(title: "First", value: "Pro monthly", systemImage: "calendar")
                AVAviStatPill(title: "Then", value: "Purchased", systemImage: "creditcard")
                AVAviStatPill(title: "Then", value: "Other", systemImage: "gift")
            }
            Text(message)
                .foregroundStyle(.secondary)
        }
    }
}
