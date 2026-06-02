import XCTest
@testable import MomentsAV

@MainActor
final class MomentsRepositoryTests: XCTestCase {
    func testRepositoryIsNotConfiguredWithoutDeploymentURL() {
        let repository = MomentsRepository(deploymentURL: "  ")

        XCTAssertFalse(repository.isConfigured)
    }

    func testRepositoryIsConfiguredWithDeploymentURL() {
        let repository = MomentsRepository(deploymentURL: "https://moments-av.convex.cloud")

        XCTAssertTrue(repository.isConfigured)
    }

    func testCreateMomentThrowsNotConfiguredWhenConvexIsNotConfigured() async {
        let repository = MomentsRepository(deploymentURL: "")

        do {
            _ = try await repository.createMoment(
                ownerUserId: "user-1",
                form: MomentSetupForm(template: .birthdayMessage)
            )
            XCTFail("Expected not configured error")
        } catch {
            XCTAssertEqual(error as? MomentsSyncError, .notConfigured)
        }
    }

    func testCreateMomentThrowsInvalidFormBeforeRemoteCall() async {
        let repository = MomentsRepository(deploymentURL: "")
        var form = MomentSetupForm(template: .birthdayMessage)
        form.occasion = "  "

        do {
            _ = try await repository.createMoment(ownerUserId: "user-1", form: form)
            XCTFail("Expected invalid form error")
        } catch {
            XCTAssertEqual(error as? MomentsSyncError, .invalidForm)
        }
    }
}
