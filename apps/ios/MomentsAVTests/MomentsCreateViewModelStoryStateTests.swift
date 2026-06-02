import XCTest
@testable import MomentsAV

@MainActor
final class MomentsCreateViewModelStoryStateTests: XCTestCase {
    func testStoryScenesClearStaleErrorAndMarkCurrentInputPrepared() {
        let viewModel = MomentsCreateViewModel()
        let media = MomentsCreateTestFixtures.makeSelectedMedia(
            id: "00000000-0000-0000-0000-000000000001"
        )

        viewModel.applyMomentCreationState(
            MomentsCreateMomentCreationState(
                isCreatingMoment: false,
                activeMomentId: "moment-1",
                setupErrorMessage: nil
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
        viewModel.applyStoryPlanState(
            MomentsCreateStoryPlanState(
                savedScenes: [],
                generatedScenes: [],
                statusMessage: MomentsRecoveryCopy.storyFailure(),
                isPlanning: false
            )
        )

        XCTAssertEqual(viewModel.storySummary.statusMessage, MomentsRecoveryCopy.storyFailure())
        XCTAssertFalse(viewModel.isStoryPreparedForCurrentInput)

        viewModel.applyStoryPlanState(
            MomentsCreateStoryPlanState(
                savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
                generatedScenes: [],
                statusMessage: MomentsRecoveryCopy.storyFailure(),
                isPlanning: false
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

        viewModel.applyMomentCreationState(
            MomentsCreateMomentCreationState(
                isCreatingMoment: false,
                activeMomentId: "moment-1",
                setupErrorMessage: nil
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
                activeWorkspace: MomentWorkspace(
                moment: MomentsCreateTestFixtures.makeMoment(id: "moment-1"),
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

        let expectedLocalSignature = viewModel.currentStoryPlanInputSignature(
            momentId: "moment-1",
            persistedMedia: [
                MomentsStoryPlanMedia(
                    mediaAssetId: localMedia.id.uuidString,
                    mediaKind: localMedia.kind,
                    sortOrder: localMedia.sortOrder,
                    selected: localMedia.selected,
                    moderationStatus: "pending"
                )
            ]
        )
        let backendMediaSignature = viewModel.currentStoryPlanInputSignature(
            momentId: "moment-1",
            persistedMedia: [
                MomentsStoryPlanMedia(
                    mediaAssetId: "backend-media-1",
                    mediaKind: "image",
                    sortOrder: 0,
                    selected: true,
                    moderationStatus: "approved"
                )
            ]
        )

        XCTAssertEqual(viewModel.currentStoryPlanInputSignature(momentId: "moment-1"), expectedLocalSignature)
        XCTAssertNotEqual(viewModel.currentStoryPlanInputSignature(momentId: "moment-1"), backendMediaSignature)
    }
}
