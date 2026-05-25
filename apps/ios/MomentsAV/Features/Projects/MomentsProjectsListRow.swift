import SwiftUI

struct MomentsProjectsListRow: View {
    let row: MomentsProjectsListRowPresentation
    let selectProject: () -> Void

    var body: some View {
        Button(action: selectProject) {
            HStack(alignment: .top, spacing: 12) {
                MomentsProjectStatusMarker(row: row)

                VStack(alignment: .leading, spacing: 8) {
                    Text(row.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        ForEach(row.metadata) { metadata in
                            MomentsProjectListMetadata(metadata: metadata)
                        }
                    }

                    HStack(spacing: 8) {
                        Text(row.statusTitle)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(MomentsTheme.highlight)
                        Text(row.creditCostTitle)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: row.accessorySystemImage)
                    .foregroundStyle(row.isSelected ? MomentsTheme.highlight : .secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

