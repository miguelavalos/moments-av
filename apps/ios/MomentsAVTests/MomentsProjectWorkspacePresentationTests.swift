import XCTest
@testable import MomentsAV

final class MomentsProjectWorkspacePresentationTests: XCTestCase {
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
}
