import Foundation

enum MomentsCreditProductID {
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

    static var proMonthly: MomentsCreditPaywallProduct {
        MomentsCreditPaywallProduct(
        id: MomentsCreditProductID.proMonthlyProduct,
        kind: .subscription,
        eyebrow: MomentsL10n.string("paywall.product.bestValue"),
        title: MomentsL10n.string("paywall.product.pro.title"),
        detail: MomentsL10n.string("paywall.product.pro.detail"),
        buttonTitle: MomentsL10n.string("paywall.product.pro.button"),
        systemImage: "sparkles",
        isRecommended: true
        )
    }

    static var starterPack: MomentsCreditPaywallProduct {
        MomentsCreditPaywallProduct(
        id: MomentsCreditProductID.starterPackProduct,
        kind: .consumableCredits(5),
        eyebrow: MomentsL10n.string("paywall.product.starter.eyebrow"),
        title: MomentsL10n.string("paywall.product.starter.title"),
        detail: MomentsL10n.string("paywall.product.starter.detail"),
        buttonTitle: MomentsL10n.string("paywall.product.starter.button"),
        systemImage: "plus.circle.fill",
        isRecommended: false
        )
    }

    static var creatorPack: MomentsCreditPaywallProduct {
        MomentsCreditPaywallProduct(
        id: MomentsCreditProductID.creatorPackProduct,
        kind: .consumableCredits(20),
        eyebrow: MomentsL10n.string("paywall.product.bestValue"),
        title: MomentsL10n.string("paywall.product.creator.title"),
        detail: MomentsL10n.string("paywall.product.creator.detail"),
        buttonTitle: MomentsL10n.string("paywall.product.creator.button"),
        systemImage: "square.stack.3d.up.fill",
        isRecommended: false
        )
    }

    static var all: [MomentsCreditPaywallProduct] { [
        .proMonthly,
        .starterPack,
        .creatorPack
    ] }
}
