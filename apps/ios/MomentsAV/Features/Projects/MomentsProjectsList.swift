import SwiftUI

struct MomentsProjectsList: View {
    let projectSummary: MomentsProjectListSummary
    let selectedProjectId: String?
    let selectProject: (MomentDraftProject) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            summaryRow
            projectGroup(title: "In progress", projects: projectSummary.groups.inProgress)
            projectGroup(title: "Finished", projects: projectSummary.groups.finished)
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 10) {
            MomentsProjectsListSummaryPill(
                title: "Total",
                value: projectSummary.projectCount,
                systemImage: "rectangle.stack"
            )
            MomentsProjectsListSummaryPill(
                title: "Active",
                value: projectSummary.inProgressCount,
                systemImage: "clock"
            )
            MomentsProjectsListSummaryPill(
                title: "Done",
                value: projectSummary.finishedCount,
                systemImage: "checkmark.circle"
            )
        }
    }

    @ViewBuilder
    private func projectGroup(title: String, projects: [MomentDraftProject]) -> some View {
        if !projects.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(projects.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ForEach(projects) { project in
                    projectRow(project)
                }
            }
        }
    }

    private func projectRow(_ project: MomentDraftProject) -> some View {
        let isSelected = selectedProjectId == project.id

        return Button {
            selectProject(project)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                MomentsProjectStatusMarker(status: project.status)

                VStack(alignment: .leading, spacing: 8) {
                    Text(project.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        MomentsProjectListMetadata(
                            systemImage: "clock",
                            text: MomentsDateFormatting.formattedDate(milliseconds: project.updatedAt)
                        )
                        MomentsProjectListMetadata(
                            systemImage: "play.rectangle",
                            text: "\(Int(project.previewCount))/\(Int(project.previewLimit)) previews"
                        )
                    }

                    HStack(spacing: 8) {
                        Text(MomentsProjectStatusRules.displayTitle(for: project.status))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(MomentsTheme.brandPalette.accent)
                        Text("\(Int(project.creditCost)) credits")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "chevron.up.circle.fill" : "chevron.right.circle")
                    .foregroundStyle(isSelected ? MomentsTheme.brandPalette.accent : .secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

private struct MomentsProjectsListSummaryPill: View {
    let title: String
    let value: Int
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MomentsTheme.brandPalette.accent)
            Text("\(value)")
                .font(.subheadline.weight(.semibold))
            Text(title)
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
    let status: String

    var body: some View {
        Image(systemName: MomentsProjectStatusRules.isFinishedStatus(status) ? "checkmark.circle.fill" : "circle.dashed")
            .font(.subheadline)
            .foregroundStyle(MomentsProjectStatusRules.isFinishedStatus(status) ? MomentsTheme.brandPalette.accent : .secondary)
            .frame(width: 20)
    }
}

private struct MomentsProjectListMetadata: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
    }
}
