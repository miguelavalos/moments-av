import AccountAV
import Combine
import Foundation

@MainActor
final class AccountController: ObservableObject {
    @Published private(set) var user: AccountAVUser?
    @Published private(set) var creditBalance = MomentsCreditBalance.empty
    @Published private(set) var purchaseCatalog = MomentsPurchaseCatalog.empty
    @Published private(set) var isPurchaseCatalogLoading = false
    @Published private(set) var purchaseCatalogErrorMessage: String?
    @Published private(set) var isPurchaseInProgress = false
    @Published private(set) var isBusy = false
    @Published var errorMessage: String?

    private let service: AVAccountService
    private let balanceClient: MomentsCreditBalanceClient
    private let promoCodeClient: MomentsPromoCodeClient
    private let reviewBundleClient: MomentsReviewBundleClient
    private let purchaseService: MomentsPurchaseServicing

    init(
        service: AVAccountService = DefaultAVAccountService(),
        balanceClient: MomentsCreditBalanceClient? = nil,
        promoCodeClient: MomentsPromoCodeClient? = nil,
        reviewBundleClient: MomentsReviewBundleClient? = nil,
        purchaseService: MomentsPurchaseServicing = RevenueCatMomentsPurchaseService()
    ) {
        self.service = service
        self.balanceClient = balanceClient ?? MomentsCreditBalanceClient(baseURLString: AppConfig.momentsAPIBaseURL)
        self.promoCodeClient = promoCodeClient ?? MomentsPromoCodeClient(baseURLString: AppConfig.momentsAPIBaseURL)
        self.reviewBundleClient = reviewBundleClient ?? MomentsReviewBundleClient(baseURLString: AppConfig.momentsAPIBaseURL)
        self.purchaseService = purchaseService
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
            purchaseCatalog = .empty
            purchaseCatalogErrorMessage = nil
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
            purchaseCatalog = .empty
            purchaseCatalogErrorMessage = nil
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
            await self.purchaseService.logOut()
            self.user = nil
            self.creditBalance = .empty
            self.purchaseCatalog = .empty
            self.purchaseCatalogErrorMessage = nil
        }
    }

    func claimPromotionCode(_ code: String) async throws -> Int {
        let normalizedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let user, !normalizedCode.isEmpty else { return 0 }

        let token = try await service.getToken() ?? user.id
        let response = try await promoCodeClient.redeem(code: normalizedCode, bearerToken: token)
        creditBalance = response.balance
        return response.creditsGranted
    }

    func purchaseReviewBundle() async throws -> MomentsReviewBundlePurchaseResponse {
        guard let user else {
            throw MomentsAPIError(code: "moments_sign_in_required", message: "Sign in before adding story reviews.")
        }

        let token = try await service.getToken() ?? user.id
        let response = try await reviewBundleClient.purchase(bearerToken: token)
        creditBalance = response.balance
        return response
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
            purchaseCatalogErrorMessage = error.localizedDescription
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: MomentsCreditPaywallProduct) async throws -> MomentsPurchaseResult {
        guard let user else {
            throw MomentsAPIError(code: "moments_sign_in_required", message: "Sign in before purchasing credits.")
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
            throw MomentsAPIError(code: "moments_sign_in_required", message: "Sign in before restoring purchases.")
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

    func currentBearerToken() async throws -> String? {
        guard let user else { return nil }
        return try await service.getToken() ?? user.id
    }

    private func refreshCreditBalanceAfterBillingEvent() async {
        await refreshCreditBalance()
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await self?.refreshCreditBalance()
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
            purchased: decoded.purchasedCredits,
            reviewAllowanceRemaining: decoded.reviewAllowanceRemaining,
            includedReviewsRemaining: decoded.includedReviewsRemaining,
            canReview: decoded.canReview,
            canCreateDirectly: decoded.canCreateDirectly,
            canBuyReviewBundle: decoded.canBuyReviewBundle,
            reviewBundleCreditCost: decoded.reviewBundleCreditCost,
            reviewBundleReviewCount: decoded.reviewBundleReviewCount,
            watermarkRemovalCreditCost: decoded.watermarkRemovalCreditCost,
            watermarkFreeIncluded: decoded.watermarkFreeIncluded
        )
    }
}

struct MomentsReviewBundleClient {
    var baseURLString: String
    var session: URLSession = .shared

