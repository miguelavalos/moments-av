import Foundation
import XCTest
@testable import MomentsAV

final class MomentsMediaRulesTests: XCTestCase {
    func testSelectedCountUsesSyncedMediaWhenLocalSelectionIsEmpty() {
        let syncedMedia = [
            makeSyncedMedia(id: "media-1", selected: true),
            makeSyncedMedia(id: "media-2", selected: false),
            makeSyncedMedia(id: "media-3", selected: true)
        ]

        XCTAssertEqual(
            MomentsMediaRules.selectedCount(localMedia: [], syncedMedia: syncedMedia),
            2
        )
    }

    func testSelectedCountPrefersLocalMediaWhenPresent() {
        let localMedia = [
            makeLocalMedia(id: "00000000-0000-0000-0000-000000000001", selected: true),
            makeLocalMedia(id: "00000000-0000-0000-0000-000000000002", selected: false)
        ]
        let syncedMedia = [
            makeSyncedMedia(id: "media-1", selected: true),
            makeSyncedMedia(id: "media-2", selected: true),
            makeSyncedMedia(id: "media-3", selected: true)
        ]

        XCTAssertEqual(
            MomentsMediaRules.selectedCount(localMedia: localMedia, syncedMedia: syncedMedia),
            1
        )
    }

    func testRemainingSlotsNeverReturnsNegativeCount() {
        XCTAssertEqual(
            MomentsMediaRules.remainingSlots(template: .birthdayMessage, selectedCount: 19),
            1
        )
        XCTAssertEqual(
            MomentsMediaRules.remainingSlots(template: .birthdayMessage, selectedCount: 20),
            0
        )
        XCTAssertEqual(
            MomentsMediaRules.remainingSlots(template: .birthdayMessage, selectedCount: 21),
            0
        )
    }

    private func makeLocalMedia(id: String, selected: Bool) -> MomentsSelectedMedia {
        MomentsSelectedMedia(
            id: UUID(uuidString: id)!,
            sourceLocalIdentifier: id,
            originalFilename: "\(id).jpg",
            contentType: "image/jpeg",
            kind: "photo",
            byteSize: 4,
            sha256: "abcd",
            data: Data([1, 2, 3, 4]),
            sortOrder: 0,
            selected: selected
        )
    }

    private func makeSyncedMedia(id: String, selected: Bool) -> MomentMediaAsset {
        MomentMediaAsset(
            id: id,
            platformMediaAssetId: "platform-\(id)",
            uploadId: "upload-\(id)",
            kind: "photo",
            sortOrder: 0,
            selected: selected,
            moderationStatus: "pending",
            uploadedAt: 1_779_000_000_000,
            sourceExpiresAt: 1_781_592_000_000
        )
    }
}
