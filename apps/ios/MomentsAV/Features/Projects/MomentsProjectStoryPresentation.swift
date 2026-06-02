import Foundation

struct MomentsProjectStorySectionPresentation: Equatable {
    let title = L10n.string("project.story.title")
    let emptySystemImage = "text.bubble"
    let emptyMessage = L10n.string("project.story.empty")
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
        title = L10n.string("project.story.scene", Int(scene.sceneIndex) + 1)
        caption = scene.caption
    }

    static func sorted(_ scenes: [MomentStoryScene]) -> [MomentsProjectStoryScenePresentation] {
        scenes
            .sorted { $0.sceneIndex < $1.sceneIndex }
            .map(MomentsProjectStoryScenePresentation.init)
    }
}
