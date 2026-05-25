import AVAviFoundation
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

                MomentsAviPreparationCard {
                    selectTab(.create)
                }

                MomentsAviCurrentFocusCard(
                    workflowFocusTitle: viewModel.workflowFocusTitle,
                    workflowFocusMessage: viewModel.workflowFocusMessage,
                    workflowFocusSystemImage: viewModel.workflowFocusSystemImage,
                    projectSummary: viewModel.projectSummary,
                    creditBalance: viewModel.creditBalance
                )

                MomentsAviCreditGuidanceCard(message: viewModel.creditGuidanceMessage)

                MomentsAviHelpCard()

                MomentsAviProjectGuidanceCard {
                    selectTab(.projects)
                }
            }
            .padding(20)
        }
        .background(MomentsTheme.canvas.ignoresSafeArea())
        .navigationTitle("Avi")
    }
}
