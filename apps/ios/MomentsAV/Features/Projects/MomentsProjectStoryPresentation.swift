import Foundation

struct MomentsProjectStorySectionPresentation: Equatable {
    let title = "Story"
    let emptySystemImage = "text.bubble"
    let emptyMessage = "Prepare the story after this Moment has enough media."
    let storyScenes: [MomentsProjectStoryScenePresentation]

    init(storyScenes: [MomentStoryScene]) {
        self.storyScenes = MomentsProjectStoryScenePresentation.sorted(storyScenes)
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
