import AVAppShellFoundation
import SwiftUI

struct MomentsProjectMediaSection: View {
    let mediaAssets: [MomentMediaAsset]

    private var presentation: MomentsProjectMediaSectionPresentation {
        MomentsProjectMediaSectionPresentation(mediaAssets: mediaAssets)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AVAppShellSectionHeader(title: presentation.title)

            if presentation.mediaAssets.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: presentation.emptySystemImage,
                    message: presentation.emptyMessage
                )
            } else {
                MomentsSharedSyncedMediaGrid(mediaAssets: mediaAssets)
            }
        }
    }
}

struct MomentsProjectStorySection: View {
    let storyScenes: [MomentStoryScene]

    private var presentation: MomentsProjectStorySectionPresentation {
        MomentsProjectStorySectionPresentation(storyScenes: storyScenes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AVAppShellSectionHeader(title: presentation.title)

            if presentation.storyScenes.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: presentation.emptySystemImage,
                    message: presentation.emptyMessage
                )
            } else {
                ForEach(presentation.storyScenes) { storyScene in
                    MomentsProjectStorySceneRow(presentation: storyScene)
                }
            }
        }
    }
}

struct MomentsProjectEmptySectionRow: View {
    let systemImage: String
    let message: String

    var body: some View {
        AVAppShellInlineMessage(message: message, systemImage: systemImage)
    }
}

struct MomentsProjectMediaAssetRow: View {
    let presentation: MomentsProjectMediaAssetPresentation

    var body: some View {
        AVAppShellInfoRow(
            title: presentation.title,
            detail: presentation.detail,
            systemImage: presentation.systemImage
        )
    }
}

struct MomentsProjectStorySceneRow: View {
    let presentation: MomentsProjectStoryScenePresentation

    var body: some View {
        AVAppShellInfoRow(
            title: presentation.caption,
            detail: presentation.title,
            systemImage: "rectangle.stack.fill"
        )
    }
}
