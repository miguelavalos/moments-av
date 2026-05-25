import AVBrandFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAuthOnboardingView: View {
    @Binding var authOptionsArePresented: Bool
    @ObservedObject var accountController: AccountController
    let onSkip: () -> Void

    var body: some View {
        AVAuthConfiguredOnboardingScreen(
            authOptionsArePresented: $authOptionsArePresented,
            primaryAction: accountController.isAccountAvailable ? showAuthOptions : onSkip,
            secondaryAction: onSkip,
            brandWidth: 160,
            ctaCompanionOffset: CGSize(width: -2, height: -112),
            authPanel: {
                MomentsAuthOptionsPanel(
                    accountController: accountController,
                    onSkip: onSkip
                )
            }
        )
    }

    private func showAuthOptions() {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
            authOptionsArePresented = true
        }
    }
}

private struct MomentsAuthOptionsPanel: View {
    @ObservedObject var accountController: AccountController
    let onSkip: () -> Void
    @Environment(\.avCommonAppExperience) private var appExperience

    var body: some View {
        AVAuthOptionsPanel(
            title: "Sign in to Moments AV",
            subtitle: "Projects, credits, previews, and final exports stay attached to your account.",
            legalConsentText: legalConsentText,
            unavailableMessage: unavailableMessage,
            skipTitle: "Skip",
            appleTitle: "Continue with Apple",
            googleTitle: "Continue with Google",
            isBusy: accountController.isBusy,
            isAvailable: accountController.isAccountAvailable,
            appleAccessibilityIdentifier: "moments.onboarding.auth.apple",
            googleAccessibilityIdentifier: "moments.onboarding.auth.google",
            onApple: accountController.signInWithApple,
            onGoogle: accountController.signInWithGoogle,
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
        AVAuthLegalConsentText.make(
            identity: appExperience.identity,
            legalLinks: appExperience.legalLinks,
            textColor: AVBrandColor.ink.opacity(0.66)
        )
    }

    private var unavailableMessage: String? {
        if let errorMessage = accountController.errorMessage {
            return errorMessage
        }
        if !accountController.isAccountAvailable {
            return "Account services are unavailable right now."
        }
        return nil
    }
}
