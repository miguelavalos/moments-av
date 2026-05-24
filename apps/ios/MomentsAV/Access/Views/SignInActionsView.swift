import SwiftUI

struct SignInActionsView<AuthenticationController>: View where AuthenticationController: ObservableObject & MomentsAuthenticationControlling {
    @ObservedObject var authenticationController: AuthenticationController

    var body: some View {
        VStack(spacing: 10) {
            Button {
                authenticationController.signInWithApple()
            } label: {
                Label("Continue with Apple", systemImage: "apple.logo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                authenticationController.signInWithGoogle()
            } label: {
                Label("Continue with Google", systemImage: "globe")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .disabled(authenticationController.isAuthenticationBusy || !authenticationController.isAuthenticationAvailable)
    }
}
