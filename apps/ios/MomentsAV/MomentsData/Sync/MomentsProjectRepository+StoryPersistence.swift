import Foundation

extension MomentsProjectRepository {
    func saveStoryDraft(
        ownerUserId: String,
        projectId: String,
        draft: MomentsStoryDraftResponse
    ) async throws {
        for scene in draft.scenes {
            try await remoteClient.upsertStoryScene(
                ownerUserId: ownerUserId,
                projectId: projectId,
                scene: scene
            )
        }

        try await remoteClient.markStoryReady(
            ownerUserId: ownerUserId,
            projectId: projectId,
            draft: draft
        )
    }
}
