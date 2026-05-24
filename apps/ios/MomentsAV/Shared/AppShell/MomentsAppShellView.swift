import AVBrandFoundation
import SwiftUI

struct MomentsAppShellView: View {
    @Binding var selectedTab: MomentsRootTab
    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var createViewModel: MomentsCreateViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MomentsRootTab.allCases) { tab in
                NavigationStack {
                    screen(for: tab)
                }
                .tabItem {
                    Label(tab.shellTab.title, systemImage: tab.shellTab.systemImage)
                }
                .tag(tab)
            }
        }
        .tint(MomentsTheme.brandPalette.accent)
        .background(AVBrandColor.canvas.ignoresSafeArea())
    }

    @ViewBuilder
    private func screen(for tab: MomentsRootTab) -> some View {
        switch tab {
        case .home:
            MomentsHomeScreen(
                selectTab: { selectedTab = $0 },
                signInActions: AnyView(SignInActionsView(authenticationController: accountController))
            )
        case .create:
            MomentsCreateScreen()
        case .projects:
            MomentsProjectsScreen { project in
                createViewModel.continueProject(project)
                selectedTab = .create
            }
        case .avi:
            MomentsAviScreen { selectedTab = $0 }
        }
    }
}
