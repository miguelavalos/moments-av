import AVAviFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAviScreen: View {
    let selectTab: (MomentsRootTab) -> Void
    @Environment(\.avCommonAppExperience) private var appExperience
    @EnvironmentObject private var viewModel: MomentsAviViewModel

    private var presentation: MomentsAviPresentation {
        viewModel.presentation
    }

    private var landingContent: AVAviLandingContent {
        AVAviLandingContent(
            eyebrow: "Moments guide",
            title: "Keep projects moving",
            detail: "Check draft structure, preview readiness, render status, and credit decisions before the final export.",
            chips: [
                AVAviLandingChip(title: "Draft", systemImage: "text.quote"),
                AVAviLandingChip(title: "Preview", systemImage: "play.rectangle"),
                AVAviLandingChip(title: "Export", systemImage: "square.and.arrow.up")
            ],
            accessibilityIdentifier: "moments.avi.hero"
        )
    }

    var body: some View {
        AVAviGuidanceScreenScaffold(
            identity: appExperience.identity,
            summary: "Guidance for story drafts, previews, final renders, and project review.",
            status: "Guide",
            headerAccessibilityIdentifier: "moments.avi.header",
            landingContent: landingContent,
            backgroundStyle: AnyShapeStyle(MomentsTheme.shellBackground)
        ) {
            EmptyView()
        } heroAvatar: {
            Image("AviFullBody")
                .resizable()
                .scaledToFit()
                .frame(width: 82, height: 82)
                .accessibilityLabel("Avi")
        } content: {
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
