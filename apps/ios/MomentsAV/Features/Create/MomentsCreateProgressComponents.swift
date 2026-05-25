import AVAppShellFoundation
import SwiftUI

struct MomentsCreateWorkspaceProgress: View {
    let summary: MomentsCreateWorkspaceSummary
    let minimumMediaCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AVAppShellSectionHeader(title: "Workspace progress")
            AVAppShellProgressRow(
                title: "Media",
                detail: summary.mediaDetail,
                systemImage: "photo.on.rectangle",
                isComplete: summary.mediaCount >= minimumMediaCount,
            )
            AVAppShellProgressRow(
                title: "Story",
                detail: summary.storyDetail,
                systemImage: "text.bubble",
                isComplete: summary.sceneCount > 0,
            )
            AVAppShellProgressRow(
                title: "Preview",
                detail: summary.previewDetail,
                systemImage: "play.rectangle",
                isComplete: summary.hasPreviewArtifact,
            )
            AVAppShellProgressRow(
                title: "Final export",
                detail: summary.hasFinalExport ? "Ready" : "Not rendered",
                systemImage: "square.and.arrow.up",
                isComplete: summary.hasFinalExport,
            )
        }
    }
}
