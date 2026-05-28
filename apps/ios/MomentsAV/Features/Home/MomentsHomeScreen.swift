import AVAviFoundation
import AVAppShellFoundation
import AVBrandFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsHomeScreen: View {
    @EnvironmentObject private var viewModel: MomentsHomeViewModel
    @EnvironmentObject private var createViewModel: MomentsCreateViewModel

    let openSettings: () -> Void
    let openAccount: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void
    let selectTab: (MomentsRootTab) -> Void
    let startMoment: () -> Void
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    private var projectSummary: MomentsProjectListSummary { viewModel.projectSummary }
    private var presentation: MomentsHomePresentation {
        MomentsHomePresentation.make(
            isSignedIn: viewModel.isSignedIn,
            displayName: viewModel.displayName,
            projectSummary: projectSummary
        )
    }

    init(
        openSettings: @escaping () -> Void,
        openAccount: @escaping () -> Void,
        startSignInFlow: @escaping () -> Void,
        openCredits: @escaping () -> Void,
        selectTab: @escaping (MomentsRootTab) -> Void,
        startMoment: @escaping () -> Void,
        continueProject: @escaping (MomentsProjectContinuationRequest) -> Void
    ) {
        self.openSettings = openSettings
        self.openAccount = openAccount
        self.startSignInFlow = startSignInFlow
        self.openCredits = openCredits
        self.selectTab = selectTab
        self.startMoment = startMoment
        self.continueProject = continueProject
    }

    var body: some View {
        AVAppShellScrollableScreenScaffold {
            MomentsTheme.shellBackground
        } content: {
            AVAppShellHomeHeader(
                title: "Memory Studio",
                subtitle: "Choose the media and let Avi turn it into a private memory film."
            ) {
                AVAppShellConfiguredBrandHeader(
                    activeItem: nil,
                    openSettings: openSettings,
                    openAccount: openAccount
                )
            } content: {
                MomentsHomeAviContextCard(
                    title: aviContextTitle,
                    detail: aviContextDetail,
                    buttonTitle: aviContextButtonTitle,
                    hasMomentContext: createViewModel.hasRecoverableMomentContext,
                    isSignedIn: viewModel.isSignedIn,
                    action: viewModel.isSignedIn ? startMoment : startSignInFlow
                )
            }

            if viewModel.isSignedIn {
                MomentsHomeAccountCard(
                    creditBalance: viewModel.creditBalance,
                    openCredits: openCredits
                )
            } else {
                MomentsHomeSignInCard(startSignInFlow: startSignInFlow)
            }

            MomentsHomeProjectStatusCard(
                isSignedIn: viewModel.isSignedIn,
                projectSummary: projectSummary,
                presentation: presentation,
                openProjects: { selectTab(.projects) }
            )

            MomentsHomeNextActionsCard(
                presentation: presentation,
                continueProject: continueProject,
                startMoment: startMoment,
                selectTab: selectTab
            )
        }
    }

    @Environment(\.avCommonAppExperience) private var appExperience

    private var aviContextTitle: String {
        guard viewModel.isSignedIn else { return "Sign in to create" }
        if createViewModel.hasRecoverableMomentContext {
            if createViewModel.previewSummary.latestPreview != nil {
                return "Preview ready"
            }
            if createViewModel.previewSummary.isGenerating {
                return "Avi is creating"
            }
            if createViewModel.storySummary.isDrafting {
                return "Avi is preparing"
            }
            return "Current Moment"
        }
        return "Create a Moment"
    }

    private var aviContextDetail: String {
        guard viewModel.isSignedIn else {
            return "Connect your account to create memory films, previews, and final videos."
        }
        if createViewModel.hasRecoverableMomentContext {
            let count = createViewModel.mediaSelectedCount
            if createViewModel.previewSummary.latestPreview != nil {
                return "Your preview is ready to review before final video."
            }
            if createViewModel.previewSummary.isGenerating {
                return "Avi is creating the preview from your selected moments."
            }
            if createViewModel.storySummary.isDrafting {
                return "Avi is organizing the story from your media."
            }
            if count > 0 {
                return "\(count) \(count == 1 ? "item" : "items") selected. Continue to preview."
            }
            return "A local creation is waiting for media."
        }
        return "Choose photos or clips and let Avi prepare the first version."
    }

    private var aviContextButtonTitle: String {
        guard viewModel.isSignedIn else { return "Sign in" }
        return createViewModel.hasRecoverableMomentContext ? "Continue" : "Create"
    }
}

private struct MomentsHomeAviContextCard: View {
    let title: String
    let detail: String
    let buttonTitle: String
    let hasMomentContext: Bool
    let isSignedIn: Bool
    let action: () -> Void

    private var actionSystemImage: String {
        if !isSignedIn { return "person.crop.circle" }
        return hasMomentContext ? "video.fill" : "plus"
    }

    var body: some View {
        Button(action: action) {
            AVAppShellCard {
                HStack(spacing: 14) {
                    Image("AviFullBody")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 54, height: 68)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary)

                        Text(detail)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AVBrandColor.textSecondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: actionSystemImage)
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(isSignedIn ? AVBrandColor.textInverse : AVBrandColor.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(isSignedIn ? AVBrandColor.accent : AVBrandColor.neutral100)
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("moments.home.aviContext.open")
        .accessibilityLabel("\(title). \(detail). \(buttonTitle)")
    }
}
