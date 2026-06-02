import SwiftUI

struct MomentsCreateActiveMomentSection: View {
    let presentation: MomentsCreateSetupPresentation
    let minimumMediaCount: Int
    let discardDraft: () -> Void

    @ViewBuilder
    var body: some View {
        if presentation.activeMomentId != nil {
            Label(presentation.activeMomentLabel, systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.green)

            Text(presentation.activeMomentDetail)
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
