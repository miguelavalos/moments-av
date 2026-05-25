import AVSettingsFoundation
import SwiftUI

struct SignInActionsView<AuthenticationController>: View where AuthenticationController: ObservableObject & MomentsAuthenticationControlling {
    @ObservedObject var authenticationController: AuthenticationController

    var body: some View {
        AVSettingsSignInActions(
            isBusy: authenticationController.isAuthenticationBusy,
            isAvailable: authenticationController.isAuthenticationAvailable,
            appleAccessibilityIdentifier: "moments.auth.apple",
            googleAccessibilityIdentifier: "moments.auth.google",
            onApple: authenticationController.signInWithApple,
            onGoogle: authenticationController.signInWithGoogle
        )
    }
}
