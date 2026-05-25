import AVLaunchFoundation
import SwiftUI

struct MomentsAppBootstrapView: View {
    @StateObject private var dependencies = MomentsDependencyContainer()
    @State private var selectedTab: MomentsRootTab = .home
    @State private var authOptionsArePresented = false
    @State private var authenticationWasSkipped = false
    @State private var didApplyLaunchTab = false

    private let launchContext = MomentsLaunchContext.current
    private var splashPolicy: AVSplashTransitionPolicy {
        AVSplashTransitionPolicy(isDisabled: launchContext.shouldDisableSplash)
    }

    var body: some View {
        Group {
            if dependencies.accountController.isSignedIn || authenticationWasSkipped {
                MomentsAppShellView(selectedTab: $selectedTab)
            } else {
                MomentsAuthOnboardingView(
                    authOptionsArePresented: $authOptionsArePresented,
                    accountController: dependencies.accountController,
                    onSkip: skipAuthentication
                )
            }
        }
        .avSplashTransition(policy: splashPolicy) {
            MomentsAVSplashView()
        }
        .environmentObject(dependencies.accountController)
        .environmentObject(dependencies.projectsListWorkflow)
        .environmentObject(dependencies.homeViewModel)
        .environmentObject(dependencies.createViewModel)
        .environmentObject(dependencies.projectsViewModel)
        .environmentObject(dependencies.aviViewModel)
        .task {
            applyLaunchTabIfNeeded()
            dependencies.applyUITestFixturesIfNeeded()
            await Task.yield()
            dependencies.applyUITestFixturesIfNeeded()
        }
        .onReceive(dependencies.accountController.currentUserIdPublisher) { ownerUserId in
            dependencies.handleAccountChange(ownerUserId: ownerUserId)
        }
    }

    private func applyLaunchTabIfNeeded() {
        guard !didApplyLaunchTab else { return }
        didApplyLaunchTab = true
        guard let preferredTab = launchContext.preferredTab else { return }
        selectedTab = MomentsRootTab(preferredTab)
    }

    private func skipAuthentication() {
        authOptionsArePresented = false
        authenticationWasSkipped = true
    }
}

private extension MomentsRootTab {
    init(_ launchTab: MomentsLaunchContext.Tab) {
        switch launchTab {
        case .home:
            self = .home
        case .create:
            self = .create
        case .projects:
            self = .projects
        case .avi:
            self = .avi
        }
    }
}
