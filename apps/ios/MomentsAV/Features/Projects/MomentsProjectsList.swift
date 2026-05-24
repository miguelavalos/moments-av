import SwiftUI

struct MomentsProjectsList: View {
    let projectSummary: MomentsProjectListSummary
    let selectedProjectId: String?
    let selectProject: (MomentDraftProject) -> Void
    private var presentation: MomentsProjectsListPresentation {
        MomentsProjectsListPresentation.make(
            projectSummary: projectSummary,
            selectedProjectId: selectedProjectId
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MomentsProjectsListSummaryRow(pills: presentation.summaryPills)

            ForEach(presentation.groups) { group in
                MomentsProjectsListGroup(
                    group: group,
                    selectProject: selectProject
                )
            }
        }
    }
}

private struct MomentsProjectsListSummaryRow: View {
    let pills: [MomentsProjectsListSummaryPresentation]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(pills) { pill in
                MomentsProjectsListSummaryPill(pill: pill)
            }
        }
    }
}

private struct MomentsProjectsListGroup: View {
    let group: MomentsProjectsListGroupPresentation
    let selectProject: (MomentDraftProject) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(group.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(group.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ForEach(group.rows) { row in
                MomentsProjectsListRow(row: row) {
                    selectProject(row.project)
                }
            }
        }
    }
}

private struct MomentsProjectsListRow: View {
    let row: MomentsProjectsListRowPresentation
    let selectProject: () -> Void

    var body: some View {
        Button {
            selectProject()
        } label: {
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
                            .foregroundStyle(MomentsTheme.brandPalette.accent)
                        Text(row.creditCostTitle)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: row.accessorySystemImage)
                    .foregroundStyle(row.isSelected ? MomentsTheme.brandPalette.accent : .secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

private struct MomentsProjectsListSummaryPill: View {
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

private struct MomentsProjectStatusMarker: View {
    let row: MomentsProjectsListRowPresentation

    var body: some View {
        Image(systemName: row.statusSystemImage)
            .font(.subheadline)
            .foregroundStyle(row.isFinished ? MomentsTheme.brandPalette.accent : .secondary)
            .frame(width: 20)
    }
}

private struct MomentsProjectListMetadata: View {
    let metadata: MomentsProjectsListMetadataPresentation

    var body: some View {
        Label(metadata.text, systemImage: metadata.systemImage)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
    }
}
