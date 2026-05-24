import XCTest
@testable import MomentsAV

final class MomentsProjectStatusRulesTests: XCTestCase {
    func testGroupsCompletedProjectsAsFinished() {
        let draft = makeProject(id: "draft", status: "draft_created", updatedAt: 10)
        let preview = makeProject(id: "preview", status: "preview_ready", updatedAt: 20)
        let completed = makeProject(id: "completed", status: "completed", updatedAt: 30)

        let groups = MomentsProjectStatusRules.group([draft, preview, completed])

        XCTAssertEqual(groups.inProgress.map(\.id), ["preview", "draft"])
        XCTAssertEqual(groups.finished.map(\.id), ["completed"])
    }

    func testGroupsSortProjectsByLatestUpdateWithinEachSection() {
        let olderDraft = makeProject(id: "older-draft", status: "draft_created", updatedAt: 10)
        let newerDraft = makeProject(id: "newer-draft", status: "story_ready", updatedAt: 30)
        let olderFinished = makeProject(id: "older-finished", status: "completed", updatedAt: 20)
        let newerFinished = makeProject(id: "newer-finished", status: "completed", updatedAt: 40)

        let groups = MomentsProjectStatusRules.group([
            olderDraft,
            olderFinished,
            newerDraft,
            newerFinished
        ])

        XCTAssertEqual(groups.inProgress.map(\.id), ["newer-draft", "older-draft"])
        XCTAssertEqual(groups.finished.map(\.id), ["newer-finished", "older-finished"])
    }

    func testListSummaryCountsAndLatestProjectUseProjectRules() {
        let oldest = makeProject(id: "oldest", status: "completed", updatedAt: 10)
        let newest = makeProject(id: "newest", status: "story_ready", updatedAt: 30)
        let middle = makeProject(id: "middle", status: "completed", updatedAt: 20)

        let summary = MomentsProjectListSummary.make(from: [oldest, newest, middle])

        XCTAssertEqual(summary.projectCount, 3)
        XCTAssertEqual(summary.inProgressCount, 1)
        XCTAssertEqual(summary.finishedCount, 2)
        XCTAssertEqual(summary.latestProject?.id, "newest")
        XCTAssertTrue(summary.hasProjects)
    }

    func testListSummaryExposesLatestInProgressContinuationRequest() {
        let olderDraft = makeProject(id: "older-draft", status: "draft_created", updatedAt: 10)
        let newestFinished = makeProject(id: "newest-finished", status: "completed", updatedAt: 30)
        let latestDraft = makeProject(id: "latest-draft", status: "story_ready", updatedAt: 20)

        let summary = MomentsProjectListSummary.make(from: [olderDraft, newestFinished, latestDraft])

        XCTAssertEqual(summary.latestProject?.id, "newest-finished")
        XCTAssertEqual(summary.latestInProgressProject?.id, "latest-draft")
        XCTAssertEqual(summary.latestInProgressContinuationRequest?.project.id, "latest-draft")
        XCTAssertEqual(summary.latestInProgressContinuationRequest?.focus, .review)
    }

    func testEmptyListSummaryHasNoProjects() {
        let summary = MomentsProjectListSummary.make(from: [])

        XCTAssertEqual(summary.projectCount, 0)
        XCTAssertEqual(summary.inProgressCount, 0)
        XCTAssertEqual(summary.finishedCount, 0)
        XCTAssertNil(summary.latestProject)
        XCTAssertNil(summary.latestInProgressProject)
        XCTAssertNil(summary.latestInProgressContinuationRequest)
        XCTAssertFalse(summary.hasProjects)
    }

    func testDisplayHelpersFormatBackendValuesForUI() {
        XCTAssertEqual(MomentsProjectStatusRules.displayTitle(for: "preview_ready"), "Preview Ready")
        XCTAssertEqual(MomentsProjectStatusRules.displayKind("final_render"), "Final Render")
    }

    func testNextActionAsksForMediaWhenWorkspaceHasNoMedia() {
        let action = MomentsProjectStatusRules.nextAction(for: makeWorkspace())

        XCTAssertEqual(action.title, "Add media")
        XCTAssertEqual(action.systemImage, "photo.badge.plus")
        XCTAssertEqual(action.primaryButtonTitle, "Add Media in Create")
        XCTAssertEqual(action.continuationFocus, .media)
    }

