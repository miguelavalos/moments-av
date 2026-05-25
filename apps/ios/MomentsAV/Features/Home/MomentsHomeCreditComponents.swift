import SwiftUI

struct MomentsHomeCreditBreakdown: View {
    let balance: MomentsCreditBalance

    var body: some View {
        HStack(spacing: 8) {
            ForEach(CreditSource.allCases, id: \.rawValue) { source in
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(balance.amount(for: source))")
                        .font(.caption.weight(.semibold))
                    Text(source.shortTitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .padding(8)
                .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

struct MomentsHomeMetricTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MomentsTheme.brandPalette.accent)
            Text(value)
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.76)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(MomentsTheme.brandPalette.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
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
