import SwiftUI

struct MomentsProjectsListGroup: View {
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

