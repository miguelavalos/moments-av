import XCTest
@testable import MomentsAV

final class MomentsHomePresentationTests: XCTestCase {
    func testSignedOutStateRequiresAccountAndDisablesProjectActions() {
        let presentation = MomentsHomePresentation.make(
            isSignedIn: false,
            displayName: nil,
            projectSummary: InProgressMomentsSummary()
        )

        XCTAssertEqual(presentation.accountTitle, "Account required")
        XCTAssertEqual(
            presentation.accountDetail,
            "Sign in is required before creating, rendering, and managing Moments."
        )
        XCTAssertTrue(presentation.createAction.isDisabled)
        XCTAssertTrue(presentation.reviewInProgressAction.isDisabled)
        XCTAssertNil(presentation.latestInProgressAction)
        XCTAssertNil(presentation.latestInProgressContinuationRequest)
    }

    func testEmptySignedInStatePromotesCreateAction() {
        let presentation = MomentsHomePresentation.make(
            isSignedIn: true,
            displayName: "Ava",
            projectSummary: InProgressMomentsSummary()
        )

        XCTAssertEqual(presentation.accountTitle, "Account connected")
        XCTAssertEqual(presentation.accountDetail, "Signed in as Ava.")
        XCTAssertEqual(presentation.momentStatusDetail, "No synced Moments yet.")
        XCTAssertTrue(presentation.createAction.isProminent)
        XCTAssertFalse(presentation.createAction.isDisabled)
        XCTAssertEqual(
            presentation.reviewInProgressAction.detail,
            "Drafts appear after you start a Moment."
        )
    }

    func testLatestInProgressProjectAddsContinuationAction() {
        let moment = makeProject(id: "latest-draft", status: "story_ready", updatedAt: 20)
        let presentation = MomentsHomePresentation.make(
            isSignedIn: true,
            displayName: nil,
            projectSummary: InProgressMomentsSummary.make(from: [
                makeProject(id: "finished", status: "completed", updatedAt: 30),
                moment
            ])
        )

        XCTAssertEqual(presentation.latestInProgressAction?.title, "Continue latest Moment")
        XCTAssertEqual(presentation.latestInProgressAction?.systemImage, "arrow.right.circle")
        XCTAssertTrue(presentation.latestInProgressAction?.isProminent == true)
        XCTAssertFalse(presentation.createAction.isProminent)
        XCTAssertEqual(presentation.latestInProgressContinuationRequest?.moment.id, "latest-draft")
        XCTAssertEqual(presentation.latestInProgressContinuationRequest?.focus, .review)
    }

    func testProjectCountDrivesStatusAndReviewDetail() {
        let presentation = MomentsHomePresentation.make(
            isSignedIn: true,
            displayName: nil,
            projectSummary: InProgressMomentsSummary.make(from: [
                makeProject(id: "one", status: "draft_created", updatedAt: 10),
                makeProject(id: "two", status: "completed", updatedAt: 20)
            ])
        )

        XCTAssertEqual(
            presentation.momentStatusDetail,
            "2 synced Moments tracked across the current account."
        )
        XCTAssertEqual(
            presentation.reviewInProgressAction.detail,
            "Open drafts, active renders, and videos waiting for local download."
        )
    }

    func testSingleProjectUsesSingularProjectCopy() {
        let presentation = MomentsHomePresentation.make(
            isSignedIn: true,
            displayName: nil,
            projectSummary: InProgressMomentsSummary.make(from: [
                makeProject(id: "one", status: "draft_created", updatedAt: 10)
            ])
        )

        XCTAssertEqual(
            presentation.momentStatusDetail,
            "1 synced Moment tracked across the current account."
        )
        XCTAssertEqual(
            presentation.reviewInProgressAction.detail,
            "Open drafts, active renders, and videos waiting for local download."
        )
    }

    private func makeProject(id: String, status: String, updatedAt: Double) -> InProgressMoment {
        InProgressMoment(
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
