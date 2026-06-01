import AVAppShellFoundation
import SwiftUI

struct MomentsProjectWorkspaceHeader: View {
    let workspace: MomentProjectWorkspace
    private var presentation: MomentsProjectWorkspaceHeaderPresentation {
        MomentsProjectWorkspaceHeaderPresentation(workspace: workspace)
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

struct MomentsProjectNextActionRow: View {
    let action: MomentsProjectNextAction

    var body: some View {
        AVAppShellInfoRow(
            title: action.title,
            detail: action.message,
            systemImage: action.systemImage
        )
    }
}

struct MomentsProjectContinueButton: View {
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

struct MomentsProjectDeleteButton: View {
    let isDeletingProject: Bool
    let requestDeleteProject: () -> Void

    var body: some View {
        Button(role: .destructive) {
            requestDeleteProject()
        } label: {
            Label(isDeletingProject ? MomentsL10n.string("projects.deleteProject.deleting") : MomentsL10n.string("projects.deleteProject.shortButton"), systemImage: "trash")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(isDeletingProject)
    }
}
