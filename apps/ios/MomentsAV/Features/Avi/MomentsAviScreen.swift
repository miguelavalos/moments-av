import AVAviFoundation
import AVAppShellFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAviScreen: View {
    let selectTab: (MomentsRootTab) -> Void
    let startMoment: () -> Void
    let startSignInFlow: () -> Void
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
                isSignedIn: viewModel.isSignedIn,
                startSignInFlow: startSignInFlow,
                startMoment: startMoment,
                selectTab: selectTab
            )
        }
    }
}

private struct MomentsAviGuidanceContent: View {
    let presentation: MomentsAviPresentation
    let projectSummary: MomentsProjectListSummary
    let creditBalance: MomentsCreditBalance
    let isSignedIn: Bool
    let startSignInFlow: () -> Void
    let startMoment: () -> Void
    let selectTab: (MomentsRootTab) -> Void

    var body: some View {
        if !isSignedIn {
            MomentsAviSignInCard(startSignInFlow: startSignInFlow)
        }

        MomentsAviPreparationCard(openCreate: startMoment)

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

private struct MomentsAviSignInCard: View {
    let startSignInFlow: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 12) {
                AVAppShellContentHeader(
                    title: "Sign in to use Avi",
                    detail: "Avi needs your account to see credits, projects, drafts, previews, and final exports."
                )

                AVAppShellActionRow(
                    title: "Sign in",
                    detail: "Connect your account and unlock project guidance.",
                    systemImage: "person.crop.circle.fill",
                    isProminent: true,
                    accessibilityIdentifier: "moments.avi.signin",
                    action: startSignInFlow
                )
            }
        }
    }
}
