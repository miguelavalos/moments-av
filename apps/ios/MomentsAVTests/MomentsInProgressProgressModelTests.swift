import XCTest
@testable import MomentsAV

final class MomentsInProgressProgressModelTests: XCTestCase {
    func testEmptyWorkspaceMarksMomentCreatedAndRemainingStepsWaiting() {
        let model = MomentsInProgressProgressModel(workspace: makeWorkspace())

        XCTAssertEqual(model.phases.map(\.title), ["Moment", "Media", "Story", "Avi's Cut", "Create Video"])
        XCTAssertEqual(model.phases.map(\.state), [.complete, .waiting, .waiting, .waiting, .waiting])
        XCTAssertEqual(model.phases.map(\.detail), [
            "In Progress",
            "No media yet",
            "Not ready",
            "Not reviewed",
            "Not created"
        ])
    }

    func testRenderJobStatusDrivesPreviewProgressUntilArtifactIsAvailable() {
        let model = MomentsInProgressProgressModel(
            workspace: makeWorkspace(renderJobs: [makeRenderJob(kind: "preview", status: "running")])
        )

        let preview = model.phases.first { $0.title == "Avi's Cut" }
        XCTAssertEqual(preview?.state, .active)
        XCTAssertEqual(preview?.detail, "Running")
    }

    func testAvailableFinalExportArtifactCompletesFinalProgress() {
        let model = MomentsInProgressProgressModel(
            workspace: makeWorkspace(
                renderJobs: [makeRenderJob(kind: "final", status: "failed")],
                artifacts: [makeArtifact(kind: "final_export", status: "available")]
            )
        )

        let final = model.phases.first { $0.title == "Create Video" }
        XCTAssertEqual(final?.state, .complete)
        XCTAssertEqual(final?.detail, "Available")
    }

    private func makeWorkspace(
        mediaAssets: [MomentMediaAsset] = [],
        storyScenes: [MomentStoryScene] = [],
        renderJobs: [MomentRenderJob] = [],
        artifacts: [MomentArtifact] = []
    ) -> MomentWorkspace {
        MomentWorkspace(
            moment: makeMoment(id: "moment-1", status: "in_progress", updatedAt: 10),
            mediaAssets: mediaAssets,
            storyScenes: storyScenes,
            renderJobs: renderJobs,
            artifacts: artifacts
        )
    }

    private func makeMoment(id: String, status: String, updatedAt: Double) -> InProgressMoment {
        InProgressMoment(
            id: id,
            template: .birthdayMessage,
            status: status,
            title: id,
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: updatedAt
        )
    }

    private func makeArtifact(kind: String, status: String) -> MomentArtifact {
        MomentArtifact(
            id: "\(kind)-1",
            kind: kind,
            r2Key: "momentsav/user/moment/\(kind).mp4",
            status: status,
            hasWatermark: kind == "preview",
            expiresAt: 1_781_592_000_000
        )
    }

    private func makeRenderJob(kind: String, status: String) -> MomentRenderJob {
        MomentRenderJob(
            id: "\(kind)-job-1",
            kind: kind,
            status: status,
            workflowRunId: "workflow-1",
            provider: "mock-provider",
            model: "mock-model",
            providerRequestId: "provider-request-1",
            errorCode: status == "failed" ? "provider_failed" : nil,
            errorMessage: status == "failed" ? "Render failed." : nil,
            createdAt: 1_779_000_000_000,
            updatedAt: 1_779_000_001_000
        )
    }
}
