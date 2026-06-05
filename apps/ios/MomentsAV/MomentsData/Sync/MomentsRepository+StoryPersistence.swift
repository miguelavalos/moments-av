import Foundation

extension MomentsRepository {
    func saveStory(
        ownerUserId: String,
        momentId: String,
        plan: MomentsStoryResponse,
        storyInputSignature: String
    ) async throws {
        try await remoteClient.saveStory(
            ownerUserId: ownerUserId,
            momentId: momentId,
            plan: plan,
            storyInputSignature: storyInputSignature
        )
    }
}
