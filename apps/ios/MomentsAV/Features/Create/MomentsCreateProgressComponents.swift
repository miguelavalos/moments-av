import AVAppShellFoundation
import SwiftUI

struct MomentsCreateWorkspaceProgress: View {
    let summary: MomentsCreateWorkspaceSummary
    let minimumMediaCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AVAppShellSectionHeader(title: "Workspace progress")
            AVAppShellProgressRow(
                title: "Photos and clips",
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
                title: "Story Review",
                detail: summary.previewDetail,
                systemImage: "text.bubble",
                isComplete: summary.hasPreviewArtifact,
            )
            AVAppShellProgressRow(
                title: "Final video",
                detail: summary.hasFinalExport ? "Ready" : "Not made yet",
                systemImage: "square.and.arrow.up",
                isComplete: summary.hasFinalExport,
            )
        }
    }
}
