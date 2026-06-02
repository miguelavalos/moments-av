import SwiftUI

struct MomentsInProgressWorkspaceDetail: View {
    let workspace: MomentProjectWorkspace
    let isDeletingProject: Bool
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void
    private var presentation: MomentsInProgressWorkspaceDetailPresentation {
        MomentsInProgressWorkspaceDetailPresentation(workspace: workspace)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(presentation.title)
                .font(.headline)

            MomentsInProgressWorkspaceHeader(workspace: workspace)
            MomentsInProgressNextActionRow(action: presentation.nextAction)
            MomentsInProgressWorkspaceSummary(workspace: workspace)
            MomentsInProgressProgressSection(workspace: workspace)

            MomentsProjectPreviewArtifactSection(artifacts: workspace.artifacts)
            MomentsProjectFinalExportSection(artifacts: workspace.artifacts)

            MomentsInProgressMediaSection(mediaAssets: workspace.mediaAssets)
            MomentsInProgressStorySection(storyScenes: workspace.storyScenes)
            MomentsInProgressRenderJobsSection(renderJobs: workspace.renderJobs)
            MomentsInProgressContinueButton(action: presentation.nextAction) {
                continueProject(presentation.continuationRequest)
            }
            MomentsInProgressDeleteButton(isDeletingProject: isDeletingProject) {
                requestDeleteProject(workspace.project)
            }
        }
    }
}

struct MomentsInProgressLoadingDetail: View {
    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
            Text(L10n.string("projects.loadingDetail"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
