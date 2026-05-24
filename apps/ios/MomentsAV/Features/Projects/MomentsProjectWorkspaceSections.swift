import SwiftUI

struct MomentsProjectMediaSection: View {
    let mediaAssets: [MomentMediaAsset]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Media")
                .font(.subheadline.weight(.semibold))

            if mediaAssets.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: "photo.badge.plus",
                    message: "Add photos or clips from Create to unlock story drafting."
                )
            } else {
                ForEach(mediaAssets.sorted { $0.sortOrder < $1.sortOrder }) { media in
                    MomentsProjectMediaAssetRow(media: media)
                }
            }
        }
    }
}

struct MomentsProjectStorySection: View {
    let storyScenes: [MomentStoryScene]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Story")
                .font(.subheadline.weight(.semibold))

            if storyScenes.isEmpty {
                MomentsProjectEmptySectionRow(
                    systemImage: "text.bubble",
                    message: "Generate a story draft after the project has enough media."
                )
            } else {
                ForEach(storyScenes.sorted { $0.sceneIndex < $1.sceneIndex }) { scene in
                    MomentsProjectStorySceneRow(scene: scene)
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
    let media: MomentMediaAsset

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: media.kind == "video" ? "video" : "photo")
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(MomentsProjectStatusRules.displayKind(media.kind)) \(Int(media.sortOrder) + 1)")
                    .font(.caption.weight(.semibold))
                Text(MomentsProjectFormatting.mediaAssetDetail(media))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

struct MomentsProjectStorySceneRow: View {
    let scene: MomentStoryScene

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Scene \(Int(scene.sceneIndex) + 1)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(scene.caption)
                .font(.caption)
        }
    }
}
