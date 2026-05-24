import SwiftUI

struct MomentsProjectWorkspaceDetail: View {
    let workspace: MomentProjectWorkspace
    let isDeletingProject: Bool
    let continueProject: (MomentDraftProject) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project detail")
                .font(.headline)

            header
            MomentsProjectNextActionRow(action: MomentsProjectStatusRules.nextAction(for: workspace))
            MomentsProjectWorkspaceSummary(workspace: workspace)
            MomentsProjectProgressSection(workspace: workspace)

            MomentsProjectPreviewArtifactSection(artifacts: workspace.artifacts)
            MomentsProjectFinalExportSection(artifacts: workspace.artifacts)

            MomentsProjectMediaSection(mediaAssets: workspace.mediaAssets)
            MomentsProjectStorySection(storyScenes: workspace.storyScenes)
            MomentsProjectRenderJobsSection(renderJobs: workspace.renderJobs)
            continueProjectButton
            deleteProjectButton
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workspace.project.title)
                .font(.subheadline.weight(.semibold))
            Text("Updated \(MomentsDateFormatting.formattedDate(milliseconds: workspace.project.updatedAt))")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Media \(workspace.mediaAssets.count) · Scenes \(workspace.storyScenes.count) · Jobs \(workspace.renderJobs.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var continueProjectButton: some View {
        Button {
            continueProject(workspace.project)
        } label: {
            Label("Continue in Create", systemImage: "arrow.right.circle")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }

    private var deleteProjectButton: some View {
        Button(role: .destructive) {
            requestDeleteProject(workspace.project)
        } label: {
            Label(isDeletingProject ? "Deleting project..." : "Delete project", systemImage: "trash")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(isDeletingProject)
    }
}

private struct MomentsProjectNextActionRow: View {
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

struct MomentsProjectLoadingDetail: View {
    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
            Text("Loading project detail...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
