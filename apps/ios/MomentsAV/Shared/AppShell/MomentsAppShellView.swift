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
    @EnvironmentObject private var aviViewModel: MomentsAviViewModel
    @Environment(\.avCommonAppExperience) private var appExperience
    @State private var chromeItem: AVAppShellChromeItem?
    @State private var creditsPaywallIsPresented = false
    @State private var newMomentPickerItems: [PhotosPickerItem] = []

    var body: some View {
        AVAppShellConfiguredScaffold(
            selectedTabID: footerSelectedTab,
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
        .overlay(alignment: .bottomTrailing) {
            if showsNewMomentFloatingAction {
                PhotosPicker(
                    selection: $newMomentPickerItems,
                    maxSelectionCount: createViewModel.form.template.maximumAssets,
                    matching: .any(of: [.images, .videos])
                ) {
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
                .onChange(of: newMomentPickerItems) { _, newItems in
                    guard !newItems.isEmpty else { return }
                    createViewModel.beginNewProject(openMediaPicker: false)
                    createViewModel.importPickerItems(newItems)
                    newMomentPickerItems = []
                    selectedTab = .create
                }
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
            accessibilityIdentifier: "moments.tab.avi"
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
                    selectTab: { selectedTab = $0 },
                    continueProject: { request in
                        createViewModel.continueProject(request.project, focus: request.focus)
                        selectedTab = .create
                    }
                )
            case .create:
                MomentsCreateScreen(
                    startSignInFlow: startSignInFlow,
                    openCredits: openCredits
                )
            case .projects:
                MomentsProjectsScreen(
                    continueProject: { request in
                        createViewModel.continueProject(request.project, focus: request.focus)
                        selectedTab = .create
                    },
                    startProject: {
                        createViewModel.beginNewProject()
                        selectedTab = .create
                    }
                )
            case .avi:
                MomentsAviScreen { selectedTab = $0 }
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
        chromeItem == nil ? selectedTab : .profile
    }

    private var showsNewMomentFloatingAction: Bool {
        chromeItem == nil && selectedTab == .projects
    }
}
