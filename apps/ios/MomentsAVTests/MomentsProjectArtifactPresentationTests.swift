import XCTest
@testable import MomentsAV

final class MomentsProjectArtifactPresentationTests: XCTestCase {
    func testPreviewAndFinalExportPickLatestMatchingArtifact() {
        let artifacts = [
            makeArtifact(id: "preview-1", kind: "preview", status: "expired"),
            makeArtifact(id: "final-1", kind: "final_export", status: "available"),
            makeArtifact(id: "preview-2", kind: "preview", status: "available")
        ]

        XCTAssertEqual(MomentsProjectArtifactPresentation.preview(in: artifacts)?.status, "available")
        XCTAssertEqual(MomentsProjectArtifactPresentation.preview(in: artifacts)?.storageKey, "momentsav/preview-2.mp4")
        XCTAssertEqual(MomentsProjectArtifactPresentation.finalExport(in: artifacts)?.storageKey, "momentsav/final-1.mp4")
    }

    func testArtifactPresentationFormatsKindWatermarkAndExpiry() {
        let presentation = MomentsProjectArtifactPresentation(
            artifact: makeArtifact(
                id: "preview-1",
                kind: "preview",
                status: "available",
                hasWatermark: true,
                expiresAt: 1_781_592_000_000
            )
        )

        XCTAssertEqual(presentation.kindTitle, "Preview")
        XCTAssertEqual(presentation.watermarkTitle, "Included")
        XCTAssertEqual(presentation.expiresAtTitle, MomentsDateFormatting.formattedDate(milliseconds: 1_781_592_000_000))
    }

    func testRenderJobPresentationSortsNewestFirstAndUsesFallbacks() {
        let presentations = MomentsProjectRenderJobPresentation.sorted([
            makeRenderJob(id: "old", kind: "preview", status: "queued", updatedAt: 10),
            makeRenderJob(id: "new", kind: "final", status: "failed", updatedAt: 20, provider: nil, model: nil)
        ])

        XCTAssertEqual(presentations.map(\.id), ["new", "old"])
        XCTAssertEqual(presentations[0].kindTitle, "Final")
        XCTAssertEqual(presentations[0].providerTitle, "Unknown")
        XCTAssertEqual(presentations[0].modelTitle, "Unknown")
    }

    private func makeArtifact(
        id: String,
        kind: String,
        status: String,
        hasWatermark: Bool = false,
        expiresAt: Double = 1_781_592_000_000
    ) -> MomentArtifact {
        MomentArtifact(
            id: id,
            kind: kind,
            r2Key: "momentsav/\(id).mp4",
            status: status,
            hasWatermark: hasWatermark,
            expiresAt: expiresAt
        )
    }

    private func makeRenderJob(
        id: String,
        kind: String,
        status: String,
        updatedAt: Double,
        provider: String? = "mock-provider",
        model: String? = "mock-model"
    ) -> MomentRenderJob {
        MomentRenderJob(
            id: id,
            kind: kind,
            status: status,
            workflowRunId: "workflow-\(id)",
            provider: provider,
            model: model,
            providerRequestId: "request-\(id)",
            errorCode: status == "failed" ? "provider_failed" : nil,
            errorMessage: status == "failed" ? "Render failed." : nil,
            createdAt: updatedAt - 1,
            updatedAt: updatedAt
        )
    }
}
