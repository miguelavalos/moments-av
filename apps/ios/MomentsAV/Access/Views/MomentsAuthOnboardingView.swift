import AVSettingsFoundation
import SwiftUI
import os

struct MomentsAuthOnboardingView: View {
    @Binding var authOptionsArePresented: Bool
    let accountIsAvailable: Bool
    let onContinueWithApple: () async throws -> Void
    let onContinueWithGoogle: () async throws -> Void
    let onSkip: () -> Void

    @StateObject private var signInCoordinator = AVAuthSignInCoordinator()

    private let authLogger = Logger(subsystem: "com.avalsys.momentsav", category: "auth")

    var body: some View {
        AVAuthConfiguredOnboardingScreen(
            authOptionsArePresented: $authOptionsArePresented,
            primaryAction: accountIsAvailable ? showAuthOptions : onSkip,
            secondaryAction: onSkip,
            brandWidth: 160,
            ctaCompanionOffset: CGSize(width: -2, height: -112),
            authPanel: {
                MomentsAuthOptionsPanel(
                    accountIsAvailable: accountIsAvailable,
                    activeProvider: signInCoordinator.activeProvider,
                    onAppleTap: startAppleSignIn,
                    onGoogleTap: startGoogleSignIn,
                    onSkip: onSkip
                )
            }
        )
        .alert("Unable to continue", isPresented: $signInCoordinator.isShowingError) {
            Button("Close", role: .cancel) {}
        } message: {
            Text(signInCoordinator.errorMessage)
        }
        .onDisappear {
            signInCoordinator.cancel()
        }
    }

    private func showAuthOptions() {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            authOptionsArePresented = true
        }
    }

    private func startAppleSignIn() {
        startSignIn(provider: .apple, operation: onContinueWithApple)
    }

    private func startGoogleSignIn() {
        startSignIn(provider: .google, operation: onContinueWithGoogle)
    }

    private func startSignIn(provider: AVAuthProvider, operation: @escaping () async throws -> Void) {
        signInCoordinator.start(
            provider: provider,
            isAvailable: accountIsAvailable,
            unavailableMessage: "Account services are unavailable right now.",
            operation: operation,
            onSuccess: {
                authOptionsArePresented = false
            },
            onFailure: logAuthError
        )
    }

    private func logAuthError(_ error: Error, provider: AVAuthProvider) {
        let nsError = error as NSError
        let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
        let underlyingDomain = underlyingError?.domain ?? "none"
        let underlyingCode = underlyingError?.code ?? 0
        let providerName = provider == .apple ? "apple" : "google"
        authLogger.error(
            "Account AV \(providerName, privacy: .public) failed domain=\(nsError.domain, privacy: .public) code=\(nsError.code, privacy: .public) underlying_domain=\(underlyingDomain, privacy: .public) underlying_code=\(underlyingCode, privacy: .public)"
        )
    }
}

private struct MomentsAuthOptionsPanel: View {
    let accountIsAvailable: Bool
    let activeProvider: AVAuthProvider?
    let onAppleTap: () -> Void
    let onGoogleTap: () -> Void
    let onSkip: () -> Void
    @Environment(\.avCommonAppExperience) private var appExperience

    var body: some View {
        AVAuthOptionsPanel(
            title: "Connect your account",
            subtitle: "Use your AV account to continue across devices.",
            legalConsentText: legalConsentText,
            unavailableMessage: unavailableMessage,
            skipTitle: "Skip for now",
            appleTitle: "Continue with Apple",
            googleTitle: "Continue with Google",
            isBusy: activeProvider != nil,
            activeProvider: activeProvider,
            isAvailable: accountIsAvailable,
            appleAccessibilityIdentifier: "moments.onboarding.auth.apple",
            googleAccessibilityIdentifier: "moments.onboarding.auth.google",
            onApple: onAppleTap,
            onGoogle: onGoogleTap,
            onSkip: onSkip
        ) {
            AVAuthConfiguredCompanionArtwork(
                placement: .authPanel,
                imageWidth: 126,
                imageHeight: 126,
                frameWidth: 140,
                frameHeight: 110,
                imageOffset: CGSize(width: 0, height: -5),
                groundShadowColor: nil
            )
                .offset(x: -44, y: -91)
                .allowsHitTesting(false)
        }
    }

    private var legalConsentText: AttributedString {
        let termsURL = appExperience.legalLinks.termsURL?.absoluteString ?? AppConfig.termsURL.absoluteString
        let privacyURL = appExperience.legalLinks.privacyURL?.absoluteString ?? AppConfig.privacyPolicyURL.absoluteString
        let markdown = "By continuing, you agree to the [Terms](\(termsURL)) and [Privacy Policy](\(privacyURL)) of Moments AV."
        return (try? AttributedString(markdown: markdown)) ?? AttributedString("By continuing, you agree to the Terms and Privacy Policy of Moments AV.")
    }

    private var unavailableMessage: String? {
        if !accountIsAvailable {
            return "Account services are unavailable right now."
        }
        return nil
    }
}
