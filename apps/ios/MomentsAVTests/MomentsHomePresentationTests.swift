import XCTest
@testable import MomentsAV

final class MomentsHomePresentationTests: XCTestCase {
    func testSignedOutStateRequiresAccountAndDisablesProjectActions() {
        let presentation = MomentsHomePresentation.make(
            isSignedIn: false,
            displayName: nil,
            projectSummary: MomentsProjectListSummary()
        )

        XCTAssertEqual(presentation.accountTitle, "Account required")
        XCTAssertEqual(
            presentation.accountDetail,
            "Sign in is required before creating, rendering, and managing projects."
        )
        XCTAssertTrue(presentation.createAction.isDisabled)
        XCTAssertTrue(presentation.reviewProjectsAction.isDisabled)
        XCTAssertNil(presentation.latestInProgressAction)
        XCTAssertNil(presentation.latestInProgressContinuationRequest)
    }

    func testEmptySignedInStatePromotesCreateAction() {
        let presentation = MomentsHomePresentation.make(
            isSignedIn: true,
            displayName: "Ava",
            projectSummary: MomentsProjectListSummary()
        )

        XCTAssertEqual(presentation.accountTitle, "Account connected")
        XCTAssertEqual(presentation.accountDetail, "Signed in as Ava.")
        XCTAssertEqual(presentation.projectStatusDetail, "No synced projects yet.")
        XCTAssertTrue(presentation.createAction.isProminent)
        XCTAssertFalse(presentation.createAction.isDisabled)
        XCTAssertEqual(
            presentation.reviewProjectsAction.detail,
            "Project workspace details will appear after the first synced draft."
        )
    }

    func testLatestInProgressProjectAddsContinuationAction() {
        let project = makeProject(id: "latest-draft", status: "story_ready", updatedAt: 20)
        let presentation = MomentsHomePresentation.make(
            isSignedIn: true,
            displayName: nil,
            projectSummary: MomentsProjectListSummary.make(from: [
                makeProject(id: "finished", status: "completed", updatedAt: 30),
                project
            ])
        )

        XCTAssertEqual(presentation.latestInProgressAction?.title, "Continue latest project")
        XCTAssertEqual(presentation.latestInProgressAction?.systemImage, "arrow.right.circle")
        XCTAssertTrue(presentation.latestInProgressAction?.isProminent == true)
        XCTAssertFalse(presentation.createAction.isProminent)
        XCTAssertEqual(presentation.latestInProgressContinuationRequest?.project.id, "latest-draft")
        XCTAssertEqual(presentation.latestInProgressContinuationRequest?.focus, .review)
    }

    func testProjectCountDrivesStatusAndReviewDetail() {
        let presentation = MomentsHomePresentation.make(
            isSignedIn: true,
            displayName: nil,
            projectSummary: MomentsProjectListSummary.make(from: [
                makeProject(id: "one", status: "draft_created", updatedAt: 10),
                makeProject(id: "two", status: "completed", updatedAt: 20)
            ])
        )

        XCTAssertEqual(
            presentation.projectStatusDetail,
            "2 synced projects tracked across the current account."
        )
        XCTAssertEqual(
            presentation.reviewProjectsAction.detail,
            "Open 2 synced projects with preview and final status."
        )
    }

    func testSingleProjectUsesSingularProjectCopy() {
        let presentation = MomentsHomePresentation.make(
            isSignedIn: true,
            displayName: nil,
            projectSummary: MomentsProjectListSummary.make(from: [
                makeProject(id: "one", status: "draft_created", updatedAt: 10)
            ])
        )

        XCTAssertEqual(
            presentation.projectStatusDetail,
            "1 synced project tracked across the current account."
        )
        XCTAssertEqual(
            presentation.reviewProjectsAction.detail,
            "Open 1 synced project with preview and final status."
        )
    }

    private func makeProject(id: String, status: String, updatedAt: Double) -> MomentDraftProject {
        MomentDraftProject(
            id: id,
            template: .birthdayMessage,
            status: status,
            title: id,
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: updatedAt
        )
    }
}
