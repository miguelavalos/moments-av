import AVAppShellFoundation
import AVBrandFoundation
import Photos
import SwiftUI
import UIKit

struct MomentsCreateMediaRow: View {
    let media: MomentsSelectedMedia
    let remove: () -> Void

    var body: some View {
        AVAppShellInfoRow(
            title: media.originalFilename,
            detail: "\(media.kind.capitalized) · \(media.displaySize)",
            systemImage: media.kind == "video" ? "video.fill" : "photo.fill"
        ) {
            Button(role: .destructive, action: remove) {
                Image(systemName: "minus.circle")
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(media.originalFilename)")
        }
    }
}

struct MomentsCreateMediaThumbnailTile: View {
    let media: MomentsSelectedMedia
    let index: Int
    let openDetails: () -> Void

    var body: some View {
        Button(action: openDetails) {
            ZStack(alignment: .bottomLeading) {
                thumbnail

                Text("\(index + 1)")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.48), in: Capsule())
                    .padding(7)
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(media.kind.capitalized) \(index + 1)")
    }

    @ViewBuilder
    private var thumbnail: some View {
        if media.kind == "photo", let image = UIImage(data: media.data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            ZStack {
                AVBrandColor.neutral100
                Image(systemName: media.kind == "video" ? "video.fill" : "photo.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(MomentsTheme.highlight)
            }
        }
    }
}

struct MomentsCreateMediaDetailSheet: View {
    let media: MomentsSelectedMedia
    let remove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            preview

            VStack(alignment: .leading, spacing: 6) {
                Text(media.kind.capitalized)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                Text(media.displaySize)
                    .font(AVBrandTypography.captionStrong)
                    .foregroundStyle(AVBrandColor.textSecondary)
            }

            Button(role: .destructive, action: remove) {
                Label("Remove from project", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Spacer(minLength: 0)
        }
        .padding(20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var preview: some View {
        if media.kind == "photo", let image = UIImage(data: media.data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(1.25, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            ZStack {
                AVBrandColor.neutral100
                Image(systemName: media.kind == "video" ? "video.fill" : "photo.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(MomentsTheme.highlight)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.25, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

struct MomentsCreateSyncedMediaThumbnailTile: View {
    let media: MomentMediaAsset
    let index: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            MomentsCreateSyncedMediaThumbnailImage(media: media)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white, MomentsTheme.highlight)
                .padding(7)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityLabel("\(media.kind.capitalized) \(index + 1)")
    }
}

struct MomentsCreateSyncedMediaThumbnailImage: View {
    let media: MomentMediaAsset
    var size: CGFloat?
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                AVBrandColor.neutral100
                Image(systemName: media.kind == "video" ? "video.fill" : "photo.fill")
                    .font(.system(size: size == nil ? 24 : 20, weight: .semibold))
                    .foregroundStyle(MomentsTheme.highlight)
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .task(id: "\(media.id)-\(media.platformMediaAssetId ?? "")") {
            image = MomentsLocalMediaThumbnailCache.thumbnail(
                mediaAssetId: media.id,
                platformMediaAssetId: media.platformMediaAssetId
            )
            guard image == nil else { return }
            image = await MomentsCreateLocalPhotoThumbnailLoader.thumbnail(
                for: media.platformMediaAssetId,
                targetSize: CGSize(width: 220, height: 220)
            )
            if let image {
                MomentsLocalMediaThumbnailCache.store(
                    image,
                    mediaAssetId: media.id,
                    platformMediaAssetId: media.platformMediaAssetId
                )
            }
        }
    }
}

private enum MomentsCreateLocalPhotoThumbnailLoader {
    static func thumbnail(for localIdentifier: String?, targetSize: CGSize) async -> UIImage? {
        guard let localIdentifier, !localIdentifier.isEmpty else { return nil }
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = result.firstObject else { return nil }

        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

struct MomentsCreateSyncedMediaRow: View {
    let media: MomentMediaAsset

    var body: some View {
        AVAppShellInfoRow(
            title: "\(MomentsProjectStatusRules.displayKind(media.kind)) \(Int(media.sortOrder) + 1)",
            detail: MomentsProjectFormatting.mediaAssetDetail(media),
            systemImage: media.kind == "video" ? "video.fill" : "photo.fill"
        ) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(MomentsTheme.highlight)
                .font(.system(size: 18, weight: .semibold))
        }
    }
}

struct MomentsCreateEmptySectionRow: View {
    let systemImage: String
    let message: String

    var body: some View {
        AVAppShellInlineMessage(message: message, systemImage: systemImage)
    }
}
