import XCTest
@testable import MomentsAV

final class MomentsCreateWorkflowPresentationTests: XCTestCase {
    func testWorkflowPresentationHidesWorkflowCardsWithoutProject() {
        let presentation = MomentsCreateWorkflowPresentation(
            createdProjectId: nil,
            template: .birthdayMessage,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            previewSummary: MomentsCreatePreviewSummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary()
        )

        XCTAssertFalse(presentation.showsWorkflowCards)
    }

    func testWorkflowPresentationCarriesWorkflowStateForActiveProject() {
        let preview = makeArtifact(id: "preview-1", kind: "preview")
        let finalExport = makeArtifact(id: "final-1", kind: "final_export")
        let latestPreviewJob = makeRenderJob(id: "preview-job", kind: "preview", status: "running")
        let latestFinalJob = makeRenderJob(id: "final-job", kind: "final_render", status: "queued")
        let mediaSummary = MomentsCreateMediaSummary(
            selectedMedia: [],
            syncedMediaAssets: [makeMediaAsset(id: "media-1")],
            isImporting: true,
            statusMessage: "Importing media."
        )
        let storySummary = MomentsCreateStorySummary(
            savedScenes: [makeScene(id: "scene-1")],
            generatedScenes: [],
            isDrafting: true,
            statusMessage: "Drafting story."
        )
        let previewSummary = MomentsCreatePreviewSummary(
            activeProject: makeProject(id: "project-1"),
            latestPreview: preview,
            latestPreviewJob: latestPreviewJob,
            isGenerating: true,
            isRefreshingStatus: false,
            statusMessage: "Generating preview."
        )
        let finalRenderSummary = MomentsCreateFinalRenderSummary(
            creditCost: 2,
            finalExport: finalExport,
            latestFinalJob: latestFinalJob,
            isGenerating: false,
            isRefreshingStatus: true,
            statusMessage: "Refreshing final render."
        )

        let presentation = MomentsCreateWorkflowPresentation(
            createdProjectId: "project-1",
            template: .birthdayMessage,
            mediaSummary: mediaSummary,
            storySummary: storySummary,
            previewSummary: previewSummary,
            finalRenderSummary: finalRenderSummary,
            canAddMedia: true,
            canDraftStory: true,
            canGeneratePreview: true,
            canRefreshPreviewStatus: true,
            canGenerateFinalRender: true,
            canRefreshFinalRenderStatus: true,
            mediaAvailabilityMessage: "Add media.",
            storyAvailabilityMessage: "Draft story.",
            previewAvailabilityMessage: "Generate preview.",
            previewRefreshAvailabilityMessage: "Refresh preview.",
            finalRenderAvailabilityMessage: "Generate final.",
            finalRenderRefreshAvailabilityMessage: "Refresh final."
        )

        XCTAssertTrue(presentation.showsWorkflowCards)
        XCTAssertEqual(presentation.createdProjectId, "project-1")
        XCTAssertEqual(presentation.template, .birthdayMessage)
        XCTAssertEqual(presentation.mediaSummary, mediaSummary)
        XCTAssertEqual(presentation.storySummary, storySummary)
        XCTAssertEqual(presentation.previewSummary, previewSummary)
        XCTAssertEqual(presentation.finalRenderSummary, finalRenderSummary)
        XCTAssertTrue(presentation.canAddMedia)
        XCTAssertTrue(presentation.canDraftStory)
        XCTAssertTrue(presentation.canGeneratePreview)
        XCTAssertTrue(presentation.canRefreshPreviewStatus)
        XCTAssertTrue(presentation.canGenerateFinalRender)
        XCTAssertTrue(presentation.canRefreshFinalRenderStatus)
        XCTAssertEqual(presentation.mediaAvailabilityMessage, "Add media.")
        XCTAssertEqual(presentation.storyAvailabilityMessage, "Draft story.")
        XCTAssertEqual(presentation.previewAvailabilityMessage, "Generate preview.")
        XCTAssertEqual(presentation.previewRefreshAvailabilityMessage, "Refresh preview.")
        XCTAssertEqual(presentation.finalRenderAvailabilityMessage, "Generate final.")
        XCTAssertEqual(presentation.finalRenderRefreshAvailabilityMessage, "Refresh final.")
    }

    private func makeProject(id: String) -> MomentDraftProject {
        MomentDraftProject(
            id: id,
            template: .birthdayMessage,
            status: "draft_created",
            title: "Family Weekend",
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: 10
        )
    }

    private func makeMediaAsset(id: String) -> MomentMediaAsset {
        MomentMediaAsset(
            id: id,
            platformMediaAssetId: "platform-\(id)",
            uploadId: "upload-\(id)",
            kind: "image",
            sortOrder: 0,
            selected: true,
            moderationStatus: "approved",
            uploadedAt: nil,
            sourceExpiresAt: nil
        )
    }

    private func makeScene(id: String) -> MomentStoryScene {
        MomentStoryScene(
            id: id,
            sceneIndex: 0,
            mediaAssetIds: [],
            caption: "Opening",
            narrationText: nil,
            tone: nil,
            musicCue: nil,
            durationMs: 3_000,
            createdBy: "avi"
        )
    }

    private func makeArtifact(id: String, kind: String) -> MomentArtifact {
        MomentArtifact(
            id: id,
            kind: kind,
            r2Key: "momentsav/\(id).mp4",
            status: "available",
            hasWatermark: kind == "preview",
            expiresAt: 1_781_592_000_000
        )
    }

    private func makeRenderJob(id: String, kind: String, status: String) -> MomentRenderJob {
        MomentRenderJob(
            id: id,
            kind: kind,
            status: status,
            workflowRunId: "workflow-\(id)",
            provider: "mock-provider",
            model: "mock-model",
            providerRequestId: "request-\(id)",
            errorCode: nil,
            errorMessage: nil,
            createdAt: 9,
            updatedAt: 10
        )
    }
}
