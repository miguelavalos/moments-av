import XCTest
@testable import MomentsAV

final class RenderResultPersistenceRequestTests: XCTestCase {
    func testPreviewRequestUsesPreviewRenderAndFreeWatermarkedArtifact() {
        let response = MomentsPreviewResponse(
            appId: "momentsav",
            momentId: "moment-1",
            renderJobId: "provider-render-1",
            workflowRunId: "workflow-1",
            provider: "mock-provider",
            model: "mock-model",
            artifactId: "artifact-1",
            artifactKind: "preview",
            status: "available",
            progressPercent: 100,
            progressState: "complete",
            r2Key: "momentsav/user/moment/previews/preview.mp4",
            expiresAt: "2026-05-16T17:00:00Z",
            hasWatermark: true,
            generatedAt: "2026-05-16T16:00:00Z"
        )

        let request = RenderResultPersistenceRequest.preview(
            response,
            template: .partyRecap
        )

        XCTAssertEqual(request.renderKind, "preview")
        XCTAssertEqual(request.artifactKind, "preview")
        XCTAssertEqual(request.workflowRunId, "workflow-1")
        XCTAssertNil(request.creditReservationId)
        XCTAssertEqual(request.provider, "mock-provider")
        XCTAssertEqual(request.model, "mock-model")
        XCTAssertEqual(request.providerRequestId, "provider-render-1")
        XCTAssertEqual(request.r2Key, "momentsav/user/moment/previews/preview.mp4")
        XCTAssertEqual(request.durationSeconds, 30)
        XCTAssertEqual(request.creditCost, 0)
        XCTAssertTrue(request.hasWatermark)
        XCTAssertEqual(request.status, "available")
    }

}
