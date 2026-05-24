import Foundation

extension MomentsProjectRemoteClient {
    func upsertStoryScene(
        ownerUserId: String,
        projectId: String,
        scene: MomentsStoryDraftScene
    ) async throws {
        let client = try requireClient()

        let _: String? = try await client.mutation(
            "moments:upsertStoryScene",
            with: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
                "sceneIndex": scene.sceneIndex,
                "mediaAssetIds": convexStringArray(scene.mediaAssetIds),
                "caption": scene.caption,
                "narrationText": scene.narrationText,
                "tone": scene.tone,
                "musicCue": scene.musicCue,
                "durationMs": scene.durationMs,
                "createdBy": "avi"
            ]
        )
    }

    func markStoryReady(
        ownerUserId: String,
        projectId: String,
        draft: MomentsStoryDraftResponse
    ) async throws {
        let client = try requireClient()

        let _: String? = try await client.mutation(
            "moments:markStoryReady",
            with: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
                "workflowRunId": draft.workflowRunId,
                "moderationStatus": storyModerationStatus(for: draft)
            ]
        )
    }
}
