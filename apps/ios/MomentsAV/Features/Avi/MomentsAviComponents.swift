import AVAviFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAviPreparationCard: View {
    let openCreate: () -> Void

    var body: some View {
        AVSettingsCard {
            Text("Before creating")
                .font(.headline)
            MomentsAviInfoRow(
                title: "Choose a focused occasion",
                detail: "Birthdays, trips, milestones, and recaps work best when the draft has one clear purpose.",
                systemImage: "sparkles"
            )
            MomentsAviInfoRow(
                title: "Use a tight media set",
                detail: "Pick the strongest clips and photos first. The create flow can keep the order clean for the story draft.",
                systemImage: "photo.on.rectangle"
            )
            MomentsAviInfoRow(
                title: "Preview before final export",
                detail: "Previews are for checking pacing and story. Final render is the credit-committing step.",
                systemImage: "play.rectangle"
            )
            MomentsAviActionRow(
                title: "Prepare a new video",
                detail: "Open the create flow when the occasion and media set are ready.",
                systemImage: "plus.app",
                buttonTitle: "Open Create",
                action: openCreate
            )
        }
    }
}

struct MomentsAviCurrentFocusCard: View {
    let workflowFocusTitle: String
    let workflowFocusMessage: String
    let projectSummary: MomentsProjectListSummary
    let creditBalance: MomentsCreditBalance

    var body: some View {
        AVSettingsCard {
            Text("Current focus")
                .font(.headline)
            MomentsAviInfoRow(
                title: workflowFocusTitle,
                detail: workflowFocusMessage,
                systemImage: projectSummary.inProgressCount > 0 ? "clock.badge.checkmark" : "sparkles"
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

struct MomentsAviHelpCard: View {
    var body: some View {
        AVSettingsCard {
            Text("How Avi helps")
                .font(.headline)
            MomentsAviInfoRow(
                title: "Draft",
                detail: "Turns the occasion, tone, template, and selected media into a scene outline.",
                systemImage: "text.quote"
            )
            MomentsAviInfoRow(
                title: "Preview",
                detail: "Helps validate pacing and story shape before credits are committed to the final export.",
                systemImage: "rectangle.inset.filled.and.person.filled"
            )
            MomentsAviInfoRow(
                title: "Project review",
                detail: "Points you back to story scenes, render jobs, and artifacts when a project needs inspection.",
                systemImage: "rectangle.stack"
            )
        }
    }
}

struct MomentsAviProjectGuidanceCard: View {
    let openProjects: () -> Void

    var body: some View {
        AVSettingsCard {
            Text("Project guidance")
                .font(.headline)
            MomentsAviInfoRow(
                title: "In progress",
                detail: "Use Projects to check story scenes, preview artifacts, and render jobs while a video is moving through the workflow.",
                systemImage: "clock"
            )
            MomentsAviInfoRow(
                title: "Finished",
                detail: "Completed projects keep the final export artifact visible in the workspace detail.",
                systemImage: "checkmark.circle"
            )
            Button(action: openProjects) {
                Label("Open Projects", systemImage: "rectangle.stack")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct MomentsAviInfoRow: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        AVAviInfoRow(
            title: title,
            detail: detail,
            systemImage: systemImage,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }

    private var accessibilityIdentifier: String {
        "moments.avi.\(title.lowercased().replacingOccurrences(of: " ", with: "."))"
    }
}

private struct MomentsAviActionRow: View {
    let title: String
    let detail: String
    let systemImage: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MomentsAviInfoRow(title: title, detail: detail, systemImage: systemImage)
            Button(action: action) {
                Label(buttonTitle, systemImage: systemImage)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(MomentsTheme.brandPalette.accent)
        }
    }
}
