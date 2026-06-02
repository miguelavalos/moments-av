import SwiftUI

struct MomentsCreateActiveDraftSection: View {
    let presentation: MomentsCreateDraftSetupPresentation
    let minimumMediaCount: Int
    let discardDraft: () -> Void

    @ViewBuilder
    var body: some View {
        if presentation.activeMomentId != nil {
            Label(presentation.activeProjectLabel, systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.green)

            Text(presentation.activeProjectDetail)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            MomentsCreateWorkspaceProgress(
                summary: presentation.workspaceSummary,
                minimumMediaCount: minimumMediaCount
            )

            Button(action: discardDraft) {
                Label(L10n.string("create.workflowContent.discardMoment"), systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!presentation.canStartAnotherProject)
        }
    }
}
