import Foundation
import RevenueCat

struct MomentsPurchaseCatalog: Equatable {
    struct Entry: Equatable {
        let productId: String
        let packageIdentifier: String
        let localizedTitle: String
        let localizedPrice: String
    }

    var entriesByProductId: [String: Entry]

    static let empty = MomentsPurchaseCatalog(entriesByProductId: [:])

    func entry(for product: MomentsCreditPaywallProduct) -> Entry? {
        entriesByProductId[product.id]
    }

    func localizedPrice(for product: MomentsCreditPaywallProduct) -> String? {
        entry(for: product)?.localizedPrice
    }
}

struct MomentsPurchaseResult: Equatable {
    enum Status: Equatable {
        case purchased
        case restored
        case cancelled
    }

    let status: Status
    let productId: String?
    let transactionId: String?
}

enum MomentsPurchaseError: LocalizedError, Equatable {
    case notConfigured
    case offeringUnavailable
    case productUnavailable(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return L10n.string("purchase.error.notConfigured")
        case .offeringUnavailable:
            return L10n.string("purchase.error.offeringUnavailable")
        case .productUnavailable:
            return L10n.string("purchase.error.productUnavailable")
        }
    }
}

@MainActor
protocol MomentsPurchaseServicing {
    func loadCatalog(userId: String) async throws -> MomentsPurchaseCatalog
    func purchase(productId: String, userId: String) async throws -> MomentsPurchaseResult
    func restorePurchases(userId: String) async throws -> MomentsPurchaseResult
    func logOut() async
}

@MainActor
final class RevenueCatMomentsPurchaseService: MomentsPurchaseServicing {
    private let apiKeyProvider: () -> String
    private let offeringIDProvider: () -> String
    private let monthlyPackageIDProvider: () -> String
    private var packagesByProductId: [String: Package] = [:]

    init(
        apiKeyProvider: @escaping () -> String = { AppConfig.revenueCatPublicAPIKey },
        offeringIDProvider: @escaping () -> String = { AppConfig.revenueCatOfferingID },
        monthlyPackageIDProvider: @escaping () -> String = { AppConfig.revenueCatMonthlyPackageID }
    ) {
        self.apiKeyProvider = apiKeyProvider
        self.offeringIDProvider = offeringIDProvider
        self.monthlyPackageIDProvider = monthlyPackageIDProvider
    }

    func loadCatalog(userId: String) async throws -> MomentsPurchaseCatalog {
        try await configureIfNeeded(userId: userId)
        let offering = try await momentsOffering()
        return catalog(from: offering)
    }

    func purchase(productId: String, userId: String) async throws -> MomentsPurchaseResult {
        try await configureIfNeeded(userId: userId)

        if packagesByProductId[productId] == nil {
            _ = try await loadCatalog(userId: userId)
        }

        guard let package = packagesByProductId[productId] else {
            throw MomentsPurchaseError.productUnavailable(productId)
        }

        let result = try await Purchases.shared.purchase(package: package)
        guard !result.userCancelled else {
            return MomentsPurchaseResult(status: .cancelled, productId: productId, transactionId: nil)
        }

        return MomentsPurchaseResult(
            status: .purchased,
            productId: result.transaction?.productIdentifier ?? productId,
            transactionId: result.transaction?.transactionIdentifier
        )
    }

    func restorePurchases(userId: String) async throws -> MomentsPurchaseResult {
        try await configureIfNeeded(userId: userId)
        _ = try await Purchases.shared.restorePurchases()
        return MomentsPurchaseResult(status: .restored, productId: nil, transactionId: nil)
    }

    func logOut() async {
        guard Purchases.isConfigured else { return }
        packagesByProductId = [:]
        _ = try? await Purchases.shared.logOut()
    }

    private func configureIfNeeded(userId: String) async throws {
        let apiKey = apiKeyProvider().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else {
            throw MomentsPurchaseError.notConfigured
        }

        if Purchases.isConfigured {
            if Purchases.shared.appUserID != userId {
                _ = try await Purchases.shared.logIn(userId)
                packagesByProductId = [:]
            }
            return
        }

        Purchases.configure(withAPIKey: apiKey, appUserID: userId)
    }

    private func momentsOffering() async throws -> Offering {
        let offerings = try await Purchases.shared.offerings()
        let offeringID = offeringIDProvider().trimmingCharacters(in: .whitespacesAndNewlines)
        if !offeringID.isEmpty, let offering = offerings.offering(identifier: offeringID) {
            return offering
        }
        if let current = offerings.current {
            return current
        }
        throw MomentsPurchaseError.offeringUnavailable
    }

    private func catalog(from offering: Offering) -> MomentsPurchaseCatalog {
        var packagesByProductId: [String: Package] = [:]
        for package in offering.availablePackages where packagesByProductId[package.storeProduct.productIdentifier] == nil {
            packagesByProductId[package.storeProduct.productIdentifier] = package
        }
        self.packagesByProductId = packagesByProductId
        cacheConfiguredMonthlyPackage(from: offering)

        return MomentsPurchaseCatalog(
            entriesByProductId: self.packagesByProductId.mapValues { package in
                MomentsPurchaseCatalog.Entry(
                    productId: package.storeProduct.productIdentifier,
                    packageIdentifier: package.identifier,
                    localizedTitle: package.storeProduct.localizedTitle,
                    localizedPrice: package.localizedPriceString
                )
            }
        )
    }

    private func cacheConfiguredMonthlyPackage(from offering: Offering) {
        let monthlyPackageID = monthlyPackageIDProvider().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !monthlyPackageID.isEmpty,
              let package = offering.availablePackages.first(where: {
                  $0.identifier == monthlyPackageID &&
                  $0.storeProduct.productIdentifier == MomentsCreditProductID.proMonthlyProduct
              }) else {
            return
        }
        packagesByProductId[MomentsCreditProductID.proMonthlyProduct] = package
    }
}
