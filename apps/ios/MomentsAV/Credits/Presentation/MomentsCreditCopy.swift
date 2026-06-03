enum MomentsCreditCopy {
    static let monthlyVideoCreditsIncluded = 6

    static func noun(_ count: Int) -> String {
        count == 1 ? L10n.string("credits.noun.one") : L10n.string("credits.noun.other")
    }

    static func countTitle(_ count: Int) -> String {
        L10n.string("credits.countTitle", count, noun(count))
    }

    static func availableTitle(_ balance: MomentsCreditBalance) -> String {
        countTitle(balance.spendable)
    }

    static func availableDetail(_ balance: MomentsCreditBalance) -> String {
        balance.spendable == 0
            ? L10n.string("credits.available.none")
            : L10n.string("credits.available.detail", availableTitle(balance))
    }

    static func balanceStatusTitle(_ loadState: MomentsCreditBalanceLoadState) -> String {
        switch loadState {
        case .signedOut:
            L10n.string("credits.balance.signedOut.title")
        case .loading:
            L10n.string("credits.balance.loading.title")
        case .loaded:
            L10n.string("credits.available.title")
        case .offline:
            L10n.string("credits.balance.offline.title")
        case .unavailable:
            L10n.string("credits.balance.unavailable.title")
        }
    }

    static func balanceStatusDetail(_ loadState: MomentsCreditBalanceLoadState) -> String {
        switch loadState {
        case .signedOut:
            L10n.string("credits.balance.signedOut.detail")
        case .loading:
            L10n.string("credits.balance.loading.detail")
        case .loaded:
            L10n.string("credits.home.ready")
        case .offline:
            L10n.string("credits.balance.offline.detail")
        case .unavailable:
            L10n.string("credits.balance.unavailable.detail")
        }
    }

    static func balanceStatusDetail(
        _ loadState: MomentsCreditBalanceLoadState,
        balance: MomentsCreditBalance
    ) -> String {
        loadState.hasLoadedBalance ? availableDetail(balance) : balanceStatusDetail(loadState)
    }

    static func proMonthlyDetail(_ balance: MomentsCreditBalance) -> String {
        L10n.string("credits.proMonthly.detail", balance.proMonthly, monthlyVideoCreditsIncluded)
    }

    static func purchasedDetail(_ balance: MomentsCreditBalance) -> String {
        L10n.string("credits.purchased.detail", balance.purchased)
    }

    static func otherDetail(_ balance: MomentsCreditBalance) -> String {
        L10n.string("credits.other.detail", balance.promotional)
    }

    static func detailRows(for balance: MomentsCreditBalance) -> [MomentsCreditDetailRow] {
        [
            MomentsCreditDetailRow(
                id: "proMonthly",
                title: L10n.string("credits.proMonthly.title"),
                value: balance.proMonthly,
                detail: proMonthlyDetail(balance),
                systemImage: "sparkles.rectangle.stack"
            ),
            MomentsCreditDetailRow(
                id: "purchased",
                title: L10n.string("credits.purchased.title"),
                value: balance.purchased,
                detail: purchasedDetail(balance),
                systemImage: "creditcard"
            ),
            MomentsCreditDetailRow(
                id: "other",
                title: L10n.string("credits.other.title"),
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
