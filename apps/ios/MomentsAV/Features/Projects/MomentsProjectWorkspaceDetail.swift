import SwiftUI

struct MomentsProjectWorkspaceDetail: View {
    let workspace: MomentProjectWorkspace
    let isDeletingProject: Bool
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void
    private var nextAction: MomentsProjectNextAction {
        MomentsProjectStatusRules.nextAction(for: workspace)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project detail")
                .font(.headline)

            MomentsProjectWorkspaceHeader(workspace: workspace)
            MomentsProjectNextActionRow(action: nextAction)
            MomentsProjectWorkspaceSummary(workspace: workspace)
            MomentsProjectProgressSection(workspace: workspace)

            MomentsProjectPreviewArtifactSection(artifacts: workspace.artifacts)
            MomentsProjectFinalExportSection(artifacts: workspace.artifacts)

            MomentsProjectMediaSection(mediaAssets: workspace.mediaAssets)
            MomentsProjectStorySection(storyScenes: workspace.storyScenes)
            MomentsProjectRenderJobsSection(renderJobs: workspace.renderJobs)
            MomentsProjectContinueButton(action: nextAction) {
                continueProject(
                    MomentsProjectContinuationRequest(
                        project: workspace.project,
                        focus: nextAction.continuationFocus
                    )
                )
            }
            MomentsProjectDeleteButton(isDeletingProject: isDeletingProject) {
                requestDeleteProject(workspace.project)
            }
        }
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
