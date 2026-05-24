import SwiftUI

struct MomentsProjectMediaSection: View {
    let mediaAssets: [MomentMediaAsset]

    private var presentations: [MomentsProjectMediaAssetPresentation] {
        MomentsProjectMediaAssetPresentation.sorted(mediaAssets)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Media")
                .font(.subheadline.weight(.semibold))

            if presentations.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: "photo.badge.plus",
                    message: "Add photos or clips from Create to unlock story drafting."
                )
            } else {
                ForEach(presentations) { presentation in
                    MomentsProjectMediaAssetRow(presentation: presentation)
                }
            }
        }
    }
}

struct MomentsProjectStorySection: View {
    let storyScenes: [MomentStoryScene]

    private var presentations: [MomentsProjectStoryScenePresentation] {
        MomentsProjectStoryScenePresentation.sorted(storyScenes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Story")
                .font(.subheadline.weight(.semibold))

            if presentations.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: "text.bubble",
                    message: "Generate a story draft after the project has enough media."
                )
            } else {
                ForEach(presentations) { presentation in
                    MomentsProjectStorySceneRow(presentation: presentation)
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
