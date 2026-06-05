import Foundation

enum CreditSource: String, CaseIterable {
    case proMonthly
    case promotional
    case purchased

    var title: String {
        switch self {
        case .proMonthly: L10n.string("credits.proMonthly.title")
        case .promotional: L10n.string("credits.promotional.title")
        case .purchased: L10n.string("credits.purchased.title")
        }
    }
}

struct MomentsCreditBalance: Equatable {
    var proMonthly: Int
    var promotional: Int
    var purchased: Int
    var availableCredits: Int?
    var watermarkRemovalCreditCost: Int = 1
    var watermarkFreeIncluded: Bool = false

    static let empty = MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 0)

    var spendable: Int {
        availableCredits ?? (proMonthly + promotional + purchased)
    }

    func amount(for source: CreditSource) -> Int {
        switch source {
        case .proMonthly: proMonthly
        case .promotional: promotional
        case .purchased: purchased
        }
    }
}

struct MomentsCreditSpendPlan: Equatable {
    let proMonthly: Int
    let promotional: Int
    let purchased: Int

    var total: Int {
        proMonthly + promotional + purchased
    }
}

enum MomentsCreditGate {
    static func canAfford(_ template: MomentTemplate, balance: MomentsCreditBalance) -> Bool {
        balance.spendable >= template.creditCost
    }

    static func canAffordAny(_ templates: [MomentTemplate], balance: MomentsCreditBalance) -> Bool {
        templates.contains { canAfford($0, balance: balance) }
    }

    static func spendPlan(for cost: Int, balance: MomentsCreditBalance) -> MomentsCreditSpendPlan? {
        guard cost > 0, balance.spendable >= cost else { return nil }

        let proMonthlySpend = min(balance.proMonthly, cost)
        let afterPro = cost - proMonthlySpend
        let promotionalSpend = min(balance.promotional, afterPro)
        let purchasedSpend = afterPro - promotionalSpend

        return MomentsCreditSpendPlan(
            proMonthly: proMonthlySpend,
            promotional: promotionalSpend,
            purchased: purchasedSpend
        )
    }
}
