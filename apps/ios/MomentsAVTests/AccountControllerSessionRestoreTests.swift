import AccountAV
import Foundation
import XCTest
@testable import MomentsAV

@MainActor
final class AccountControllerSessionRestoreTests: XCTestCase {
    override func tearDown() {
        AccountControllerURLProtocol.reset()
        super.tearDown()
    }

    func testTemporarilyUnavailableSessionPreservesCurrentUser() async {
        let user = AccountAVUser(id: "user-1", displayName: "User One", emailAddress: "user@example.com")
        let accountService = StubAVAccountService(
            user: user,
            restoreResult: .temporarilyUnavailable(nil)
        )
        let controller = AccountController(
            service: accountService,
            balanceClient: balanceClient(),
            purchaseService: StubMomentsPurchaseService(),
            userDefaults: isolatedUserDefaults()
        )

        await controller.syncFromAccountProvider()

        XCTAssertTrue(controller.isSignedIn)
        XCTAssertEqual(controller.currentUserId, user.id)
        XCTAssertTrue(controller.isAccountSessionTemporarilyUnavailable)
        XCTAssertFalse(accountService.didSignOut)
    }

    func testLastKnownUserPreservesColdStartDuringTemporarySessionFailure() async {
        let userDefaults = isolatedUserDefaults()
        let user = AccountAVUser(id: "cached-user", displayName: "Cached User", emailAddress: "cached@example.com")
        let signedInController = AccountController(
            service: StubAVAccountService(user: user),
            balanceClient: balanceClient(),
            purchaseService: StubMomentsPurchaseService(),
            userDefaults: userDefaults
        )
        await signedInController.syncFromAccountProvider()

        let restoredController = AccountController(
            service: StubAVAccountService(user: nil, restoreResult: .temporarilyUnavailable(nil)),
            balanceClient: balanceClient(),
            purchaseService: StubMomentsPurchaseService(),
            userDefaults: userDefaults
        )
        await restoredController.syncFromAccountProvider()

        XCTAssertTrue(restoredController.isSignedIn)
        XCTAssertEqual(restoredController.currentUserId, user.id)
        XCTAssertTrue(restoredController.isAccountSessionTemporarilyUnavailable)
    }

    func testConfirmedSignedOutClearsLastKnownUser() async {
        let userDefaults = isolatedUserDefaults()
        let user = AccountAVUser(id: "signed-out-user", displayName: "Signed Out User", emailAddress: nil)
        let signedInController = AccountController(
            service: StubAVAccountService(user: user),
            balanceClient: balanceClient(),
            purchaseService: StubMomentsPurchaseService(),
            userDefaults: userDefaults
        )
        await signedInController.syncFromAccountProvider()

        let signedOutController = AccountController(
            service: StubAVAccountService(user: nil, restoreResult: .signedOut),
            balanceClient: balanceClient(),
            purchaseService: StubMomentsPurchaseService(),
            userDefaults: userDefaults
        )
        await signedOutController.syncFromAccountProvider()

        XCTAssertFalse(signedOutController.isSignedIn)
        XCTAssertNil(signedOutController.currentUserId)
        XCTAssertFalse(signedOutController.isAccountSessionTemporarilyUnavailable)
    }

    func testManualSignOutClearsLastKnownUser() async throws {
        let userDefaults = isolatedUserDefaults()
        let accountService = StubAVAccountService(
            user: AccountAVUser(id: "manual-user", displayName: "Manual User", emailAddress: nil)
        )
        let controller = AccountController(
            service: accountService,
            balanceClient: balanceClient(),
            purchaseService: StubMomentsPurchaseService(),
            userDefaults: userDefaults
        )
        await controller.syncFromAccountProvider()

        controller.signOut()
        try await Task.sleep(nanoseconds: 50_000_000)

        let restoredController = AccountController(
            service: StubAVAccountService(user: nil, restoreResult: .temporarilyUnavailable(nil)),
            balanceClient: balanceClient(),
            purchaseService: StubMomentsPurchaseService(),
            userDefaults: userDefaults
        )

        XCTAssertFalse(restoredController.isSignedIn)
        XCTAssertNil(restoredController.currentUserId)
        XCTAssertTrue(accountService.didSignOut)
    }

    private func balanceClient() -> MomentsCreditBalanceClient {
        AccountControllerURLProtocol.responseJSON = """
        {
          "proMonthlyCredits": 10,
          "promotionalGrantedCredits": 0,
          "purchasedCredits": 0,
          "watermarkRemovalCreditCost": 1,
          "watermarkFreeIncluded": true
        }
        """
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [AccountControllerURLProtocol.self]
        return MomentsCreditBalanceClient(baseURLString: "https://account.example.test", session: URLSession(configuration: configuration))
    }

    private func isolatedUserDefaults() -> UserDefaults {
        let suiteName = "MomentsAVTests.AccountController.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}

@MainActor
private final class StubAVAccountService: AVAccountService {
    private var storedUser: AccountAVUser?
    private let token: String?
    private let restoreResult: AccountAVSessionRestoreResult?
    private(set) var didSignOut = false

    init(user: AccountAVUser?, token: String? = "test-token", restoreResult: AccountAVSessionRestoreResult? = nil) {
        self.storedUser = user
        self.token = token
        self.restoreResult = restoreResult
    }

    var isAvailable: Bool { true }
    var currentUser: AccountAVUser? { storedUser }

    func restoreSession() async -> AccountAVSessionRestoreResult {
        if let restoreResult {
            return restoreResult
        }
        guard let storedUser else { return .signedOut }
        return .active(storedUser)
    }

    func getToken() async throws -> String? {
        token
    }

    func signInWithApple() async throws {}
    func signInWithGoogle() async throws {}

    func signOut() async throws {
        didSignOut = true
        storedUser = nil
    }
}

@MainActor
private struct StubMomentsPurchaseService: MomentsPurchaseServicing {
    func loadCatalog(userId: String) async throws -> MomentsPurchaseCatalog {
        .empty
    }

    func purchase(productId: String, userId: String) async throws -> MomentsPurchaseResult {
        MomentsPurchaseResult(status: .cancelled, productId: productId, transactionId: nil)
    }

    func restorePurchases(userId: String) async throws -> MomentsPurchaseResult {
        MomentsPurchaseResult(status: .cancelled, productId: nil, transactionId: nil)
    }

    func logOut() async {}
}

private final class AccountControllerURLProtocol: URLProtocol {
    static var responseJSON = "{}"

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(Self.responseJSON.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    static func reset() {
        responseJSON = "{}"
    }
}
