import XCTest
@testable import MomentsAV

final class MomentsProjectsPresentationTests: XCTestCase {
    func testSignedOutAvailabilityExplainsAccountRequirement() {
        let presentation = MomentsProjectsPresentation.make(
            isSignedIn: false,
            projectSummary: MomentsProjectListSummary(),
            projectPendingDeletion: nil
        )

        XCTAssertEqual(
            presentation.availability,
            .signedOut(
                MomentsProjectsUnavailablePresentation(
                    systemImage: "person.crop.circle.fill",
                    title: "Sign in to make Moments",
                    message: "In Progress and local Gallery unlock once your account is connected."
                )
            )
        )
    }

    func testEmptySignedInAvailabilityExplainsCreateFirstState() {
        let presentation = MomentsProjectsPresentation.make(
            isSignedIn: true,
            projectSummary: MomentsProjectListSummary(),
            projectPendingDeletion: nil
        )

        XCTAssertEqual(
            presentation.availability,
            .empty(
                MomentsProjectsUnavailablePresentation(
                    systemImage: "rectangle.stack.badge.plus",
                    title: "Nothing here yet",
                    message: "Drafts appear in In Progress. Downloaded final videos appear in Gallery."
                )
            )
        )
    }

    func testProjectsAvailabilityIsAvailableWhenSignedInWithProjects() {
        let presentation = MomentsProjectsPresentation.make(
            isSignedIn: true,
            projectSummary: MomentsProjectListSummary.make(from: [
                makeProject(id: "project-1")
            ]),
            projectPendingDeletion: nil
        )

        XCTAssertEqual(presentation.availability, .available)
    }

    func testDeletionMessageUsesPendingProjectTitleOrFallback() {
        let fallback = MomentsProjectsPresentation.make(
            isSignedIn: true,
            projectSummary: MomentsProjectListSummary(),
            projectPendingDeletion: nil
        )
        let project = makeProject(id: "project-1", title: "Family Weekend")
        let titled = MomentsProjectsPresentation.make(
            isSignedIn: true,
            projectSummary: MomentsProjectListSummary(),
            projectPendingDeletion: project
        )

        XCTAssertEqual(
            fallback.deletionMessage,
            "This removes this project, including source media records and generated artifacts."
        )
        XCTAssertEqual(
            titled.deletionMessage,
            "This removes Family Weekend, including source media records and generated artifacts."
        )
    }

    private func makeProject(
        id: String,
        title: String? = nil,
        status: String = "draft_created",
        updatedAt: Double = 10
    ) -> MomentDraftProject {
        MomentDraftProject(
            id: id,
            template: .birthdayMessage,
            status: status,
            title: title ?? id,
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
