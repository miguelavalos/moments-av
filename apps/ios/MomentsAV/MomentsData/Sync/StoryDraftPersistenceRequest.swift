import Foundation

struct StoryScenePersistenceRequest {
    let sceneIndex: Int
    let mediaAssetIds: [String]
    let caption: String
    let narrationText: String
    let tone: String?
    let musicCue: String?
    let durationMs: Int
    let createdBy: String
}

struct StoryReadyPersistenceRequest {
    let workflowRunId: String
    let moderationStatus: String
}

extension StoryScenePersistenceRequest {
    static func scene(_ scene: MomentsStoryDraftScene) -> StoryScenePersistenceRequest {
        StoryScenePersistenceRequest(
            sceneIndex: scene.sceneIndex,
            mediaAssetIds: scene.mediaAssetIds,
            caption: scene.caption,
            narrationText: scene.narrationText,
            tone: scene.tone,
            musicCue: scene.musicCue,
            durationMs: scene.durationMs,
            createdBy: "avi"
        )
    }
}

extension StoryReadyPersistenceRequest {
    static func draft(_ draft: MomentsStoryDraftResponse) -> StoryReadyPersistenceRequest {
        StoryReadyPersistenceRequest(
            workflowRunId: draft.workflowRunId,
            moderationStatus: draft.moderationStatus == "allowed" ? "approved" : "blocked"
        )
    }
}