    func purchase(bearerToken: String) async throws -> MomentsReviewBundlePurchaseResponse {
        guard let url = URL(string: "\(baseURLString)/v1/apps/momentsav/credits/review-bundles") else {
            throw MomentsAPIError(code: "invalid_moments_api_url", message: "Moments AV API URL is not configured.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            MomentsReviewBundlePurchaseRequest(idempotencyKey: "ios-review-bundle:\(UUID().uuidString)")
        )

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_review_bundle_purchase_failed",
                fallbackMessage: "Story reviews could not be added."
            )
        }

        return try JSONDecoder().decode(MomentsReviewBundlePurchaseResponse.self, from: data)
    }
}

private struct MomentsReviewBundlePurchaseRequest: Encodable {
    let appId = "momentsav"
    let idempotencyKey: String
}

struct MomentsReviewBundlePurchaseResponse: Decodable, Equatable {
    let reviewsGranted: Int
    let creditsCommitted: Int
    let balance: MomentsCreditBalance

    private enum CodingKeys: String, CodingKey {
        case reviewsGranted
        case creditsCommitted
        case balance
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reviewsGranted = try container.decode(Int.self, forKey: .reviewsGranted)
        creditsCommitted = try container.decode(Int.self, forKey: .creditsCommitted)
        balance = try MomentsCreditBalance.decode(from: container, forKey: .balance)
    }
}

private struct MomentsCreditBalanceResponse: Decodable {
    let proMonthlyCredits: Int
    let promotionalGrantedCredits: Int
    let purchasedCredits: Int
    let reviewAllowanceRemaining: Int
    let includedReviewsRemaining: Int
    let canReview: Bool
    let canCreateDirectly: Bool
    let canBuyReviewBundle: Bool
    let reviewBundleCreditCost: Int
    let reviewBundleReviewCount: Int
    let watermarkRemovalCreditCost: Int
    let watermarkFreeIncluded: Bool

    private enum CodingKeys: String, CodingKey {
        case proMonthlyCredits
        case promotionalGrantedCredits
        case purchasedCredits
        case reviewAllowanceRemaining
        case includedReviewsRemaining
        case canReview
        case canCreateDirectly
        case canBuyReviewBundle
        case reviewBundleCreditCost
        case reviewBundleReviewCount
        case watermarkRemovalCreditCost
        case watermarkFreeIncluded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        proMonthlyCredits = try container.decode(Int.self, forKey: .proMonthlyCredits)
        promotionalGrantedCredits = try container.decode(Int.self, forKey: .promotionalGrantedCredits)
        purchasedCredits = try container.decode(Int.self, forKey: .purchasedCredits)
        reviewAllowanceRemaining = try container.decodeIfPresent(Int.self, forKey: .reviewAllowanceRemaining) ?? 0
        includedReviewsRemaining = try container.decodeIfPresent(Int.self, forKey: .includedReviewsRemaining) ?? reviewAllowanceRemaining
        canReview = try container.decodeIfPresent(Bool.self, forKey: .canReview) ?? true
        canCreateDirectly = try container.decodeIfPresent(Bool.self, forKey: .canCreateDirectly) ?? true
        canBuyReviewBundle = try container.decodeIfPresent(Bool.self, forKey: .canBuyReviewBundle) ?? false
        reviewBundleCreditCost = try container.decodeIfPresent(Int.self, forKey: .reviewBundleCreditCost) ?? 1
        reviewBundleReviewCount = try container.decodeIfPresent(Int.self, forKey: .reviewBundleReviewCount) ?? 2
        watermarkRemovalCreditCost = try container.decodeIfPresent(Int.self, forKey: .watermarkRemovalCreditCost) ?? 1
        watermarkFreeIncluded = try container.decodeIfPresent(Bool.self, forKey: .watermarkFreeIncluded) ?? false
    }
}

private extension MomentsCreditBalance {
    static func decode<Keys: CodingKey>(
        from container: KeyedDecodingContainer<Keys>,
        forKey key: Keys
    ) throws -> MomentsCreditBalance {
        let balanceContainer = try container.nestedContainer(keyedBy: MomentsCreditBalanceCodingKeys.self, forKey: key)
        return try decode(from: balanceContainer)
    }

