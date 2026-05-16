import AccountAV
import Foundation

@MainActor
final class AccountController: ObservableObject {
    @Published private(set) var user: AccountAVUser?
    @Published private(set) var isBusy = false
    @Published var errorMessage: String?

    private let service: AVAccountService

    init(service: AVAccountService = DefaultAVAccountService()) {
        self.service = service
        refresh()
    }

    var isAccountAvailable: Bool {
        service.isAvailable
    }

    var isSignedIn: Bool {
        user != nil
    }

    func refresh() {
        user = service.currentUser
    }

    func signInWithApple() {
        startAuthTask { [self] in
            try await self.service.signInWithApple()
        }
    }

    func signInWithGoogle() {
        startAuthTask { [self] in
            try await self.service.signInWithGoogle()
        }
    }

    func signOut() {
        startAuthTask { [self] in
            try await self.service.signOut()
        }
    }

    private func startAuthTask(_ operation: @escaping () async throws -> Void) {
        guard !isBusy else { return }
        isBusy = true
        errorMessage = nil

        Task {
            do {
                try await operation()
                refresh()
            } catch {
                errorMessage = error.localizedDescription
            }
            isBusy = false
        }
    }
}
