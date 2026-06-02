import SwiftUI

struct MomentsCreateActiveMomentSection: View {
    let presentation: MomentsCreateSetupPresentation
    let minimumMediaCount: Int
    let discardMoment: () -> Void

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

            HStack {
                Spacer(minLength: 0)

                Button(action: discardMoment) {
                    Label(L10n.string("create.discard.current"), systemImage: "trash")
                }
                .font(.system(size: 13, weight: .bold))
                .buttonStyle(MomentsCreateNeutralInlineButtonStyle())
                .disabled(!presentation.canStartAnotherMoment)
            }
        }
    }
}
