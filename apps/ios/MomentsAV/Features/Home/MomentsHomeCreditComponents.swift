import AVAppShellFoundation
import SwiftUI

struct MomentsHomeCreditBreakdown: View {
    let balance: MomentsCreditBalance

    var body: some View {
        AVAppShellMetricStrip(
            metrics: CreditSource.allCases.map { source in
                AVAppShellMetric(
                    id: source.rawValue,
                    title: source.shortTitle,
                    value: "\(balance.amount(for: source))"
                )
            },
            minTileHeight: 54
        )
    }
}

private extension CreditSource {
    var shortTitle: String {
        switch self {
        case .proMonthly: "Monthly"
        case .promotional: "Promo"
        case .purchased: "Purchased"
        }
    }
}
