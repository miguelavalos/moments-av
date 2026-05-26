import AVAviFoundation
import AVAppShellFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsHomeScreen: View {
    @EnvironmentObject private var viewModel: MomentsHomeViewModel

    let openSettings: () -> Void
    let openAccount: () -> Void
    let selectTab: (MomentsRootTab) -> Void
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
        selectTab: @escaping (MomentsRootTab) -> Void,
        continueProject: @escaping (MomentsProjectContinuationRequest) -> Void
    ) {
        self.openSettings = openSettings
        self.openAccount = openAccount
        self.selectTab = selectTab
        self.continueProject = continueProject
    }

    var body: some View {
        AVAppShellScrollableScreenScaffold {
            MomentsTheme.shellBackground
        } content: {
            AVAppShellHomeHeader(
                title: "Moments AV",
                subtitle: "Create private memory films from selected media, then track every project from draft to final export."
            ) {
                AVAppShellConfiguredBrandHeader(
                    activeItem: nil,
                    openSettings: openSettings,
                    openAccount: openAccount
                )
            } content: {
                AVAviHomeBriefCard(
                    identity: appExperience.identity,
                    detail: presentation.aviBriefDetail,
                    actionAccessibilityLabel: "Open Avi guidance",
                    accessibilityIdentifier: "moments.home.aviBrief.open",
                    openAvi: { selectTab(.avi) }
                ) {
                    Image("AviFullBody")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 54, height: 68)
                        .accessibilityHidden(true)
                }
            }

            if viewModel.isSignedIn {
                MomentsHomeAccountCard(
                    creditBalance: viewModel.creditBalance,
                    projectSummary: projectSummary,
                    presentation: presentation
                )
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
                selectTab: selectTab
            )
        }
    }

    @Environment(\.avCommonAppExperience) private var appExperience
}
