import XCTest
@testable import MomentsAV

final class MomentsNewMomentStartControllerTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var userDefaultsSuiteName: String!

    override func setUp() {
        super.setUp()
        userDefaultsSuiteName = "MomentsNewMomentStartControllerTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
        userDefaults = nil
        userDefaultsSuiteName = nil
        super.tearDown()
    }

    func testDefaultsToPhotosOrClipsForSpeed() {
        let controller = MomentsNewMomentStartController(userDefaults: userDefaults)

        XCTAssertEqual(controller.currentPreference, .photosOrClips)
    }

    func testSelectPersistsPreference() {
        let controller = MomentsNewMomentStartController(userDefaults: userDefaults)

        controller.select(.album)

        let reloaded = MomentsNewMomentStartController(userDefaults: userDefaults)
        XCTAssertEqual(reloaded.currentPreference, .album)
    }

    func testInvalidStoredPreferenceFallsBackToPhotosOrClips() {
        userDefaults.set("unexpected", forKey: "momentsav.newMomentStartPreference")

        let controller = MomentsNewMomentStartController(userDefaults: userDefaults)

        XCTAssertEqual(controller.currentPreference, .photosOrClips)
    }
}
