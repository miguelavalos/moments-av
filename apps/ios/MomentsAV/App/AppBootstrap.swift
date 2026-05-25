import AVLaunchFoundation
import SwiftUI

struct MomentsAppBootstrapView: View {
    @StateObject private var dependencies = MomentsDependencyContainer()
    @State private var selectedTab: MomentsRootTab = .home
    @State private var authOptionsArePresented = false
    @State private var authenticationWasSkipped = false
    @State private var didApplyLaunchTab = false
    @State private var postAuthenticationSplashIsPresented = false

    private let launchContext = MomentsLaunchContext.current
    private var splashPolicy: AVSplashTransitionPolicy {
        AVSplashTransitionPolicy(isDisabled: launchContext.shouldDisableSplash)
    }

    var body: some View {
        Group {
            if dependencies.accountController.isSignedIn || authenticationWasSkipped {
                MomentsAppShellView(
                    selectedTab: $selectedTab,
                    startSignInFlow: startSignInFlow
                )
                .id(dependencies.accountController.isSignedIn ? "signed-in-shell" : "skipped-auth-shell")
                .avSplashTransition(policy: splashPolicy) {
                    MomentsAVSplashView()
                }
                .overlay {
                    if postAuthenticationSplashIsPresented {
                        MomentsAVSplashView()
                            .transition(.opacity)
                            .zIndex(2)
                    }
                }
            } else {
                MomentsAuthOnboardingView(
                    authOptionsArePresented: $authOptionsArePresented,
                    accountIsAvailable: dependencies.accountController.isAccountAvailable,
                    onContinueWithApple: startAppleSignIn,
                    onContinueWithGoogle: startGoogleSignIn,
                    onSkip: skipAuthentication
                )
            }
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
        postAuthenticationSplashIsPresented = true
        authenticationWasSkipped = true
        Task {
            try? await Task.sleep(for: splashPolicy.displayDuration)
            await MainActor.run {
                withAnimation(splashPolicy.dismissAnimation) {
                    postAuthenticationSplashIsPresented = false
                }
            }
        }
    }

    private func startSignInFlow() {
        postAuthenticationSplashIsPresented = false
        authenticationWasSkipped = false
        authOptionsArePresented = true
    }

    private func startAppleSignIn() async throws {
        try await dependencies.accountController.signInWithApple()
        authenticationWasSkipped = false
        authOptionsArePresented = false
    }

    private func startGoogleSignIn() async throws {
        try await dependencies.accountController.signInWithGoogle()
        authenticationWasSkipped = false
        authOptionsArePresented = false
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
