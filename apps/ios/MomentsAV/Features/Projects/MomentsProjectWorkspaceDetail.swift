import SwiftUI

struct MomentsProjectWorkspaceDetail: View {
    let workspace: MomentProjectWorkspace
    let isDeletingProject: Bool
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void
    private var presentation: MomentsProjectWorkspaceDetailPresentation {
        MomentsProjectWorkspaceDetailPresentation(workspace: workspace)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(presentation.title)
                .font(.headline)

            MomentsProjectWorkspaceHeader(workspace: workspace)
            MomentsProjectNextActionRow(action: presentation.nextAction)
            MomentsProjectWorkspaceSummary(workspace: workspace)
            MomentsProjectProgressSection(workspace: workspace)

            MomentsProjectPreviewArtifactSection(artifacts: workspace.artifacts)
            MomentsProjectFinalExportSection(artifacts: workspace.artifacts)

            MomentsProjectMediaSection(mediaAssets: workspace.mediaAssets)
            MomentsProjectStorySection(storyScenes: workspace.storyScenes)
            MomentsProjectRenderJobsSection(renderJobs: workspace.renderJobs)
            MomentsProjectContinueButton(action: presentation.nextAction) {
                continueProject(presentation.continuationRequest)
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
            Text(MomentsL10n.string("projects.loadingDetail"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
