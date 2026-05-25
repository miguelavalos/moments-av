import AVAppShellFoundation
import SwiftUI

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
