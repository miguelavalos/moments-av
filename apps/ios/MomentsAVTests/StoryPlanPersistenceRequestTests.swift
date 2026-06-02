import XCTest
@testable import MomentsAV

final class StoryPlanPersistenceRequestTests: XCTestCase {
    func testSceneRequestUsesPlanSceneFieldsAndAviAuthor() {
        let scene = MomentsStoryPlanScene(
            sceneIndex: 1,
            mediaAssetIds: ["media-1", "media-2"],
            caption: "A birthday toast",
            narrationText: "Everyone gathers around the table.",
            mood: "warm",
            tone: "warm",
            musicCue: "soft piano",
            durationMs: 4_500,
            createdBy: "model",
            editable: true
        )

        let request = StoryScenePersistenceRequest.scene(scene)

        XCTAssertEqual(request.sceneIndex, 1.0)
        XCTAssertEqual(request.mediaAssetIds, ["media-1", "media-2"])
        XCTAssertEqual(request.caption, "A birthday toast")
        XCTAssertEqual(request.narrationText, "Everyone gathers around the table.")
        XCTAssertEqual(request.mood, "warm")
        XCTAssertEqual(request.musicCue, "soft piano")
        XCTAssertEqual(request.durationMs, 4_500.0)
        XCTAssertEqual(request.createdBy, "avi")
    }

    func testReadyRequestApprovesAllowedPlans() {
        let plan = makePlan(moderationStatus: "allowed")

        let request = StoryReadyPersistenceRequest.plan(plan, storyInputSignature: "signature-1")

        XCTAssertEqual(request.workflowRunId, "workflow-1")
        XCTAssertEqual(request.moderationStatus, "approved")
        XCTAssertEqual(request.storyInputSignature, "signature-1")
    }

    func testReadyRequestBlocksNonAllowedPlans() {
        let plan = makePlan(moderationStatus: "rejected")

        let request = StoryReadyPersistenceRequest.plan(plan, storyInputSignature: "signature-1")

        XCTAssertEqual(request.moderationStatus, "blocked")
    }

    private func makePlan(moderationStatus: String) -> MomentsStoryPlanResponse {
        let json = """
        {
          "appId": "momentsav",
          "momentId": "moment-1",
          "workflowRunId": "workflow-1",
          "status": "ready",
          "provider": "mock-provider",
          "model": "mock-model",
          "moderationStatus": "\(moderationStatus)",
          "errorCode": null,
          "errorMessage": null,
          "narrationVoice": "avi_clear",
          "helperCopy": "Ready for preview.",
          "scenes": [],
          "generatedAt": "2026-05-16T16:00:00Z"
        }
        """

        return try! JSONDecoder().decode(
            MomentsStoryPlanResponse.self,
            from: Data(json.utf8)
        )
    }
}
