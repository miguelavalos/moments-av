import Foundation

extension MomentsRepository {
    func saveStoryDraft(
        ownerUserId: String,
        momentId: String,
        draft: MomentsStoryDraftResponse,
        storyInputSignature: String
    ) async throws {
        try await remoteClient.saveStoryDraft(
            ownerUserId: ownerUserId,
            momentId: momentId,
            draft: draft,
            storyInputSignature: storyInputSignature
        )
    }
}
