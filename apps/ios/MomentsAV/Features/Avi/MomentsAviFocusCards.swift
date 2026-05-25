import AVAviFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAviCurrentFocusCard: View {
    let workflowFocusTitle: String
    let workflowFocusMessage: String
    let workflowFocusSystemImage: String
    let projectSummary: MomentsProjectListSummary
    let creditBalance: MomentsCreditBalance

    var body: some View {
        AVSettingsCard {
            Text("Current focus")
                .font(.headline)
            MomentsAviInfoRow(
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
        AVSettingsCard {
            Text("Credit guidance")
                .font(.headline)
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
