import AVAppShellFoundation
import SwiftUI

struct MomentsCreateWorkspaceProgress: View {
    let summary: MomentsCreateWorkspaceSummary
    let minimumMediaCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AVAppShellSectionHeader(title: MomentsL10n.string("create.progress.title"))
            AVAppShellProgressRow(
                title: MomentsL10n.string("create.progress.media"),
                detail: summary.mediaDetail,
                systemImage: "photo.on.rectangle",
                isComplete: summary.mediaCount >= minimumMediaCount,
            )
            AVAppShellProgressRow(
                title: MomentsL10n.string("project.progress.story"),
                detail: summary.storyDetail,
                systemImage: "text.bubble",
                isComplete: summary.sceneCount > 0,
            )
            AVAppShellProgressRow(
                title: MomentsL10n.string("project.kind.storyReview"),
                detail: summary.previewDetail,
                systemImage: "text.bubble",
                isComplete: summary.hasPreviewArtifact,
            )
            AVAppShellProgressRow(
                title: MomentsL10n.string("project.artifact.final.title"),
                detail: summary.hasFinalExport ? MomentsL10n.string("create.status.ready") : MomentsL10n.string("create.progress.finalNotMade"),
                systemImage: "square.and.arrow.up",
                isComplete: summary.hasFinalExport,
            )
        }
    }
}
