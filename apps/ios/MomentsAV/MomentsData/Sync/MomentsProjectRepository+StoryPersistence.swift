import Foundation

extension MomentsProjectRepository {
    func saveStoryDraft(
        ownerUserId: String,
        projectId: String,
        draft: MomentsStoryDraftResponse
    ) async throws {
        try await remoteClient.saveStoryDraft(
            ownerUserId: ownerUserId,
            projectId: projectId,
            draft: draft
        )
    }
}
