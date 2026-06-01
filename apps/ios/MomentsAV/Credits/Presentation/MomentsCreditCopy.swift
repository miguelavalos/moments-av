enum MomentsCreditCopy {
    static let monthlyVideoCreditsIncluded = 6

    static func noun(_ count: Int) -> String {
        count == 1 ? "credit" : "credits"
    }

    static func countTitle(_ count: Int) -> String {
        "\(count) \(noun(count))"
    }

    static func availableTitle(_ balance: MomentsCreditBalance) -> String {
        countTitle(balance.spendable)
    }

    static func availableDetail(_ balance: MomentsCreditBalance) -> String {
        balance.spendable == 0 ? "No credits available" : "\(availableTitle(balance)) available"
    }

    static func proMonthlyDetail(_ balance: MomentsCreditBalance) -> String {
        "\(balance.proMonthly) of \(monthlyVideoCreditsIncluded) left"
    }

    static func purchasedDetail(_ balance: MomentsCreditBalance) -> String {
        "\(balance.purchased) purchased"
    }

    static func otherDetail(_ balance: MomentsCreditBalance) -> String {
        "\(balance.promotional) other"
    }

    static func detailRows(for balance: MomentsCreditBalance) -> [MomentsCreditDetailRow] {
        [
            MomentsCreditDetailRow(
                id: "proMonthly",
                title: "Pro monthly",
                value: balance.proMonthly,
                detail: proMonthlyDetail(balance),
                systemImage: "sparkles.rectangle.stack"
            ),
            MomentsCreditDetailRow(
                id: "purchased",
                title: "Purchased",
                value: balance.purchased,
                detail: purchasedDetail(balance),
                systemImage: "creditcard"
            ),
            MomentsCreditDetailRow(
                id: "other",
                title: "Other",
                value: balance.promotional,
                detail: otherDetail(balance),
                systemImage: "gift"
            )
        ]
    }
}

struct MomentsCreditDetailRow: Identifiable, Equatable {
    let id: String
    let title: String
    let value: Int
    let detail: String
    let systemImage: String
}
