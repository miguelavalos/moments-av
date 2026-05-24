import XCTest
@testable import MomentsAV

@MainActor
final class MomentsProjectRepositoryTests: XCTestCase {
    func testRepositoryIsNotConfiguredWithoutDeploymentURL() {
        let repository = MomentsProjectRepository(deploymentURL: "  ")

        XCTAssertFalse(repository.isConfigured)
    }

    func testRepositoryIsConfiguredWithDeploymentURL() {
        let repository = MomentsProjectRepository(deploymentURL: "https://moments-av.convex.cloud")

        XCTAssertTrue(repository.isConfigured)
    }

    func testCreateDraftThrowsNotConfiguredWhenConvexIsNotConfigured() async {
        let repository = MomentsProjectRepository(deploymentURL: "")

        do {
            _ = try await repository.createDraft(
                ownerUserId: "user-1",
                form: MomentDraftForm(template: .birthdayMessage)
            )
            XCTFail("Expected not configured error")
        } catch {
            XCTAssertEqual(error as? MomentsProjectSyncError, .notConfigured)
        }
    }

    func testCreateDraftThrowsInvalidFormBeforeRemoteCall() async {
        let repository = MomentsProjectRepository(deploymentURL: "")
        var form = MomentDraftForm(template: .birthdayMessage)
        form.occasion = "  "

        do {
            _ = try await repository.createDraft(ownerUserId: "user-1", form: form)
            XCTFail("Expected invalid form error")
        } catch {
            XCTAssertEqual(error as? MomentsProjectSyncError, .invalidForm)
        }
    }
}