    static func decode(
        from container: KeyedDecodingContainer<MomentsCreditBalanceCodingKeys>
    ) throws -> MomentsCreditBalance {
        MomentsCreditBalance(
            proMonthly: try container.decode(Int.self, forKey: .proMonthlyCredits),
            promotional: try container.decode(Int.self, forKey: .promotionalGrantedCredits),
            purchased: try container.decode(Int.self, forKey: .purchasedCredits),
            reviewAllowanceRemaining: try container.decodeIfPresent(Int.self, forKey: .reviewAllowanceRemaining) ?? 0,
            includedReviewsRemaining: try container.decodeIfPresent(Int.self, forKey: .includedReviewsRemaining)
                ?? container.decodeIfPresent(Int.self, forKey: .reviewAllowanceRemaining)
                ?? 0,
            canReview: try container.decodeIfPresent(Bool.self, forKey: .canReview) ?? true,
            canCreateDirectly: try container.decodeIfPresent(Bool.self, forKey: .canCreateDirectly) ?? true,
            canBuyReviewBundle: try container.decodeIfPresent(Bool.self, forKey: .canBuyReviewBundle) ?? false,
            reviewBundleCreditCost: try container.decodeIfPresent(Int.self, forKey: .reviewBundleCreditCost) ?? 1,
            reviewBundleReviewCount: try container.decodeIfPresent(Int.self, forKey: .reviewBundleReviewCount) ?? 2,
            watermarkRemovalCreditCost: try container.decodeIfPresent(Int.self, forKey: .watermarkRemovalCreditCost) ?? 1,
            watermarkFreeIncluded: try container.decodeIfPresent(Bool.self, forKey: .watermarkFreeIncluded) ?? false
        )
    }
}

private enum MomentsCreditBalanceCodingKeys: String, CodingKey {
    case proMonthlyCredits
    case promotionalGrantedCredits
    case purchasedCredits
    case reviewAllowanceRemaining
    case includedReviewsRemaining
    case canReview
    case canCreateDirectly
    case canBuyReviewBundle
    case reviewBundleCreditCost
    case reviewBundleReviewCount
    case watermarkRemovalCreditCost
    case watermarkFreeIncluded
}

struct MomentsPromoCodeClient {
    var baseURLString: String
    var session: URLSession = .shared

    func redeem(code: String, bearerToken: String) async throws -> MomentsPromoCodeRedemptionResponse {
        guard let url = URL(string: "\(baseURLString)/v1/apps/momentsav/credits/promotions/redeem") else {
            throw MomentsAPIError(code: "invalid_moments_api_url", message: "Moments AV API URL is not configured.")
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
        case proMonthlyCredits
        case promotionalGrantedCredits
        case purchasedCredits
        case reviewAllowanceRemaining
        case includedReviewsRemaining
        case canReview
        case canCreateDirectly
        case canBuyReviewBundle
        case reviewBundleCreditCost
        case reviewBundleReviewCount
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
            reviewAllowanceRemaining: try balanceContainer.decodeIfPresent(Int.self, forKey: .reviewAllowanceRemaining) ?? 0,
            includedReviewsRemaining: try balanceContainer.decodeIfPresent(Int.self, forKey: .includedReviewsRemaining) ?? 0,
            canReview: try balanceContainer.decodeIfPresent(Bool.self, forKey: .canReview) ?? true,
            canCreateDirectly: try balanceContainer.decodeIfPresent(Bool.self, forKey: .canCreateDirectly) ?? true,
            canBuyReviewBundle: try balanceContainer.decodeIfPresent(Bool.self, forKey: .canBuyReviewBundle) ?? false,
            reviewBundleCreditCost: try balanceContainer.decodeIfPresent(Int.self, forKey: .reviewBundleCreditCost) ?? 1,
            reviewBundleReviewCount: try balanceContainer.decodeIfPresent(Int.self, forKey: .reviewBundleReviewCount) ?? 2,
            watermarkRemovalCreditCost: try balanceContainer.decodeIfPresent(Int.self, forKey: .watermarkRemovalCreditCost) ?? 1,
            watermarkFreeIncluded: try balanceContainer.decodeIfPresent(Bool.self, forKey: .watermarkFreeIncluded) ?? false
        )
    }
}

extension AccountController: MomentsCurrentUserProviding, MomentsAuthTokenProviding, MomentsCreditBalanceProviding, MomentsReviewBundlePurchasing, MomentsAccountStateProviding, MomentsAuthenticationControlling {
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
