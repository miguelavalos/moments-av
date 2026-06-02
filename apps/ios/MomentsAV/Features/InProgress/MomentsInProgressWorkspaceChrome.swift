import AVAppShellFoundation
import SwiftUI

struct MomentsInProgressWorkspaceHeader: View {
    let workspace: MomentProjectWorkspace
    private var presentation: MomentsInProgressWorkspaceHeaderPresentation {
        MomentsInProgressWorkspaceHeaderPresentation(workspace: workspace)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(presentation.title)
                .font(.subheadline.weight(.semibold))
            Text(presentation.updatedAtTitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(presentation.countsTitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct MomentsInProgressNextActionRow: View {
    let action: MomentsProjectNextAction

    var body: some View {
        AVAppShellInfoRow(
            title: action.title,
            detail: action.message,
            systemImage: action.systemImage
        )
    }
}

struct MomentsInProgressContinueButton: View {
    let action: MomentsProjectNextAction
    let continueProject: () -> Void

    var body: some View {
        AVAppShellPrimaryButton(
            action.primaryButtonTitle,
            systemImage: "arrow.right.circle",
            action: continueProject
        )
    }
}

struct MomentsInProgressDeleteButton: View {
    let isDeletingProject: Bool
    let requestDeleteProject: () -> Void

    var body: some View {
        Button(role: .destructive) {
            requestDeleteProject()
        } label: {
            Label(isDeletingProject ? L10n.string("inProgress.deleteMoment.deleting") : L10n.string("inProgress.deleteMoment.shortButton"), systemImage: "trash")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(isDeletingProject)
    }
}
