import XCTest
@testable import MomentsAV

final class MomentsProjectArtifactPresentationTests: XCTestCase {
    func testRenderJobsSectionPresentationFormatsTitleEmptyStateAndJobs() {
        let presentation = MomentsProjectRenderJobsSectionPresentation(renderJobs: [
            makeRenderJob(id: "old", kind: "preview", status: "queued", updatedAt: 10),
            makeRenderJob(id: "new", kind: "final", status: "failed", updatedAt: 20)
        ])

        XCTAssertEqual(presentation.title, "Render jobs")
        XCTAssertEqual(presentation.emptySystemImage, "gearshape.2")
        XCTAssertEqual(presentation.emptyMessage, "Preview and final render jobs will appear here.")
        XCTAssertEqual(presentation.jobs.map(\.id), ["new", "old"])
    }

    func testArtifactSectionPresentationsFormatTitlesEmptyStatesAndSelectedArtifacts() {
        let artifacts = [
            makeArtifact(id: "preview-1", kind: "preview", status: "expired"),
            makeArtifact(id: "final-1", kind: "final_export", status: "available"),
            makeArtifact(id: "preview-2", kind: "preview", status: "available")
        ]

        let preview = MomentsProjectArtifactSectionPresentation.preview(artifacts: artifacts)
        let finalExport = MomentsProjectArtifactSectionPresentation.finalExport(artifacts: artifacts)

        XCTAssertEqual(preview.title, "Preview")
        XCTAssertEqual(preview.emptySystemImage, "play.rectangle")
        XCTAssertEqual(preview.emptyMessage, "Generate a preview after the story draft is ready.")
        XCTAssertEqual(preview.artifact?.storageKey, "momentsav/preview-2.mp4")

        XCTAssertEqual(finalExport.title, "Final export")
        XCTAssertEqual(finalExport.emptySystemImage, "square.and.arrow.up")
        XCTAssertEqual(finalExport.emptyMessage, "Render the final export after approving a preview.")
        XCTAssertEqual(finalExport.artifact?.storageKey, "momentsav/final-1.mp4")
    }

    func testArtifactSectionPresentationsUseEmptyArtifactWhenMissing() {
        XCTAssertNil(MomentsProjectArtifactSectionPresentation.preview(artifacts: []).artifact)
        XCTAssertNil(MomentsProjectArtifactSectionPresentation.finalExport(artifacts: []).artifact)
    }

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
        XCTAssertEqual(presentation.actionDetail, "Preview is ready to review.")
    }

    func testFinalArtifactPresentationProvidesExportAndRecoveryCopy() {
        let availableFinal = MomentsProjectArtifactPresentation(
            artifact: makeArtifact(id: "final-1", kind: "final_export", status: "available")
        )
        let expiredFinal = MomentsProjectArtifactPresentation(
            artifact: makeArtifact(id: "final-2", kind: "final_export", status: "expired")
        )
        let failedFinal = MomentsProjectArtifactPresentation(
            artifact: makeArtifact(id: "final-3", kind: "final_export", status: "failed")
        )
        let queuedFinal = MomentsProjectArtifactPresentation(
            artifact: makeArtifact(id: "final-4", kind: "final_export", status: "queued")
        )

        XCTAssertEqual(availableFinal.actionDetail, "Your final video is ready to export or share.")
        XCTAssertEqual(expiredFinal.actionDetail, "Final Export is no longer available. Return to Create and generate it again.")
        XCTAssertEqual(
            failedFinal.actionDetail,
            "Final Export is not available. Credits are only finalized after a usable final video is ready. Please retry in Create or contact support."
        )
        XCTAssertEqual(queuedFinal.actionDetail, "Final Export is still being prepared. Refresh the project in a moment.")
    }

    func testRenderJobPresentationSortsNewestFirstAndUsesFallbacks() {
        let presentations = MomentsProjectRenderJobPresentation.sorted([
            makeRenderJob(id: "old", kind: "preview", status: "queued", updatedAt: 10),
            makeRenderJob(
                id: "new",
                kind: "final",
                status: "failed",
                updatedAt: 20,
                provider: nil,
                model: nil,
                errorMessage: "provider stack trace"
            )
        ])

        XCTAssertEqual(presentations.map(\.id), ["new", "old"])
        XCTAssertEqual(presentations[0].kindTitle, "Final")
        XCTAssertEqual(presentations[0].providerTitle, "Not recorded")
        XCTAssertEqual(presentations[0].modelTitle, "Not recorded")
        XCTAssertEqual(presentations[1].providerTitle, "Recorded")
        XCTAssertEqual(presentations[1].modelTitle, "Configured")
        XCTAssertEqual(
            presentations[0].errorMessage,
            "Video creation hit a problem. Any reserved credits will be released if the video was not completed. Please try again or contact support."
        )
    }

    func testRenderJobPresentationPreservesSafeFailedUserMessage() {
        let presentation = MomentsProjectRenderJobPresentation(
            renderJob: makeRenderJob(
                id: "final",
                kind: "final",
                status: "failed",
                updatedAt: 20,
                userMessage: "We couldn’t finish this video. No credits were charged.",
                errorMessage: "provider stack trace"
            )
        )

        XCTAssertEqual(presentation.errorMessage, "We couldn’t finish this video. No credits were charged.")
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
        model: String? = "mock-model",
        userMessage: String? = nil,
        errorMessage: String? = nil
    ) -> MomentRenderJob {
        MomentRenderJob(
            id: id,
            kind: kind,
            status: status,
            userMessage: userMessage,
            workflowRunId: "workflow-\(id)",
            provider: provider,
            model: model,
            providerRequestId: "request-\(id)",
            errorCode: status == "failed" ? "provider_failed" : nil,
            errorMessage: status == "failed" ? (errorMessage ?? "Render failed.") : errorMessage,
            createdAt: updatedAt - 1,
            updatedAt: updatedAt
        )
    }
}