    func testNextActionAsksForStoryWhenMediaExistsWithoutScenes() {
        let action = MomentsProjectStatusRules.nextAction(for: makeWorkspace(mediaAssets: [makeMediaAsset()]))

        XCTAssertEqual(action.title, "Generate story")
        XCTAssertEqual(action.systemImage, "text.bubble")
        XCTAssertEqual(action.primaryButtonTitle, "Generate Story in Create")
        XCTAssertEqual(action.continuationFocus, .story)
    }

    func testNextActionAsksForPreviewWhenStoryExistsWithoutPreviewArtifact() {
        let action = MomentsProjectStatusRules.nextAction(
            for: makeWorkspace(
                mediaAssets: [makeMediaAsset()],
                storyScenes: [makeStoryScene()]
            )
        )

        XCTAssertEqual(action.title, "Generate preview")
        XCTAssertEqual(action.systemImage, "play.rectangle")
        XCTAssertEqual(action.primaryButtonTitle, "Generate Preview in Create")
        XCTAssertEqual(action.continuationFocus, .preview)
    }

    func testNextActionAsksForFinalWhenPreviewIsAvailable() {
        let action = MomentsProjectStatusRules.nextAction(
            for: makeWorkspace(
                mediaAssets: [makeMediaAsset()],
                storyScenes: [makeStoryScene()],
                artifacts: [makeArtifact(kind: "preview")]
            )
        )

        XCTAssertEqual(action.title, "Render final export")
        XCTAssertEqual(action.systemImage, "square.and.arrow.up")
        XCTAssertEqual(action.primaryButtonTitle, "Render Final in Create")
        XCTAssertEqual(action.continuationFocus, .finalRender)
    }

    func testNextActionMarksFinishedWhenFinalExportIsAvailable() {
        let action = MomentsProjectStatusRules.nextAction(
            for: makeWorkspace(
                mediaAssets: [makeMediaAsset()],
                storyScenes: [makeStoryScene()],
                artifacts: [
                    makeArtifact(kind: "preview"),
                    makeArtifact(kind: "final_export")
                ]
            )
        )

        XCTAssertEqual(action.title, "Finished")
        XCTAssertEqual(action.systemImage, "checkmark.circle")
        XCTAssertEqual(action.primaryButtonTitle, "Open in Create")
        XCTAssertEqual(action.continuationFocus, .finalRender)
    }

    func testNextActionPrioritizesFailedRenderJobs() {
        let action = MomentsProjectStatusRules.nextAction(
            for: makeWorkspace(
                mediaAssets: [makeMediaAsset()],
                storyScenes: [makeStoryScene()],
                renderJobs: [makeRenderJob(kind: "preview", status: "failed")]
            )
        )

        XCTAssertEqual(action.title, "Review render issue")
        XCTAssertEqual(action.systemImage, "exclamationmark.triangle")
        XCTAssertEqual(action.primaryButtonTitle, "Review in Create")
        XCTAssertEqual(action.continuationFocus, .preview)
    }

    private func makeProject(
        id: String,
        status: String,
        updatedAt: Double
    ) -> MomentDraftProject {
        MomentDraftProject(
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

    private func makeWorkspace(
        mediaAssets: [MomentMediaAsset] = [],
        storyScenes: [MomentStoryScene] = [],
        renderJobs: [MomentRenderJob] = [],
        artifacts: [MomentArtifact] = []
    ) -> MomentProjectWorkspace {
        MomentProjectWorkspace(
            project: makeProject(id: "project-1", status: "draft_created", updatedAt: 10),
            mediaAssets: mediaAssets,
            storyScenes: storyScenes,
            renderJobs: renderJobs,
            artifacts: artifacts
        )
    }

    private func makeMediaAsset() -> MomentMediaAsset {
        MomentMediaAsset(
            id: "media-1",
            platformMediaAssetId: "platform-media-1",
            uploadId: "upload-1",
            kind: "photo",
            sortOrder: 0,
            selected: true,
            moderationStatus: "pending",
            uploadedAt: 1_779_000_000_000,
            sourceExpiresAt: 1_781_592_000_000
        )
    }

    private func makeStoryScene() -> MomentStoryScene {
        MomentStoryScene(
            id: "scene-1",
            sceneIndex: 0,
            mediaAssetIds: ["media-1"],
            caption: "Opening",
            narrationText: "The first scene.",
            tone: "warm",
            musicCue: "soft piano",
            durationMs: 4_000,
            createdBy: "avi"
        )
    }

    private func makeArtifact(kind: String) -> MomentArtifact {
        MomentArtifact(
            id: "\(kind)-1",
            kind: kind,
            r2Key: "momentsav/user/project/\(kind).mp4",
            status: "available",
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
