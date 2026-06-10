import AVLaunchFoundation
import AVProductAccountFoundation
import SwiftUI

struct MomentsAppBootstrapView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var dependencies = MomentsDependencyContainer()
    @State private var selectedTab: MomentsRootTab = .home
    @State private var authPresentationState: AVProductAccountAuthPresentationState = .hidden
    @State private var authenticationWasSkipped = false
    @State private var initialAccountRestoreCompleted = false
    @State private var didApplyLaunchTab = false
    @State private var postAuthenticationSplashIsPresented = false

    private let launchContext = MomentsLaunchContext.current
    private var splashPolicy: AVSplashTransitionPolicy {
        AVSplashTransitionPolicy(isDisabled: launchContext.shouldDisableSplash)
    }

    var body: some View {
        Group {
            if shouldShowOnboarding {
                MomentsAuthOnboardingView(
                    authPresentationState: $authPresentationState,
                    accountIsAvailable: dependencies.accountController.isAccountAvailable,
                    onContinueWithApple: startAppleSignIn,
                    onContinueWithGoogle: startGoogleSignIn,
                    onSkip: skipAuthentication
                )
            } else {
                MomentsAppShellView(
                    selectedTab: $selectedTab,
                    startSignInFlow: { startSignInFlow(showAuthOptions: true) }
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
            }
        }
        .environmentObject(dependencies.accountController)
        .environmentObject(dependencies.inProgressMomentsWorkflow)
        .environmentObject(dependencies.homeViewModel)
        .environmentObject(dependencies.createViewModel)
        .environmentObject(dependencies.inProgressViewModel)
        .environmentObject(dependencies.galleryViewModel)
        .environmentObject(dependencies.aviViewModel)
        .task {
            applyLaunchTabIfNeeded()
            await restoreInitialAccountSessionIfNeeded()
            dependencies.applyUITestFixturesIfNeeded()
            await Task.yield()
            dependencies.applyUITestFixturesIfNeeded()
            showInitialOnboardingAfterRestoreIfNeeded()
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            await dependencies.accountController.syncFromAccountProvider()
            initialAccountRestoreCompleted = true
        }
        .onReceive(dependencies.accountController.currentUserIdPublisher) { ownerUserId in
            dependencies.handleAccountChange(ownerUserId: ownerUserId)
        }
    }

    private var shouldShowOnboarding: Bool {
        guard !authenticationWasSkipped else { return false }
        let rootGate = AVProductAccountAuthFlowRootGate(
            accountState: dependencies.accountController.productAccountState,
            authPresentationState: authPresentationState
        )
        return rootGate.shouldShowOnboarding
    }

    private func restoreInitialAccountSessionIfNeeded() async {
        guard !initialAccountRestoreCompleted else { return }
        await dependencies.accountController.syncFromAccountProvider()
        initialAccountRestoreCompleted = true
    }

    private func showInitialOnboardingAfterRestoreIfNeeded() {
        guard initialAccountRestoreCompleted else { return }
        guard !dependencies.accountController.isSignedIn else { return }
        guard !authenticationWasSkipped else { return }
        authPresentationState = .onboardingCollapsed
    }

    private func applyLaunchTabIfNeeded() {
        guard !didApplyLaunchTab else { return }
        didApplyLaunchTab = true
        guard let preferredTab = launchContext.preferredTab else { return }
        selectedTab = MomentsRootTab(preferredTab)
    }

    private func skipAuthentication() {
        authPresentationState = .hidden
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

    private func startSignInFlow(showAuthOptions: Bool = false) {
        postAuthenticationSplashIsPresented = false
        authenticationWasSkipped = false
        authPresentationState = showAuthOptions ? .onboardingOptions : .onboardingCollapsed
    }

    private func startAppleSignIn() async throws {
        try await dependencies.accountController.signInWithApple()
        await dependencies.accountController.syncFromAccountProvider()
        authenticationWasSkipped = false
        authPresentationState = .hidden
    }

    private func startGoogleSignIn() async throws {
        try await dependencies.accountController.signInWithGoogle()
        await dependencies.accountController.syncFromAccountProvider()
        authenticationWasSkipped = false
        authPresentationState = .hidden
    }
}

private extension MomentsRootTab {
    init(_ launchTab: MomentsLaunchContext.Tab) {
        switch launchTab {
        case .home:
            self = .home
        case .create:
            self = .create
        case .inProgress:
            self = .inProgress
        case .avi:
            self = .avi
        }
    }
}
