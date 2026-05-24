import AccountAV
import Combine
import Foundation

@MainActor
final class AccountController: ObservableObject {
    @Published private(set) var user: AccountAVUser?
    @Published private(set) var creditBalance = MomentsCreditBalance.empty
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
        if user == nil {
            creditBalance = .empty
        }
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

extension AccountController: MomentsCurrentUserProviding, MomentsCreditBalanceProviding, MomentsAccountStateProviding, MomentsAuthenticationControlling {
    var currentUserId: String? {
        user?.id
    }

    var currentCreditBalance: MomentsCreditBalance {
        creditBalance
    }

    var isAuthenticationBusy: Bool {
        isBusy
    }

    var isAuthenticationAvailable: Bool {
        isAccountAvailable
    }

    var isSignedInPublisher: AnyPublisher<Bool, Never> {
        $user
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }

    var currentUserIdPublisher: AnyPublisher<String?, Never> {
        $user
            .map(\.?.id)
            .eraseToAnyPublisher()
    }

    var displayNamePublisher: AnyPublisher<String?, Never> {
        $user
            .map(\.?.displayName)
            .eraseToAnyPublisher()
    }

    var creditBalancePublisher: AnyPublisher<MomentsCreditBalance, Never> {
        $creditBalance.eraseToAnyPublisher()
    }
}
