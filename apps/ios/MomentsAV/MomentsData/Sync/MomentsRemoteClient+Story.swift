@preconcurrency import ConvexMobile
import Foundation

extension MomentsRemoteClient {
    func saveStoryDraft(
        ownerUserId: String,
        momentId: String,
        draft: MomentsStoryDraftResponse,
        storyInputSignature: String
    ) async throws {
        for scene in draft.scenes {
            try await upsertStoryScene(
                ownerUserId: ownerUserId,
                momentId: momentId,
                request: .scene(scene)
            )
        }

        try await markStoryReady(
            ownerUserId: ownerUserId,
            momentId: momentId,
            request: .draft(draft, storyInputSignature: storyInputSignature)
        )
    }

    func upsertStoryScene(
        ownerUserId: String,
        momentId: String,
        request: StoryScenePersistenceRequest
    ) async throws {
        let client = try requireClient()

        let _: String? = try await retryingMutation(
            client: client,
            name: "moments:upsertStoryScene",
            args: [
                "ownerUserId": ownerUserId,
                "momentId": momentId,
                "sceneIndex": request.sceneIndex,
                "mediaAssetIds": convexStringArray(request.mediaAssetIds),
                "caption": request.caption,
                "narrationText": request.narrationText,
                "mood": request.mood,
                "musicCue": request.musicCue,
                "durationMs": request.durationMs,
                "createdBy": request.createdBy
            ]
        )
    }

    func markStoryReady(
        ownerUserId: String,
        momentId: String,
        request: StoryReadyPersistenceRequest
    ) async throws {
        let client = try requireClient()

        let _: String? = try await retryingMutation(
            client: client,
            name: "moments:markStoryReady",
            args: [
                "ownerUserId": ownerUserId,
                "momentId": momentId,
                "workflowRunId": request.workflowRunId,
                "moderationStatus": request.moderationStatus,
                "storyInputSignature": request.storyInputSignature
            ]
        )
    }

    func convexStringArray(_ values: [String]) -> [ConvexEncodable?] {
        values.map { $0 as ConvexEncodable }
    }
}
