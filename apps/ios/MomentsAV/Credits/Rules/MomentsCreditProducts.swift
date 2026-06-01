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

    static let proMonthly = MomentsCreditPaywallProduct(
        id: MomentsCreditProductID.proMonthlyProduct,
        kind: .subscription,
        eyebrow: "Best value",
        title: "Moments AV Pro",
        detail: "6 Video Credits and 15 Story Reviews each month, plus watermark-free final videos while Pro is active.",
        buttonTitle: "Start Pro",
        systemImage: "sparkles",
        isRecommended: true
    )

    static let starterPack = MomentsCreditPaywallProduct(
        id: MomentsCreditProductID.starterPackProduct,
        kind: .consumableCredits(5),
        eyebrow: "Starter pack",
        title: "5 Video Credits",
        detail: "Includes 10 Story Reviews for extra review passes.",
        buttonTitle: "Buy 5 credits",
        systemImage: "plus.circle.fill",
        isRecommended: false
    )

    static let creatorPack = MomentsCreditPaywallProduct(
        id: MomentsCreditProductID.creatorPackProduct,
        kind: .consumableCredits(20),
        eyebrow: "Best value",
        title: "20 Video Credits",
        detail: "Includes 40 Story Reviews for bigger batches.",
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
