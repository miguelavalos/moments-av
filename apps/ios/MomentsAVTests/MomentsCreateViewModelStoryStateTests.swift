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
                statusMessage: MomentsRecoveryCopy.storyFailure(),
                isDrafting: false
            )
        )

        XCTAssertEqual(viewModel.storySummary.statusMessage, MomentsRecoveryCopy.storyFailure())
        XCTAssertFalse(viewModel.isStoryPreparedForCurrentInput)

        viewModel.applyStoryDraftState(
            MomentsCreateStoryDraftState(
                savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
                generatedScenes: [],
                statusMessage: MomentsRecoveryCopy.storyFailure(),
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

        let expectedLocalSignature = viewModel.currentStoryInputSignature(
            projectId: "project-1",
            persistedMedia: [
                MomentsStoryDraftMedia(
                    mediaAssetId: localMedia.id.uuidString,
                    mediaKind: localMedia.kind,
                    sortOrder: localMedia.sortOrder,
                    selected: localMedia.selected,
                    moderationStatus: "pending"
                )
            ]
        )
        let backendMediaSignature = viewModel.currentStoryInputSignature(
            projectId: "project-1",
            persistedMedia: [
                MomentsStoryDraftMedia(
                    mediaAssetId: "backend-media-1",
                    mediaKind: "image",
                    sortOrder: 0,
                    selected: true,
                    moderationStatus: "approved"
                )
            ]
        )

        XCTAssertEqual(viewModel.currentStoryInputSignature(projectId: "project-1"), expectedLocalSignature)
        XCTAssertNotEqual(viewModel.currentStoryInputSignature(projectId: "project-1"), backendMediaSignature)
    }
}
