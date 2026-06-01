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

    func testGalleryStoreResolvesLocalFileURLAndDeletesRecordWithFile() throws {
        let baseDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("moments-gallery-\(UUID().uuidString)", isDirectory: true)
        let store = MomentsGalleryStore(baseDirectory: baseDirectory)
        let videosDirectory = baseDirectory.appendingPathComponent("Videos", isDirectory: true)
        try FileManager.default.createDirectory(at: videosDirectory, withIntermediateDirectories: true)
        let localFileURL = videosDirectory.appendingPathComponent("project-artifact.mp4")
        try Data("video".utf8).write(to: localFileURL)
        let record = MomentsGalleryVideoRecord(
            id: "artifact",
            projectId: "project",
            artifactId: "artifact",
            title: "Birthday",
            r2Key: "renders/project/artifact.mp4",
            localRelativePath: "Videos/project-artifact.mp4",
            createdAt: 1_717_000_000
        )

        store.addRecord(record)

        XCTAssertEqual(store.localFileURL(for: record), localFileURL)
        XCTAssertTrue(store.localFileExists(for: record))
        XCTAssertEqual(store.loadRecords(), [record])

        store.deleteRecord(record, deleteLocalFile: true)

        XCTAssertFalse(store.localFileExists(for: record))
        XCTAssertTrue(store.loadRecords().isEmpty)
        try? FileManager.default.removeItem(at: baseDirectory)
    }
}
