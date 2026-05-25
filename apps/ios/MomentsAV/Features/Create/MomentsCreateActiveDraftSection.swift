import SwiftUI

struct MomentsCreateActiveDraftSection: View {
    let presentation: MomentsCreateDraftSetupPresentation
    let minimumMediaCount: Int
    let startAnotherProject: () -> Void

    @ViewBuilder
    var body: some View {
        if let activeProjectId = presentation.activeProjectId {
            Text("\(presentation.activeProjectLabel): \(activeProjectId)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(presentation.activeProjectDetail)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            MomentsCreateWorkspaceProgress(
                summary: presentation.workspaceSummary,
                minimumMediaCount: minimumMediaCount
            )

            Button(action: startAnotherProject) {
                Label("Start another project", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!presentation.canStartAnotherProject)
        }
    }
}
