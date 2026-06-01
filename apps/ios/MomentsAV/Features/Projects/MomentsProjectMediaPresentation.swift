import Foundation

struct MomentsProjectMediaSectionPresentation: Equatable {
    let title = "Media"
    let emptySystemImage = "photo.badge.plus"
    let emptyMessage = "No media is attached to this Moment yet. Add photos or clips from Create to review the story."
    let mediaAssets: [MomentsProjectMediaAssetPresentation]

    init(mediaAssets: [MomentMediaAsset]) {
        self.mediaAssets = MomentsProjectMediaAssetPresentation.sorted(mediaAssets)
    }
}

struct MomentsProjectMediaAssetPresentation: Identifiable, Equatable {
    let id: String
    let systemImage: String
    let title: String
    let detail: String

    init(mediaAsset: MomentMediaAsset) {
        id = mediaAsset.id
        systemImage = mediaAsset.kind == "video" ? "video" : "photo"
        title = "\(MomentsProjectStatusRules.displayKind(mediaAsset.kind)) \(Int(mediaAsset.sortOrder) + 1)"
        detail = MomentsProjectFormatting.mediaAssetDetail(mediaAsset)
    }

    static func sorted(_ mediaAssets: [MomentMediaAsset]) -> [MomentsProjectMediaAssetPresentation] {
        mediaAssets
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(MomentsProjectMediaAssetPresentation.init)
    }
}
