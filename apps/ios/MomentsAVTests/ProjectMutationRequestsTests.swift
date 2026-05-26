import XCTest
@testable import MomentsAV

final class ProjectMutationRequestsTests: XCTestCase {
    func testDraftCreationRequestUsesFormValues() {
        var form = MomentDraftForm(template: .partyRecap)
        form.recipient = "Ava"
        form.occasion = "Graduation"
        form.tone = .cinematic
        form.tempo = .upbeat
        form.details = "Use the beach photos first."

        let request = DraftProjectCreationRequest.draft(form)

        XCTAssertEqual(request.template, "party_recap")
        XCTAssertEqual(request.title, "Graduation for Ava")
        XCTAssertEqual(request.tone, "cinematic")
        XCTAssertEqual(request.tempo, "upbeat")
        XCTAssertEqual(request.occasion, "Graduation")
        XCTAssertEqual(request.details, "Use the beach photos first.")
    }

    func testDraftCreationRequestUsesOccasionWhenRecipientIsEmpty() {
        var form = MomentDraftForm(template: .softRoast)
        form.occasion = "Team dinner"
        form.recipient = "  "

        let request = DraftProjectCreationRequest.draft(form)

        XCTAssertEqual(request.title, "Team dinner")
    }

    func testProjectDeletionRequestDeletesProjectTreeForUserRequest() {
        let request = ProjectDeletionRequest.userRequested(projectId: "project-1")

        XCTAssertEqual(request.projectId, "project-1")
        XCTAssertTrue(request.deleteSourceMedia)
        XCTAssertTrue(request.deleteGeneratedArtifacts)
        XCTAssertEqual(request.reason, "user request")
    }
}
