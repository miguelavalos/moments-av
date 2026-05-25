import AVAviFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAviScreen: View {
    let selectTab: (MomentsRootTab) -> Void
    @EnvironmentObject private var viewModel: MomentsAviViewModel

    private var presentation: MomentsAviPresentation {
        viewModel.presentation
    }

    private var landingContent: AVAviLandingContent {
        AVAviLandingContent(
            eyebrow: "Moments guidance",
            title: "Avi keeps videos moving",
            detail: "Use Avi as a focused guide for creating story drafts, checking previews, managing credits, and reviewing project status.",
            chips: [
                AVAviLandingChip(title: "Draft", systemImage: "text.quote"),
                AVAviLandingChip(title: "Preview", systemImage: "play.rectangle"),
                AVAviLandingChip(title: "Export", systemImage: "square.and.arrow.up")
            ],
            accessibilityIdentifier: "moments.avi.hero"
        )
    }

    var body: some View {
        AVConfiguredAviGuidanceScreen(
            summary: "Guidance for story drafts, previews, final renders, and project review.",
            status: "Guide",
            headerAccessibilityIdentifier: "moments.avi.header",
            landingContent: landingContent,
            backgroundStyle: AnyShapeStyle(MomentsTheme.shellBackground)
        ) {
            MomentsAviGuidanceContent(
                presentation: presentation,
                projectSummary: viewModel.projectSummary,
                creditBalance: viewModel.creditBalance,
                selectTab: selectTab
            )
        }
    }
}

private struct MomentsAviGuidanceContent: View {
    let presentation: MomentsAviPresentation
    let projectSummary: MomentsProjectListSummary
    let creditBalance: MomentsCreditBalance
    let selectTab: (MomentsRootTab) -> Void

    var body: some View {
        MomentsAviPreparationCard {
            selectTab(.create)
        }

        MomentsAviCurrentFocusCard(
            workflowFocusTitle: presentation.workflowFocusTitle,
            workflowFocusMessage: presentation.workflowFocusMessage,
            workflowFocusSystemImage: presentation.workflowFocusSystemImage,
            projectSummary: projectSummary,
            creditBalance: creditBalance
        )

        MomentsAviCreditGuidanceCard(message: presentation.creditGuidanceMessage)

        MomentsAviHelpCard()

        MomentsAviProjectGuidanceCard {
            selectTab(.projects)
        }
    }
}
