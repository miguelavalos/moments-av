import XCTest
@testable import MomentsAV

final class StoryDraftPersistenceRequestTests: XCTestCase {
    func testSceneRequestUsesDraftSceneFieldsAndAviAuthor() {
        let scene = MomentsStoryDraftScene(
            sceneIndex: 1,
            mediaAssetIds: ["media-1", "media-2"],
            caption: "A birthday toast",
            narrationText: "Everyone gathers around the table.",
            tone: "warm",
            musicCue: "soft piano",
            durationMs: 4_500,
            createdBy: "model",
            editable: true
        )

        let request = StoryScenePersistenceRequest.scene(scene)

        XCTAssertEqual(request.sceneIndex, 1)
        XCTAssertEqual(request.mediaAssetIds, ["media-1", "media-2"])
        XCTAssertEqual(request.caption, "A birthday toast")
        XCTAssertEqual(request.narrationText, "Everyone gathers around the table.")
        XCTAssertEqual(request.tone, "warm")
        XCTAssertEqual(request.musicCue, "soft piano")
        XCTAssertEqual(request.durationMs, 4_500)
        XCTAssertEqual(request.createdBy, "avi")
    }

    func testReadyRequestApprovesAllowedDrafts() {
        let draft = makeDraft(moderationStatus: "allowed")

        let request = StoryReadyPersistenceRequest.draft(draft)

        XCTAssertEqual(request.workflowRunId, "workflow-1")
        XCTAssertEqual(request.moderationStatus, "approved")
    }

    func testReadyRequestBlocksNonAllowedDrafts() {
        let draft = makeDraft(moderationStatus: "rejected")

        let request = StoryReadyPersistenceRequest.draft(draft)

        XCTAssertEqual(request.moderationStatus, "blocked")
    }

    private func makeDraft(moderationStatus: String) -> MomentsStoryDraftResponse {
        let json = """
        {
          "appId": "momentsav",
          "projectId": "project-1",
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
            MomentsStoryDraftResponse.self,
            from: Data(json.utf8)
        )
    }
}
