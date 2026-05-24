@preconcurrency import ConvexMobile
import Foundation

extension MomentsProjectRemoteClient {
    func saveStoryDraft(
        ownerUserId: String,
        projectId: String,
        draft: MomentsStoryDraftResponse
    ) async throws {
        for scene in draft.scenes {
            try await upsertStoryScene(
                ownerUserId: ownerUserId,
                projectId: projectId,
                scene: scene
            )
        }

        try await markStoryReady(
            ownerUserId: ownerUserId,
            projectId: projectId,
            draft: draft
        )
    }

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

    func storyModerationStatus(for draft: MomentsStoryDraftResponse) -> String {
        draft.moderationStatus == "allowed" ? "approved" : "blocked"
    }

    func convexStringArray(_ values: [String]) -> [ConvexEncodable?] {
        values.map { $0 as ConvexEncodable }
    }
}
