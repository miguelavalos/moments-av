import AVAppShellFoundation
import AVBrandFoundation
import AVSettingsFoundation
import PhotosUI
import SwiftUI

struct MomentsAppShellView: View {
    @Binding var selectedTab: MomentsRootTab
    let startSignInFlow: () -> Void

    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var createViewModel: MomentsCreateViewModel
    @EnvironmentObject private var projectsViewModel: MomentsProjectsViewModel
    @EnvironmentObject private var aviViewModel: MomentsAviViewModel
    @Environment(\.avCommonAppExperience) private var appExperience
    @State private var chromeItem: AVAppShellChromeItem?
    @State private var creditsPaywallIsPresented = false
    @State private var newMomentPickerItems: [PhotosPickerItem] = []
    @State private var navigationPath = NavigationPath()
    @State private var navigationStackResetID = UUID()

    var body: some View {
        AVAppShellConfiguredScaffold(
            selectedTabID: footerSelectedTab,
            tabs: MomentsRootTab.footerTabs.map(\.shellTab),
            assistantID: .avi,
            assistant: footerAssistant,
            hasAssistantActiveContext: selectedTab != .avi && hasAviActiveContext,
            footerConfiguration: appExperience.footerConfiguration,
            onSelectTab: { tab in
                chromeItem = nil
                selectRootTab(tab)
            },
            onSelectAssistant: {
                chromeItem = nil
                if createViewModel.hasRecoverableMomentContext {
                    selectRootTab(.create)
                } else {
                    selectRootTab(.avi)
                }
            },
            content: {
                NavigationStack(path: $navigationPath) {
                    screen(for: selectedTab)
                }
                .id(navigationStackResetID)
                .safeAreaPadding(.bottom, selectedTab == .create ? 132 : 96)
            },
            footerPlayer: {
                EmptyView()
            }
        )
        .overlay(alignment: .bottomTrailing) {
            if showsNewMomentFloatingAction {
                Button {
                    startOrContinueMoment()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AVBrandColor.textInverse)
                        .frame(width: 58, height: 58)
                        .background(
                            Circle()
                                .fill(AVBrandColor.accent)
                        )
                        .shadow(color: AVBrandColor.accent.opacity(0.24), radius: 16, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("New Moment")
                .padding(.trailing, 28)
                .padding(.bottom, 104)
            }
        }
        .sheet(isPresented: $creditsPaywallIsPresented) {
            MomentsCreditsPaywallView(
                balance: accountController.creditBalance,
                isSignedIn: accountController.isSignedIn,
                startSignInFlow: startSignInFlow,
                claimPromotionCode: accountController.claimPromotionCode,
                dismiss: { creditsPaywallIsPresented = false }
            )
        }
    }

    private var footerAssistant: AVAppShellConfiguredAssistant {
        AVAppShellConfiguredAssistant(
            experience: appExperience,
            accessibilityIdentifier: "moments.tab.avi",
            activeContextSystemImage: "video.fill"
        )
    }

    @ViewBuilder
    private func screen(for tab: MomentsRootTab) -> some View {
        if let chromeItem {
            MomentsProfileScreen(
                mode: chromeItem,
                openSettings: { self.chromeItem = .settings },
                openAccount: { self.chromeItem = .account },
                openCredits: openCredits,
                startSignInFlow: startSignInFlow
            )
        } else {
            switch tab {
            case .home:
                MomentsHomeScreen(
                    openSettings: { chromeItem = .settings },
                    openAccount: { chromeItem = .account },
                    startSignInFlow: startSignInFlow,
                    openCredits: openCredits,
                    selectTab: selectRootTab,
                    startMoment: startOrContinueMoment,
                    continueProject: { request in
                        createViewModel.continueProject(request.project, focus: request.focus)
                        selectRootTab(.create)
                    }
                )
            case .create:
                MomentsCreateScreen(
                    startSignInFlow: startSignInFlow,
                    openCredits: openCredits,
                    cancelCreation: cancelCreation
                )
            case .projects:
                MomentsProjectsScreen(
                    balance: accountController.creditBalance,
                    continueProject: { request in
                        createViewModel.continueProject(request.project, focus: request.focus)
                        selectedTab = .create
                    },
                    startProject: {
                        startOrContinueMoment()
                    },
                    startSignInFlow: startSignInFlow,
                    openCredits: openCredits
                )
            case .avi:
                MomentsAviScreen(
                    selectTab: selectRootTab,
                    startMoment: startOrContinueMoment,
                    startSignInFlow: startSignInFlow
                )
                    .environmentObject(aviViewModel)
            case .profile:
                EmptyView()
            }
        }
    }

    private func openCredits() {
        guard accountController.isSignedIn else {
            startSignInFlow()
            return
        }

        creditsPaywallIsPresented = true
    }

    private var footerSelectedTab: MomentsRootTab {
        guard chromeItem == nil else { return .profile }
        return selectedTab == .create ? .projects : selectedTab
    }

    private var showsNewMomentFloatingAction: Bool {
        chromeItem == nil
            && selectedTab == .projects
            && accountController.isSignedIn
            && (createViewModel.hasMomentWorkspace
                || projectsViewModel.projectSummary.latestInProgressProject != nil
                || createViewModel.canBeginNewProject)
    }

    private var hasAviActiveContext: Bool {
        createViewModel.hasRecoverableMomentContext
    }

    private func cancelCreation() {
        createViewModel.clearSessionState()
        selectRootTab(.projects)
    }

    private func startOrContinueMoment() {
        if createViewModel.hasMomentWorkspace {
            selectRootTab(.create)
            return
        }

        if let activeProject = projectsViewModel.projectSummary.latestInProgressProject {
            createViewModel.continueProject(activeProject)
            selectRootTab(.create)
            return
        }

        if createViewModel.canBeginNewProject {
            createViewModel.beginNewProject(openMediaPicker: true)
        }
        selectRootTab(.create)
    }

    private func selectRootTab(_ tab: MomentsRootTab) {
        navigationPath = NavigationPath()
        navigationStackResetID = UUID()
        selectedTab = tab
    }
}
