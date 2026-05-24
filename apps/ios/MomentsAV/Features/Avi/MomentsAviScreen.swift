import AVAviFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAviScreen: View {
    let selectTab: (MomentsRootTab) -> Void
    @EnvironmentObject private var viewModel: MomentsAviViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                AVAviCompanionCard(
                    title: "Avi in Moments",
                    detail: "Avi helps prepare the inputs, shape the story, and explain render steps. It is guidance for the workflow, not a chat inbox.",
                    actionAccessibilityLabel: "Learn about Avi in Moments",
                    action: {}
                ) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(MomentsTheme.brandPalette.accent)
                }

                AVSettingsCard {
                    Text("Before creating")
                        .font(.headline)
                    aviInfoRow(
                        title: "Choose a focused occasion",
                        detail: "Birthdays, trips, milestones, and recaps work best when the draft has one clear purpose.",
                        systemImage: "sparkles"
                    )
                    aviInfoRow(
                        title: "Use a tight media set",
                        detail: "Pick the strongest clips and photos first. The create flow can keep the order clean for the story draft.",
                        systemImage: "photo.on.rectangle"
                    )
                    aviInfoRow(
                        title: "Preview before final export",
                        detail: "Previews are for checking pacing and story. Final render is the credit-committing step.",
                        systemImage: "play.rectangle"
                    )

                    actionRow(
                        title: "Prepare a new video",
                        detail: "Open the create flow when the occasion and media set are ready.",
                        systemImage: "plus.app",
                        buttonTitle: "Open Create"
                    ) {
                        selectTab(.create)
                    }
                }

                AVSettingsCard {
                    Text("Current focus")
                        .font(.headline)
                    aviInfoRow(
                        title: viewModel.workflowFocusTitle,
                        detail: viewModel.workflowFocusMessage,
                        systemImage: viewModel.projectSummary.inProgressCount > 0 ? "clock.badge.checkmark" : "sparkles"
                    )

                    HStack(spacing: 10) {
                        AVAviStatPill(
                            title: "Active",
                            value: "\(viewModel.projectSummary.inProgressCount)",
                            systemImage: "clock"
                        )
                        AVAviStatPill(
                            title: "Finished",
                            value: "\(viewModel.projectSummary.finishedCount)",
                            systemImage: "checkmark.circle"
                        )
                        AVAviStatPill(
                            title: "Credits",
                            value: "\(viewModel.creditBalance.spendable)",
                            systemImage: "creditcard"
                        )
                    }
                }

                AVSettingsCard {
                    Text("Credit guidance")
                        .font(.headline)
                    HStack(spacing: 10) {
                        AVAviStatPill(title: "First", value: "Monthly", systemImage: "calendar")
                        AVAviStatPill(title: "Then", value: "Bonus", systemImage: "gift")
                        AVAviStatPill(title: "Then", value: "Paid", systemImage: "creditcard")
                    }
                    Text(viewModel.creditGuidanceMessage)
                        .foregroundStyle(.secondary)
                }

                AVSettingsCard {
                    Text("How Avi helps")
                        .font(.headline)
                    aviInfoRow(
                        title: "Draft",
                        detail: "Turns the occasion, tone, template, and selected media into a scene outline.",
                        systemImage: "text.quote"
                    )
                    aviInfoRow(
                        title: "Preview",
                        detail: "Helps validate pacing and story shape before credits are committed to the final export.",
                        systemImage: "rectangle.inset.filled.and.person.filled"
                    )
                    aviInfoRow(
                        title: "Project review",
                        detail: "Points you back to story scenes, render jobs, and artifacts when a project needs inspection.",
                        systemImage: "rectangle.stack"
                    )
                }

                AVSettingsCard {
                    Text("Project guidance")
                        .font(.headline)
                    aviInfoRow(
                        title: "In progress",
                        detail: "Use Projects to check story scenes, preview artifacts, and render jobs while a video is moving through the workflow.",
                        systemImage: "clock"
                    )
                    aviInfoRow(
                        title: "Finished",
                        detail: "Completed projects keep the final export artifact visible in the workspace detail.",
                        systemImage: "checkmark.circle"
                    )
                    Button {
                        selectTab(.projects)
                    } label: {
                        Label("Open Projects", systemImage: "rectangle.stack")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .background(MomentsTheme.canvas.ignoresSafeArea())
        .navigationTitle("Avi")
    }

    private func aviInfoRow(title: String, detail: String, systemImage: String) -> some View {
        AVAviInfoRow(
            title: title,
            detail: detail,
            systemImage: systemImage,
            accessibilityIdentifier: "moments.avi.\(title.lowercased().replacingOccurrences(of: " ", with: "."))"
        )
    }

    private func actionRow(
        title: String,
        detail: String,
        systemImage: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            aviInfoRow(title: title, detail: detail, systemImage: systemImage)
            Button(action: action) {
                Label(buttonTitle, systemImage: systemImage)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(MomentsTheme.brandPalette.accent)
        }
    }
}
