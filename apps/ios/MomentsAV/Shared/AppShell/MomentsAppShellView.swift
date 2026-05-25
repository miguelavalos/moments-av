import AVAppShellFoundation
import AVBrandFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAppShellView: View {
    @Binding var selectedTab: MomentsRootTab
    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var createViewModel: MomentsCreateViewModel
    @EnvironmentObject private var aviViewModel: MomentsAviViewModel
    @Environment(\.avCommonAppExperience) private var appExperience
    @State private var chromeItem: AVAppShellChromeItem?

    var body: some View {
        AVAppShellConfiguredScaffold(
            selectedTabID: selectedTab,
            tabs: MomentsRootTab.footerTabs.map(\.shellTab),
            assistantID: .avi,
            assistant: footerAssistant,
            hasAssistantActiveContext: selectedTab != .avi && aviViewModel.projectSummary.inProgressCount > 0,
            footerConfiguration: appExperience.footerConfiguration,
            onSelectTab: { tab in
                chromeItem = nil
                selectedTab = tab
            },
            onSelectAssistant: {
                chromeItem = nil
                selectedTab = .avi
            },
            content: {
                NavigationStack {
                    screen(for: selectedTab)
                }
                .safeAreaPadding(.bottom, 96)
            },
            footerPlayer: {
                EmptyView()
            }
        )
    }

    private var footerAssistant: AVAppShellConfiguredAssistant {
        AVAppShellConfiguredAssistant(
            experience: appExperience,
            accessibilityIdentifier: "moments.tab.avi"
        )
    }

    @ViewBuilder
    private func screen(for tab: MomentsRootTab) -> some View {
        if let chromeItem {
            MomentsProfileScreen(
                mode: chromeItem,
                openSettings: { self.chromeItem = .settings },
                openAccount: { self.chromeItem = .account }
            )
        } else {
            switch tab {
            case .home:
                MomentsHomeScreen(
                    openSettings: { chromeItem = .settings },
                    openAccount: { chromeItem = .account },
                    selectTab: { selectedTab = $0 },
                    continueProject: { request in
                        createViewModel.continueProject(request.project, focus: request.focus)
                        selectedTab = .create
                    },
                    signInActions: AnyView(SignInActionsView(authenticationController: accountController))
                )
            case .create:
                MomentsCreateScreen()
            case .projects:
                MomentsProjectsScreen(
                    continueProject: { request in
                        createViewModel.continueProject(request.project, focus: request.focus)
                        selectedTab = .create
                    },
                    startProject: {
                        selectedTab = .create
                    }
                )
            case .avi:
                MomentsAviScreen { selectedTab = $0 }
                    .environmentObject(aviViewModel)
            }
        }
    }
}
