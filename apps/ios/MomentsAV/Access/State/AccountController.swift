import AccountAV
import Combine
import Foundation

@MainActor
final class AccountController: ObservableObject {
    @Published private(set) var user: AccountAVUser?
    @Published private(set) var creditBalance = MomentsCreditBalance.empty
    @Published private(set) var creditBalanceLoadState = MomentsCreditBalanceLoadState.signedOut
    @Published private(set) var purchaseCatalog = MomentsPurchaseCatalog.empty
    @Published private(set) var isPurchaseCatalogLoading = false
    @Published private(set) var purchaseCatalogErrorMessage: String?
    @Published private(set) var isPurchaseInProgress = false
    @Published private(set) var isAccountSessionTemporarilyUnavailable = false
    @Published private(set) var isBusy = false
    @Published var errorMessage: String?

    private let service: AVAccountService
    private let accountProfileClient: MomentsAccountProfileClient
    private let balanceClient: MomentsCreditBalanceClient
    private let promoCodeClient: MomentsPromoCodeClient
    private let purchaseService: MomentsPurchaseServicing
    private let userDefaults: UserDefaults
    private let lastKnownAccountUserKey = "momentsav.account.lastKnownUser"

    init(
        service: AVAccountService = DefaultAVAccountService(),
        accountProfileClient: MomentsAccountProfileClient? = nil,
        balanceClient: MomentsCreditBalanceClient? = nil,
        promoCodeClient: MomentsPromoCodeClient? = nil,
        purchaseService: MomentsPurchaseServicing = RevenueCatMomentsPurchaseService(),
        userDefaults: UserDefaults = .standard
    ) {
        self.service = service
        self.accountProfileClient = accountProfileClient ?? MomentsAccountProfileClient(baseURLString: AppConfig.momentsAPIBaseURL)
        self.balanceClient = balanceClient ?? MomentsCreditBalanceClient(baseURLString: AppConfig.momentsAPIBaseURL)
        self.promoCodeClient = promoCodeClient ?? MomentsPromoCodeClient(baseURLString: AppConfig.momentsAPIBaseURL)
        self.purchaseService = purchaseService
        self.userDefaults = userDefaults
        self.user = Self.lastKnownAccountUser(from: userDefaults)
        refresh()
    }

    var isAccountAvailable: Bool {
        service.isAvailable
    }

    var isSignedIn: Bool {
        user != nil
    }

    func refresh() {
        if user == nil {
            resetSignedOutAccountState()
        } else {
            persistLastKnownAccountUser(user)
            creditBalanceLoadState = .loading
            Task { await refreshCreditBalance() }
        }
    }

    func syncFromAccountProvider() async {
        switch await service.restoreSession() {
        case .active(let providerUser):
            guard let resolvedUser = await resolveInternalAccountUser(providerUser: providerUser) else {
                isAccountSessionTemporarilyUnavailable = true
                if user == nil {
                    resetSignedOutAccountState()
                }
                return
            }
            user = resolvedUser
            isAccountSessionTemporarilyUnavailable = false
            persistLastKnownAccountUser(resolvedUser)
            await refreshCreditBalance()
        case .temporarilyUnavailable:
            isAccountSessionTemporarilyUnavailable = true
            if user == nil {
                resetSignedOutAccountState()
            }
        case .signedOut, .invalidated:
            user = nil
            isAccountSessionTemporarilyUnavailable = false
            clearLastKnownAccountUser()
            resetSignedOutAccountState()
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
            await self.purchaseService.logOut()
            self.user = nil
            self.isAccountSessionTemporarilyUnavailable = false
            self.clearLastKnownAccountUser()
            self.resetSignedOutAccountState()
        }
    }

    func claimPromotionCode(_ code: String) async throws -> Int {
        let normalizedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let user, !normalizedCode.isEmpty else { return 0 }

        guard let token = try await currentBackendBearerToken(for: user) else {
            throw MomentsAPIError(code: "moments_auth_token_missing", message: L10n.string("access.signInRequired.generic"))
        }
        let response = try await promoCodeClient.redeem(code: normalizedCode, bearerToken: token)
        creditBalance = response.balance
        creditBalanceLoadState = .loaded
        return response.creditsGranted
    }

    func loadPurchaseProducts() async {
        guard let user else {
            purchaseCatalog = .empty
            purchaseCatalogErrorMessage = nil
            return
        }

        isPurchaseCatalogLoading = true
        purchaseCatalogErrorMessage = nil
        defer { isPurchaseCatalogLoading = false }

        do {
            purchaseCatalog = try await purchaseService.loadCatalog(userId: user.id)
        } catch {
            purchaseCatalog = .empty
            purchaseCatalogErrorMessage = L10n.string("paywall.purchasesUnavailable")
        }
    }

