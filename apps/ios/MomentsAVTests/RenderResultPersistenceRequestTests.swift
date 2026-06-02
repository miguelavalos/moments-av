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

    func testFinalRenderRequestUsesReservationCommittedCreditsAndUnwatermarkedArtifact() {
        let response = MomentsFinalRenderResponse(
            appId: "momentsav",
            momentId: "moment-1",
            renderJobId: "provider-render-2",
            workflowRunId: "workflow-2",
            provider: "mock-provider",
            model: "mock-model",
            reservationId: "reservation-1",
            artifactId: "artifact-2",
            artifactKind: "final_export",
            status: "available",
            progressPercent: 100,
            r2Key: "momentsav/user/moment/final/final.mp4",
            expiresAt: "2026-05-16T17:00:00Z",
            hasWatermark: true,
            baseCreditCost: 2,
            watermarkRemovalCreditCost: nil,
            creditsCommitted: 2,
            generatedAt: "2026-05-16T16:00:00Z"
        )

        let request = RenderResultPersistenceRequest.finalRender(
            response,
            template: .partyRecap
        )

        XCTAssertEqual(request.renderKind, "final")
        XCTAssertEqual(request.artifactKind, "final_export")
        XCTAssertEqual(request.workflowRunId, "workflow-2")
        XCTAssertEqual(request.creditReservationId, "reservation-1")
        XCTAssertEqual(request.provider, "mock-provider")
        XCTAssertEqual(request.model, "mock-model")
        XCTAssertEqual(request.providerRequestId, "provider-render-2")
        XCTAssertEqual(request.r2Key, "momentsav/user/moment/final/final.mp4")
        XCTAssertEqual(request.durationSeconds, 30)
        XCTAssertEqual(request.creditCost, 2)
        XCTAssertTrue(request.hasWatermark)
        XCTAssertEqual(request.status, "available")
    }
}
