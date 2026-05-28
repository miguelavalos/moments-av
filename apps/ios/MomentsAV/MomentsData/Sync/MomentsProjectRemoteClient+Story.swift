@preconcurrency import ConvexMobile
import Foundation

extension MomentsProjectRemoteClient {
    func saveStoryDraft(
        ownerUserId: String,
        projectId: String,
        draft: MomentsStoryDraftResponse,
        storyInputSignature: String
    ) async throws {
        for scene in draft.scenes {
            try await upsertStoryScene(
                ownerUserId: ownerUserId,
                projectId: projectId,
                request: .scene(scene)
            )
        }

        try await markStoryReady(
            ownerUserId: ownerUserId,
            projectId: projectId,
            request: .draft(draft, storyInputSignature: storyInputSignature)
        )
    }

    func upsertStoryScene(
        ownerUserId: String,
        projectId: String,
        request: StoryScenePersistenceRequest
    ) async throws {
        let client = try requireClient()

        let _: String? = try await retryingMutation(
            client: client,
            name: "moments:upsertStoryScene",
            args: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
                "sceneIndex": request.sceneIndex,
                "mediaAssetIds": convexStringArray(request.mediaAssetIds),
                "caption": request.caption,
                "narrationText": request.narrationText,
                "tone": request.tone,
                "musicCue": request.musicCue,
                "durationMs": request.durationMs,
                "createdBy": request.createdBy
            ]
        )
    }

    func markStoryReady(
        ownerUserId: String,
        projectId: String,
        request: StoryReadyPersistenceRequest
    ) async throws {
        let client = try requireClient()

        let _: String? = try await retryingMutation(
            client: client,
            name: "moments:markStoryReady",
            args: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
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