    func purchase(_ product: MomentsCreditPaywallProduct) async throws -> MomentsPurchaseResult {
        guard let user else {
            throw MomentsAPIError(code: "moments_sign_in_required", message: L10n.string("access.signInRequired.purchase"))
        }
        guard !isPurchaseInProgress else {
            return MomentsPurchaseResult(status: .cancelled, productId: product.id, transactionId: nil)
        }

        isPurchaseInProgress = true
        defer { isPurchaseInProgress = false }

        let result = try await purchaseService.purchase(productId: product.id, userId: user.id)
        if result.status == .purchased {
            await refreshCreditBalanceAfterBillingEvent()
        }
        return result
    }

    func restorePurchases() async throws -> MomentsPurchaseResult {
        guard let user else {
            throw MomentsAPIError(code: "moments_sign_in_required", message: L10n.string("access.signInRequired.restore"))
        }
        guard !isPurchaseInProgress else {
            return MomentsPurchaseResult(status: .cancelled, productId: nil, transactionId: nil)
        }

        isPurchaseInProgress = true
        defer { isPurchaseInProgress = false }

        let result = try await purchaseService.restorePurchases(userId: user.id)
        await refreshCreditBalanceAfterBillingEvent()
        return result
    }

    func refreshCreditBalance() async {
        guard let user else {
            resetSignedOutAccountState()
            return
        }

        creditBalanceLoadState = .loading
        do {
            guard let token = try await currentBackendBearerToken(for: user) else {
                throw MomentsAPIError(code: "moments_auth_token_missing", message: L10n.string("access.signInRequired.generic"))
            }
            creditBalance = try await balanceClient.fetchBalance(bearerToken: token)
            creditBalanceLoadState = .loaded
            isAccountSessionTemporarilyUnavailable = false
            persistLastKnownAccountUser(user)
        } catch {
            creditBalanceLoadState = MomentsCreditBalanceLoadState.failureState(for: error)
            errorMessage = error.localizedDescription
        }
    }

    func currentBearerToken() async throws -> String? {
        guard let user else { return nil }
        return try await currentBackendBearerToken(for: user)
    }

