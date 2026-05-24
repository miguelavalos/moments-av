import Foundation

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

struct MomentsProjectStoryScenePresentation: Identifiable, Equatable {
    let id: String
    let title: String
    let caption: String

    init(scene: MomentStoryScene) {
        id = scene.id
        title = "Scene \(Int(scene.sceneIndex) + 1)"
        caption = scene.caption
    }

    static func sorted(_ scenes: [MomentStoryScene]) -> [MomentsProjectStoryScenePresentation] {
        scenes
            .sorted { $0.sceneIndex < $1.sceneIndex }
            .map(MomentsProjectStoryScenePresentation.init)
    }
}
