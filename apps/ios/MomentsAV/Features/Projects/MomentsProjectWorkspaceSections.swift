import SwiftUI

struct MomentsProjectMediaSection: View {
    let mediaAssets: [MomentMediaAsset]

    private var presentation: MomentsProjectMediaSectionPresentation {
        MomentsProjectMediaSectionPresentation(mediaAssets: mediaAssets)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(presentation.title)
                .font(.subheadline.weight(.semibold))

            if presentation.mediaAssets.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: presentation.emptySystemImage,
                    message: presentation.emptyMessage
                )
            } else {
                ForEach(presentation.mediaAssets) { mediaAsset in
                    MomentsProjectMediaAssetRow(presentation: mediaAsset)
                }
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
            Text(presentation.title)
                .font(.subheadline.weight(.semibold))

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
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 18)

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.vertical, 2)
    }
}

struct MomentsProjectMediaAssetRow: View {
    let presentation: MomentsProjectMediaAssetPresentation

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: presentation.systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text(presentation.title)
                    .font(.caption.weight(.semibold))
                Text(presentation.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

struct MomentsProjectStorySceneRow: View {
    let presentation: MomentsProjectStoryScenePresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(presentation.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(presentation.caption)
                .font(.caption)
        }
    }
}
