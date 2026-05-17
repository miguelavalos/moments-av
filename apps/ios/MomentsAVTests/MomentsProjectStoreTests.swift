import XCTest
@testable import MomentsAV

@MainActor
final class MomentsProjectStoreTests: XCTestCase {
    func testStoreIsNotConfiguredWithoutDeploymentURL() {
        let store = MomentsProjectStore(deploymentURL: "  ")

        XCTAssertFalse(store.isConfigured)
    }

    func testStoreIsConfiguredWithDeploymentURL() {
        let store = MomentsProjectStore(deploymentURL: "https://moments-av.convex.cloud")

        XCTAssertTrue(store.isConfigured)
    }

    func testCreateDraftFailsFastWhenConvexIsNotConfigured() async {
        let store = MomentsProjectStore(deploymentURL: "")
        let projectId = await store.createDraft(
            ownerUserId: "user-1",
            form: MomentDraftForm(template: .birthdayMessage)
        )

        XCTAssertNil(projectId)
        XCTAssertEqual(store.errorMessage, "Project sync is not configured for this build.")
    }
}
