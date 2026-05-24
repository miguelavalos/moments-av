import SwiftUI

struct MomentsHomeAction: Equatable {
    let title: String
    let detail: String
    let systemImage: String
    var isProminent = false
    var isDisabled = false
}

struct MomentsHomeSectionHeader: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct MomentsHomeLatestProjectRow: View {
    let title: String
    let detail: String
    let openProject: () -> Void

    var body: some View {
        Button(action: openProject) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "clock.badge.checkmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MomentsTheme.brandPalette.accent)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Latest project")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(12)
            .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct MomentsHomeEmptyProjectRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MomentsTheme.brandPalette.accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text("No projects yet")
                    .font(.subheadline.weight(.semibold))
                Text("Start in Create to sync the first draft, preview, and final export.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 8))
    }
}

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

struct MomentsHomeActionRow: View {
    let action: MomentsHomeAction
    let perform: () -> Void

    var body: some View {
        Button(action: perform) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: action.systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(action.isProminent ? .white : MomentsTheme.brandPalette.accent)
                    .frame(width: 26, height: 26)
                    .background(iconBackground, in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(action.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(action.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(rowBackground, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(rowBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(action.isDisabled)
        .opacity(action.isDisabled ? 0.55 : 1)
    }

    private var iconBackground: Color {
        action.isProminent ? MomentsTheme.brandPalette.accent : MomentsTheme.brandPalette.accent.opacity(0.12)
    }

    private var rowBackground: Color {
        action.isProminent ? MomentsTheme.brandPalette.accent.opacity(0.08) : Color.primary.opacity(0.03)
    }

    private var rowBorder: Color {
        action.isProminent ? MomentsTheme.brandPalette.accent.opacity(0.20) : Color.primary.opacity(0.06)
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
