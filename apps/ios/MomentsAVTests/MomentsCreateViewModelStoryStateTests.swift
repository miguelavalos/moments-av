import XCTest
@testable import MomentsAV

@MainActor
final class MomentsCreateViewModelStoryStateTests: XCTestCase {
    func testStoryScenesClearStaleErrorAndMarkCurrentInputPrepared() {
        let viewModel = MomentsCreateViewModel()
        let media = MomentsCreateTestFixtures.makeSelectedMedia(
            id: "00000000-0000-0000-0000-000000000001"
        )

        viewModel.applyProjectCreationState(
            MomentsCreateProjectCreationState(
                isCreatingDraft: false,
                activeProjectId: "project-1",
                draftErrorMessage: nil
            )
        )
        viewModel.applyMediaUploadState(
            MomentsCreateMediaUploadState(
                selectedMedia: [media],
                statusMessage: nil,
                isImporting: false,
                importProgress: nil
            )
        )
        viewModel.applyStoryDraftState(
            MomentsCreateStoryDraftState(
                savedScenes: [],
                generatedScenes: [],
                statusMessage: "Couldn't prepare the story. Please try again.",
                isDrafting: false
            )
        )

        XCTAssertEqual(viewModel.storySummary.statusMessage, "Couldn't prepare the story. Please try again.")
        XCTAssertFalse(viewModel.isStoryPreparedForCurrentInput)

        viewModel.applyStoryDraftState(
            MomentsCreateStoryDraftState(
                savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
                generatedScenes: [],
                statusMessage: "Couldn't prepare the story. Please try again.",
                isDrafting: false
            )
        )

        XCTAssertNil(viewModel.storySummary.statusMessage)
        XCTAssertTrue(viewModel.isStoryPreparedForCurrentInput)
    }

    func testCurrentStorySignaturePrefersLocalMediaWhenWorkspaceHasUploadedMedia() {
        let viewModel = MomentsCreateViewModel()
        let localMedia = MomentsCreateTestFixtures.makeSelectedMedia(
            id: "00000000-0000-0000-0000-000000000001",
            sourceLocalIdentifier: "local-asset-1"
        )

        viewModel.applyProjectCreationState(
            MomentsCreateProjectCreationState(
                isCreatingDraft: false,
                activeProjectId: "project-1",
                draftErrorMessage: nil
            )
        )
        viewModel.applyMediaUploadState(
            MomentsCreateMediaUploadState(
                selectedMedia: [localMedia],
                statusMessage: nil,
                isImporting: false,
                importProgress: nil
            )
        )

        let localSignature = viewModel.currentStoryInputSignature(projectId: "project-1")

        viewModel.applyPreviewGenerationState(
            MomentsCreatePreviewGenerationState(
                activeWorkspace: MomentProjectWorkspace(
                project: MomentsCreateTestFixtures.makeProject(id: "project-1"),
                mediaAssets: [
                    MomentsCreateTestFixtures.makeMediaAsset(
                        id: "backend-media-1",
                        sortOrder: 0
                    )
                ],
                storyScenes: [],
                renderJobs: [],
                artifacts: []
                ),
                latestPreview: nil,
                latestPreviewJob: nil,
                statusMessage: nil,
                isGenerating: false,
                isRefreshingStatus: false
            )
        )

        XCTAssertEqual(viewModel.currentStoryInputSignature(projectId: "project-1"), localSignature)
    }
}
