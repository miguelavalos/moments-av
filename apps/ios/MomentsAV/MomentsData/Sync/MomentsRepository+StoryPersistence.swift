import Foundation

extension MomentsRepository {
    func saveStoryPlan(
        ownerUserId: String,
        momentId: String,
        plan: MomentsStoryPlanResponse,
        storyInputSignature: String
    ) async throws {
        try await remoteClient.saveStoryPlan(
            ownerUserId: ownerUserId,
            momentId: momentId,
            plan: plan,
            storyInputSignature: storyInputSignature
        )
    }
}
