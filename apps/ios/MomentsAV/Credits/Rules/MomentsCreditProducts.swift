import Foundation

enum MomentsCreditProductID {
    static let revenueCatOffering = "moments_credits"
    static let proMonthlyPackage = "$rc_monthly"
    static let proMonthlyProduct = "momentsav_pro_monthly"
    static let starterPackProduct = "momentsav_credits_5"
    static let creatorPackProduct = "momentsav_credits_20"
}

struct MomentsCreditPaywallProduct: Identifiable, Equatable {
    enum Kind: Equatable {
        case subscription
        case consumableCredits(Int)
    }

    let id: String
    let kind: Kind
    let eyebrow: String
    let title: String
    let detail: String
    let buttonTitle: String
    let systemImage: String
    let isRecommended: Bool

    static let proMonthly = MomentsCreditPaywallProduct(
        id: MomentsCreditProductID.proMonthlyProduct,
        kind: .subscription,
        eyebrow: "Recommended",
        title: "Moments AV Pro",
        detail: "For regular memory videos. Includes monthly credits while your plan is active. Cancel anytime.",
        buttonTitle: "Subscribe monthly",
        systemImage: "sparkles",
        isRecommended: true
    )

    static let starterPack = MomentsCreditPaywallProduct(
        id: MomentsCreditProductID.starterPackProduct,
        kind: .consumableCredits(5),
        eyebrow: "Starter pack",
        title: "5 credits",
        detail: "Add credits when you need more.",
        buttonTitle: "Buy 5 credits",
        systemImage: "plus.circle.fill",
        isRecommended: false
    )

    static let creatorPack = MomentsCreditPaywallProduct(
        id: MomentsCreditProductID.creatorPackProduct,
        kind: .consumableCredits(20),
        eyebrow: "Best value",
        title: "20 credits",
        detail: "Add credits for trips, families, and batches.",
        buttonTitle: "Buy 20 credits",
        systemImage: "square.stack.3d.up.fill",
        isRecommended: false
    )

    static let all: [MomentsCreditPaywallProduct] = [
        .proMonthly,
        .starterPack,
        .creatorPack
    ]
}
