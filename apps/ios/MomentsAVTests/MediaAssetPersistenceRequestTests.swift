import XCTest
@testable import MomentsAV

final class MediaAssetPersistenceRequestTests: XCTestCase {
    func testMediaRequestUsesPreparedUploadAndSelectionState() {
        let uploadedAt = Date(timeIntervalSince1970: 1_800_000_000)
        let media = MomentsSelectedMedia(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            sourceLocalIdentifier: "local-1",
            originalFilename: "video.mov",
            contentType: "video/quicktime",
            kind: "video",
            byteSize: 4,
            sha256: "abcd",
            data: Data([1, 2, 3, 4]),
            capturedAt: nil,
            sortOrder: 2,
            selected: true
        )
        let preparedUpload = MomentsPreparedUpload(
            appId: "momentsav",
            projectId: "project-1",
            mediaAssetId: "asset-1",
            uploadId: "upload-1",
            uploadUrl: URL(string: "https://uploads.example/video.mov")!,
            completionUrl: nil,
            method: "PUT",
            headers: ["content-type": "video/quicktime"],
            storageKey: "momentsav/user/project/source/video.mov",
            expiresAt: "2026-05-16T17:00:00Z",
            generatedAt: "2026-05-16T16:00:00Z"
        )

        let request = MediaAssetPersistenceRequest.asset(
            media,
            preparedUpload: preparedUpload,
            uploadedAt: uploadedAt
        )

        XCTAssertEqual(request.platformMediaAssetId, "asset-1")
        XCTAssertEqual(request.uploadId, "upload-1")
        XCTAssertEqual(request.kind, "video")
        XCTAssertEqual(request.r2Key, "momentsav/user/project/source/video.mov")
        XCTAssertEqual(request.sortOrder, 2.0)
        XCTAssertTrue(request.selected)
        XCTAssertEqual(request.moderationStatus, "pending")
        XCTAssertEqual(request.uploadedAt, uploadedAt)
    }
}
