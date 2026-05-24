import SwiftUI

struct MomentsProjectWorkspaceSummary: View {
    let workspace: MomentProjectWorkspace
    private var presentation: MomentsProjectWorkspaceSummaryPresentation {
        MomentsProjectWorkspaceSummaryPresentation(workspace: workspace)
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(presentation.tiles) { tile in
                MomentsProjectSummaryTile(tile: tile)
            }
        }
    }
}

private struct MomentsProjectSummaryTile: View {
    let tile: MomentsProjectSummaryTilePresentation

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: tile.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MomentsTheme.brandPalette.accent)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(tile.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(tile.value)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .topLeading)
        .padding(10)
        .background(MomentsTheme.brandPalette.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}
