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
            detail: "Credits are consumed in a predictable order before final export."
        ) {
            HStack(spacing: 10) {
                AVAviStatPill(title: "First", value: "Monthly", systemImage: "calendar")
                AVAviStatPill(title: "Then", value: "Bonus", systemImage: "gift")
                AVAviStatPill(title: "Then", value: "Paid", systemImage: "creditcard")
            }
            Text(message)
                .foregroundStyle(.secondary)
        }
    }
}
