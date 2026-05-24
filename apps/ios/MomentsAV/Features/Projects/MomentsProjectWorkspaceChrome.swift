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
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: action.systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MomentsTheme.brandPalette.accent)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                Text(action.title)
                    .font(.caption.weight(.semibold))
                Text(action.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(10)
        .background(MomentsTheme.brandPalette.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct MomentsProjectContinueButton: View {
    let action: MomentsProjectNextAction
    let continueProject: () -> Void

    var body: some View {
        Button {
            continueProject()
        } label: {
            Label(action.primaryButtonTitle, systemImage: "arrow.right.circle")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
}

struct MomentsProjectDeleteButton: View {
    let isDeletingProject: Bool
    let requestDeleteProject: () -> Void

    var body: some View {
        Button(role: .destructive) {
            requestDeleteProject()
        } label: {
            Label(isDeletingProject ? "Deleting project..." : "Delete project", systemImage: "trash")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(isDeletingProject)
    }
}
