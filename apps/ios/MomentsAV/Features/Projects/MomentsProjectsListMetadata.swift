import SwiftUI

struct MomentsProjectStatusMarker: View {
    let row: MomentsProjectsListRowPresentation

    var body: some View {
        Image(systemName: row.statusSystemImage)
            .font(.subheadline)
            .foregroundStyle(row.isFinished ? MomentsTheme.brandPalette.accent : .secondary)
            .frame(width: 20)
    }
}

struct MomentsProjectListMetadata: View {
    let metadata: MomentsProjectsListMetadataPresentation

    var body: some View {
        Label(metadata.text, systemImage: metadata.systemImage)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
    }
}
