import SwiftUI

struct MomentsCreateMediaRow: View {
    let media: MomentsSelectedMedia
    let remove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: media.kind == "video" ? "video" : "photo")
            VStack(alignment: .leading, spacing: 3) {
                Text(media.originalFilename)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text("\(media.kind.capitalized) · \(media.displaySize)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(role: .destructive, action: remove) {
                Image(systemName: "minus.circle")
            }
        }
    }
}

struct MomentsCreateSyncedMediaRow: View {
    let media: MomentMediaAsset

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: media.kind == "video" ? "video" : "photo")
                .foregroundStyle(.secondary)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(MomentsProjectStatusRules.displayKind(media.kind)) \(Int(media.sortOrder) + 1)")
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(MomentsProjectFormatting.mediaAssetDetail(media))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(MomentsTheme.brandPalette.accent)
        }
    }
}

struct MomentsCreateEmptySectionRow: View {
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