    private func refreshCreditBalanceAfterBillingEvent() async {
        await refreshCreditBalance()
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await self?.refreshCreditBalance()
        }
    }

    private func resolveInternalAccountUser(providerUser: AccountAVUser) async -> AccountAVUser? {
        do {
            guard let token = try await service.getToken() else {
                return MomentsUITestEnvironment.current.hasAccountOverride ? providerUser : nil
            }
            return try await accountProfileClient.fetchCurrentUser(bearerToken: token)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func currentBackendBearerToken(for user: AccountAVUser) async throws -> String? {
        if let token = try await service.getToken() {
            return token
        }
        if MomentsUITestEnvironment.current.hasAccountOverride {
            return user.id
        }
        return nil
    }

    private func resetSignedOutAccountState() {
        creditBalance = .empty
        creditBalanceLoadState = .signedOut
        purchaseCatalog = .empty
        purchaseCatalogErrorMessage = nil
    }

    private static func lastKnownAccountUser(from userDefaults: UserDefaults) -> AccountAVUser? {
        guard let data = userDefaults.data(forKey: "momentsav.account.lastKnownUser"),
              let snapshot = try? JSONDecoder().decode(MomentsLastKnownAccountUser.self, from: data) else {
            return nil
        }
        return snapshot.accountUser
    }

    private func persistLastKnownAccountUser(_ user: AccountAVUser?) {
        guard let user else { return }
        let snapshot = MomentsLastKnownAccountUser(user: user)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        userDefaults.set(data, forKey: lastKnownAccountUserKey)
    }

    private func clearLastKnownAccountUser() {
        userDefaults.removeObject(forKey: lastKnownAccountUserKey)
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

private struct MomentsLastKnownAccountUser: Codable {
    let id: String
    let displayName: String
    let emailAddress: String?

    init(user: AccountAVUser) {
        id = user.id
        displayName = user.displayName
        emailAddress = user.emailAddress
    }

    var accountUser: AccountAVUser {
        AccountAVUser(id: id, displayName: displayName, emailAddress: emailAddress)
    }
}

struct MomentsAccountProfileClient {
    var baseURLString: String
    var session: URLSession = .shared

    func fetchCurrentUser(bearerToken: String) async throws -> AccountAVUser {
        guard let url = URL(string: "\(baseURLString)/v1/me") else {
            throw MomentsAPIError(code: "invalid_account_api_url", message: L10n.string("access.apiURLMissing"))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "account_profile_failed",
                fallbackMessage: "Account profile could not be loaded."
            )
        }

        let decoded = try JSONDecoder().decode(MomentsAccountProfileResponse.self, from: data)
        return AccountAVUser(
            id: decoded.user.id,
            displayName: decoded.user.displayName ?? L10n.string("account.displayName.user"),
            emailAddress: decoded.user.email ?? decoded.user.emailAddress
        )
    }
}

private struct MomentsAccountProfileResponse: Decodable {
    let user: User

    struct User: Decodable {
        let id: String
        let displayName: String?
        let email: String?
        let emailAddress: String?
    }
}

struct MomentsCreditBalanceClient {
    var baseURLString: String
    var session: URLSession = .shared

    func fetchBalance(bearerToken: String) async throws -> MomentsCreditBalance {
        guard let url = URL(string: "\(baseURLString)/v1/apps/momentsav/credits/balance") else {
            throw MomentsAPIError(code: "invalid_moments_api_url", message: L10n.string("access.apiURLMissing"))
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
            purchased: decoded.purchasedCredits,
            availableCredits: decoded.spendableCredits,
            watermarkRemovalCreditCost: decoded.watermarkRemovalCreditCost,
            watermarkFreeIncluded: decoded.watermarkFreeIncluded
        )
    }
}

private struct MomentsCreditBalanceResponse: Decodable {
    let spendableCredits: Int
    let proMonthlyCredits: Int
    let promotionalGrantedCredits: Int
    let purchasedCredits: Int
    let watermarkRemovalCreditCost: Int
    let watermarkFreeIncluded: Bool

    private enum CodingKeys: String, CodingKey {
        case spendableCredits
        case proMonthlyCredits
        case promotionalGrantedCredits
        case purchasedCredits
        case watermarkRemovalCreditCost
        case watermarkFreeIncluded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        spendableCredits = try container.decode(Int.self, forKey: .spendableCredits)
        proMonthlyCredits = try container.decode(Int.self, forKey: .proMonthlyCredits)
        promotionalGrantedCredits = try container.decode(Int.self, forKey: .promotionalGrantedCredits)
        purchasedCredits = try container.decode(Int.self, forKey: .purchasedCredits)
        watermarkRemovalCreditCost = try container.decodeIfPresent(Int.self, forKey: .watermarkRemovalCreditCost) ?? 1
        watermarkFreeIncluded = try container.decodeIfPresent(Bool.self, forKey: .watermarkFreeIncluded) ?? false
    }
}

struct MomentsPromoCodeClient {
    var baseURLString: String
    var session: URLSession = .shared

    func redeem(code: String, bearerToken: String) async throws -> MomentsPromoCodeRedemptionResponse {
        guard let url = URL(string: "\(baseURLString)/v1/apps/momentsav/credits/promotions/redeem") else {
            throw MomentsAPIError(code: "invalid_moments_api_url", message: L10n.string("access.apiURLMissing"))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(MomentsPromoCodeRedeemRequest(code: code))

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_promo_code_redeem_failed",
                fallbackMessage: "Promo code could not be redeemed."
            )
        }

        return try JSONDecoder().decode(MomentsPromoCodeRedemptionResponse.self, from: data)
    }
}

private struct MomentsPromoCodeRedeemRequest: Encodable {
    let code: String
}

struct MomentsPromoCodeRedemptionResponse: Decodable {
    let creditsGranted: Int
    let balance: MomentsCreditBalance

    private enum CodingKeys: String, CodingKey {
        case creditsGranted
        case balance
    }

    private enum BalanceCodingKeys: String, CodingKey {
        case spendableCredits
        case proMonthlyCredits
        case promotionalGrantedCredits
        case purchasedCredits
        case watermarkRemovalCreditCost
        case watermarkFreeIncluded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        creditsGranted = try container.decode(Int.self, forKey: .creditsGranted)
        let balanceContainer = try container.nestedContainer(keyedBy: BalanceCodingKeys.self, forKey: .balance)
        balance = MomentsCreditBalance(
            proMonthly: try balanceContainer.decode(Int.self, forKey: .proMonthlyCredits),
            promotional: try balanceContainer.decode(Int.self, forKey: .promotionalGrantedCredits),
            purchased: try balanceContainer.decode(Int.self, forKey: .purchasedCredits),
            availableCredits: try balanceContainer.decodeIfPresent(Int.self, forKey: .spendableCredits),
            watermarkRemovalCreditCost: try balanceContainer.decodeIfPresent(Int.self, forKey: .watermarkRemovalCreditCost) ?? 1,
            watermarkFreeIncluded: try balanceContainer.decodeIfPresent(Bool.self, forKey: .watermarkFreeIncluded) ?? false
        )
    }
}

extension AccountController: MomentsCurrentUserProviding, MomentsAuthTokenProviding, MomentsCreditBalanceProviding, MomentsAccountStateProviding, MomentsAuthenticationControlling {
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

    var creditBalanceLoadStatePublisher: AnyPublisher<MomentsCreditBalanceLoadState, Never> {
        $creditBalanceLoadState.eraseToAnyPublisher()
    }
}
