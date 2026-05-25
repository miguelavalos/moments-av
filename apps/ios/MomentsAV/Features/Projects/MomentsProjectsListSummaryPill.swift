import SwiftUI

struct MomentsProjectsListSummaryPill: View {
    let pill: MomentsProjectsListSummaryPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: pill.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MomentsTheme.brandPalette.accent)
            Text("\(pill.value)")
                .font(.subheadline.weight(.semibold))
            Text(pill.title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .topLeading)
        .padding(10)
        .background(MomentsTheme.brandPalette.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

