import XCTest
@testable import MomentsAV

final class MomentsProjectWorkspacePresentationTests: XCTestCase {
    func testWorkspaceHeaderPresentationFormatsTitleUpdateAndCounts() {
        let presentation = MomentsProjectWorkspaceHeaderPresentation(
            workspace: makeWorkspace(
                project: makeProject(title: "Family Weekend", updatedAt: 1_781_592_000_000),
                mediaAssets: [
                    makeMediaAsset(id: "media-1", kind: "image", sortOrder: 0, selected: true, moderationStatus: "approved")
                ],
                storyScenes: [
                    makeScene(id: "scene-1", sceneIndex: 0, caption: "Opening")
                ],
                renderJobs: [
                    makeRenderJob(id: "job-1", kind: "preview", status: "running", updatedAt: 20)
                ]
            )
        )

        XCTAssertEqual(presentation.title, "Family Weekend")
        XCTAssertEqual(presentation.updatedAtTitle, "Updated \(MomentsDateFormatting.formattedDate(milliseconds: 1_781_592_000_000))")
        XCTAssertEqual(presentation.countsTitle, "Media 1 · Scenes 1 · Jobs 1")
    }

    func testWorkspaceSummaryPresentationFormatsStatusArtifactsAndLatestJob() {
        let presentation = MomentsProjectWorkspaceSummaryPresentation(
            workspace: makeWorkspace(
                project: makeProject(status: "preview_ready"),
                renderJobs: [
                    makeRenderJob(id: "old", kind: "preview", status: "queued", updatedAt: 10),
                    makeRenderJob(id: "new", kind: "final_render", status: "failed", updatedAt: 20)
                ],
                artifacts: [
                    makeArtifact(id: "preview-1", kind: "preview", status: "expired"),
                    makeArtifact(id: "final-1", kind: "final_export", status: "available"),
                    makeArtifact(id: "preview-2", kind: "preview", status: "available")
                ]
            )
        )

        XCTAssertEqual(presentation.tiles.map(\.title), ["Status", "Preview", "Final", "Latest job"])
        XCTAssertEqual(presentation.tiles.map(\.value), ["Preview Ready", "Available", "Available", "Final Render · Failed"])
        XCTAssertEqual(presentation.tiles.map(\.systemImage), ["circle.dashed", "play.rectangle", "square.and.arrow.up", "gearshape.2"])
    }

    func testWorkspaceSummaryPresentationUsesFallbacksWhenNoArtifactsOrJobsExist() {
        let presentation = MomentsProjectWorkspaceSummaryPresentation(
            workspace: makeWorkspace(project: makeProject(status: "draft_created"))
        )

        XCTAssertEqual(presentation.tiles.map(\.value), ["Draft Created", "Not ready", "Not ready", "Not started"])
    }

    func testMediaAssetPresentationSortsBySortOrderAndFormatsRows() {
        let presentations = MomentsProjectMediaAssetPresentation.sorted([
            makeMediaAsset(id: "second", kind: "video", sortOrder: 1, selected: false, moderationStatus: "pending"),
            makeMediaAsset(id: "first", kind: "image", sortOrder: 0, selected: true, moderationStatus: "approved")
        ])

        XCTAssertEqual(presentations.map(\.id), ["first", "second"])
        XCTAssertEqual(presentations[0].systemImage, "photo")
        XCTAssertEqual(presentations[0].title, "Image 1")
        XCTAssertEqual(presentations[0].detail, "Selected · Approved")
        XCTAssertEqual(presentations[1].systemImage, "video")
        XCTAssertEqual(presentations[1].title, "Video 2")
        XCTAssertEqual(presentations[1].detail, "Not selected · Pending")
    }

    private func makeWorkspace(
        project: MomentDraftProject,
        mediaAssets: [MomentMediaAsset] = [],
        storyScenes: [MomentStoryScene] = [],
        renderJobs: [MomentRenderJob] = [],
        artifacts: [MomentArtifact] = []
    ) -> MomentProjectWorkspace {
        MomentProjectWorkspace(
            project: project,
            mediaAssets: mediaAssets,
            storyScenes: storyScenes,
            renderJobs: renderJobs,
            artifacts: artifacts
        )
    }

    private func makeProject(
        status: String = "draft_created",
        title: String = "project-1",
        updatedAt: Double = 10
    ) -> MomentDraftProject {
        MomentDraftProject(
            id: "project-1",
            template: .birthdayMessage,
            status: status,
            title: title,
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

    func testStoryScenePresentationSortsBySceneIndexAndFormatsRows() {
        let presentations = MomentsProjectStoryScenePresentation.sorted([
            makeScene(id: "scene-2", sceneIndex: 1, caption: "Second beat"),
            makeScene(id: "scene-1", sceneIndex: 0, caption: "Opening beat")
        ])

        XCTAssertEqual(presentations.map(\.id), ["scene-1", "scene-2"])
        XCTAssertEqual(presentations[0].title, "Scene 1")
        XCTAssertEqual(presentations[0].caption, "Opening beat")
        XCTAssertEqual(presentations[1].title, "Scene 2")
    }

    private func makeMediaAsset(
        id: String,
        kind: String,
        sortOrder: Double,
        selected: Bool,
        moderationStatus: String
    ) -> MomentMediaAsset {
        MomentMediaAsset(
            id: id,
            platformMediaAssetId: "platform-\(id)",
            uploadId: "upload-\(id)",
            kind: kind,
            sortOrder: sortOrder,
            selected: selected,
            moderationStatus: moderationStatus,
            uploadedAt: nil,
            sourceExpiresAt: nil
        )
    }

    private func makeScene(id: String, sceneIndex: Double, caption: String) -> MomentStoryScene {
        MomentStoryScene(
            id: id,
            sceneIndex: sceneIndex,
            mediaAssetIds: [],
            caption: caption,
            narrationText: nil,
            tone: nil,
            musicCue: nil,
            durationMs: 3_000,
            createdBy: "avi"
        )
    }

    private func makeArtifact(id: String, kind: String, status: String) -> MomentArtifact {
        MomentArtifact(
            id: id,
            kind: kind,
            r2Key: "momentsav/\(id).mp4",
            status: status,
            hasWatermark: kind == "preview",
            expiresAt: 1_781_592_000_000
        )
    }

    private func makeRenderJob(id: String, kind: String, status: String, updatedAt: Double) -> MomentRenderJob {
        MomentRenderJob(
            id: id,
            kind: kind,
            status: status,
            workflowRunId: "workflow-\(id)",
            provider: "mock-provider",
            model: "mock-model",
            providerRequestId: "request-\(id)",
            errorCode: status == "failed" ? "provider_failed" : nil,
            errorMessage: status == "failed" ? "Render failed." : nil,
            createdAt: updatedAt - 1,
            updatedAt: updatedAt
        )
    }
}
