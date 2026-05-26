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
    private let balanceClient: MomentsCreditBalanceClient

    init(
        service: AVAccountService = DefaultAVAccountService(),
        balanceClient: MomentsCreditBalanceClient? = nil
    ) {
        self.service = service
        self.balanceClient = balanceClient ?? MomentsCreditBalanceClient(baseURLString: AppConfig.momentsAPIBaseURL)
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
        } else {
            Task { await refreshCreditBalance() }
        }
    }

    func syncFromAccountProvider() async {
        user = service.currentUser
        if user == nil {
            do {
                _ = try await service.getToken()
                user = service.currentUser
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        if user == nil {
            creditBalance = .empty
        } else {
            await refreshCreditBalance()
        }
    }

    func signInWithApple() async throws {
        try await runAuthOperation {
            try await service.signInWithApple()
        }
    }

    func signInWithGoogle() async throws {
        try await runAuthOperation {
            try await service.signInWithGoogle()
        }
    }

    func signOut() {
        startAuthTask { [self] in
            try await self.service.signOut()
            self.user = nil
            self.creditBalance = .empty
        }
    }

    func claimPromotionCode(_ code: String) {
        let normalizedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isSignedIn, !normalizedCode.isEmpty else { return }

        creditBalance.promotional += 1
    }

    func refreshCreditBalance() async {
        guard let user else {
            creditBalance = .empty
            return
        }

        do {
            let token = try await service.getToken() ?? user.id
            creditBalance = try await balanceClient.fetchBalance(bearerToken: token)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startAuthTask(_ operation: @escaping () async throws -> Void) {
        Task {
            do {
                try await runAuthOperation(operation)
            } catch {
                // Interactive sign-in surfaces report their own errors.
            }
        }
    }

    private func runAuthOperation(_ operation: () async throws -> Void) async throws {
        guard !isBusy else { return }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            try await operation()
            await syncFromAccountProvider()
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
}

struct MomentsCreditBalanceClient {
    var baseURLString: String
    var session: URLSession = .shared

    func fetchBalance(bearerToken: String) async throws -> MomentsCreditBalance {
        guard let url = URL(string: "\(baseURLString)/v1/apps/momentsav/credits/balance") else {
            throw MomentsAPIError(code: "invalid_moments_api_url", message: "Moments AV API URL is not configured.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_credit_balance_failed",
                fallbackMessage: "Moments AV credit balance could not be loaded."
            )
        }

        let decoded = try JSONDecoder().decode(MomentsCreditBalanceResponse.self, from: data)
        return MomentsCreditBalance(
            proMonthly: decoded.proMonthlyCredits,
            promotional: decoded.promotionalGrantedCredits,
            purchased: decoded.purchasedCredits
        )
    }
}

private struct MomentsCreditBalanceResponse: Decodable {
    let proMonthlyCredits: Int
    let promotionalGrantedCredits: Int
    let purchasedCredits: Int
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
