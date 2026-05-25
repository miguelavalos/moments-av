import SwiftUI

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
