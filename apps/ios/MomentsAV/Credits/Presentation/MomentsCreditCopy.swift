enum MomentsCreditCopy {
    static let monthlyVideoCreditsIncluded = 6

    static func noun(_ count: Int) -> String {
        count == 1 ? MomentsL10n.string("credits.noun.one") : MomentsL10n.string("credits.noun.other")
    }

    static func countTitle(_ count: Int) -> String {
        MomentsL10n.string("credits.countTitle", count, noun(count))
    }

    static func availableTitle(_ balance: MomentsCreditBalance) -> String {
        countTitle(balance.spendable)
    }

    static func availableDetail(_ balance: MomentsCreditBalance) -> String {
        balance.spendable == 0
            ? MomentsL10n.string("credits.available.none")
            : MomentsL10n.string("credits.available.detail", availableTitle(balance))
    }

    static func proMonthlyDetail(_ balance: MomentsCreditBalance) -> String {
        MomentsL10n.string("credits.proMonthly.detail", balance.proMonthly, monthlyVideoCreditsIncluded)
    }

    static func purchasedDetail(_ balance: MomentsCreditBalance) -> String {
        MomentsL10n.string("credits.purchased.detail", balance.purchased)
    }

    static func otherDetail(_ balance: MomentsCreditBalance) -> String {
        MomentsL10n.string("credits.other.detail", balance.promotional)
    }

    static func detailRows(for balance: MomentsCreditBalance) -> [MomentsCreditDetailRow] {
        [
            MomentsCreditDetailRow(
                id: "proMonthly",
                title: MomentsL10n.string("credits.proMonthly.title"),
                value: balance.proMonthly,
                detail: proMonthlyDetail(balance),
                systemImage: "sparkles.rectangle.stack"
            ),
            MomentsCreditDetailRow(
                id: "purchased",
                title: MomentsL10n.string("credits.purchased.title"),
                value: balance.purchased,
                detail: purchasedDetail(balance),
                systemImage: "creditcard"
            ),
            MomentsCreditDetailRow(
                id: "other",
                title: MomentsL10n.string("credits.other.title"),
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
