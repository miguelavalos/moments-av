import AVBrandFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsAuthOnboardingView: View {
    @Binding var authOptionsArePresented: Bool
    @ObservedObject var accountController: AccountController

    var body: some View {
        AVAuthConfiguredOnboardingScreen(
            authOptionsArePresented: $authOptionsArePresented,
            primaryAction: {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                    authOptionsArePresented = true
                }
            },
            authPanel: {
                MomentsAuthOptionsPanel(accountController: accountController)
            }
        )
    }
}

private struct MomentsAuthOptionsPanel: View {
    @ObservedObject var accountController: AccountController
    @Environment(\.avCommonAppExperience) private var appExperience

    var body: some View {
        AVAuthOptionsPanel(
            title: "Sign in to Moments AV",
            subtitle: "Projects, credits, previews, and final exports stay attached to your account.",
            legalConsentText: legalConsentText,
            unavailableMessage: unavailableMessage,
            isBusy: accountController.isBusy,
            isAvailable: accountController.isAccountAvailable,
            appleAccessibilityIdentifier: "moments.onboarding.auth.apple",
            googleAccessibilityIdentifier: "moments.onboarding.auth.google",
            onApple: accountController.signInWithApple,
            onGoogle: accountController.signInWithGoogle
        ) {
            AVAuthConfiguredCompanionArtwork(
                placement: .authPanel,
                imageWidth: 112,
                imageHeight: 112,
                frameWidth: 124,
                frameHeight: 128
            )
                .frame(width: 140, height: 110)
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
