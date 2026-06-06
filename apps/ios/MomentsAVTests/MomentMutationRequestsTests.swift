import XCTest
import Combine
@testable import MomentsAV

final class MomentMutationRequestsTests: XCTestCase {
    func testMomentCreationRequestUsesFormValues() {
        var form = MomentSetupForm(template: .partyRecap)
        form.recipient = "Ava"
        form.occasion = "Graduation"
        form.tone = .cinematic
        form.tempo = .upbeat
        form.details = "Use the beach photos first."

        let request = MomentCreationRequest.setup(form)

        XCTAssertEqual(request.theme, "celebration")
        XCTAssertEqual(request.title, "Graduation for Ava")
        XCTAssertEqual(request.mood, "cinematic")
        XCTAssertEqual(request.duration, "auto")
        XCTAssertEqual(request.occasion, "Graduation")
        XCTAssertEqual(request.details, "Use the beach photos first.")
    }

    func testMomentCreationRequestUsesOccasionWhenRecipientIsEmpty() {
        var form = MomentSetupForm(template: .softRoast)
        form.occasion = "Team dinner"
        form.recipient = "  "

        let request = MomentCreationRequest.setup(form)

        XCTAssertEqual(request.title, "Team dinner")
    }

    func testMomentDeletionRequestDeletesMomentTreeForUserRequest() {
        let request = MomentDeletionRequest.userRequested(momentId: "moment-1")

        XCTAssertEqual(request.momentId, "moment-1")
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
        let localFileURL = videosDirectory.appendingPathComponent("moment-artifact.mp4")
        try Data("video".utf8).write(to: localFileURL)
        let record = MomentsGalleryVideoRecord(
            id: "artifact",
            momentId: "moment",
            artifactId: "artifact",
            title: "Birthday",
            r2Key: "renders/moment/artifact.mp4",
            localRelativePath: "Videos/moment-artifact.mp4",
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

    @MainActor
    func testGalleryViewModelShowsRemoteGalleryMetadataWhenNoLocalRecordExists() {
        let provider = TestGalleryMomentsProvider()
        let viewModel = MomentsGalleryViewModel(
            galleryStore: MomentsGalleryStore(baseDirectory: temporaryGalleryDirectory()),
            galleryMomentsProvider: provider
        )

        provider.publish([Self.galleryMoment(artifactStatus: "available", expiresAt: Date().timeIntervalSince1970 * 1000 + 60_000)])

        XCTAssertEqual(viewModel.videos.count, 1)
        XCTAssertEqual(viewModel.videos[0].availability, .downloadAvailable)
        XCTAssertNil(viewModel.videos[0].localFileURL)
    }

    @MainActor
    func testGalleryViewModelKeepsLocalMissingRecordAndMarksDownloadUnavailableWithoutRemoteArtifact() {
        let baseDirectory = temporaryGalleryDirectory()
        let store = MomentsGalleryStore(baseDirectory: baseDirectory)
        store.addRecord(
            MomentsGalleryVideoRecord(
                id: "artifact-1",
                momentId: "moment-1",
                artifactId: "artifact-1",
                title: "Recovered",
                r2Key: "renders/moment-1/artifact-1.mp4",
                localRelativePath: "Videos/missing.mp4",
                createdAt: 1
            )
        )

        let viewModel = MomentsGalleryViewModel(galleryStore: store)

        XCTAssertEqual(viewModel.videos.count, 1)
        XCTAssertEqual(viewModel.videos[0].availability, .localFileMissing)
    }

    @MainActor
    func testGalleryViewModelDedupesLocalAndRemoteByArtifactId() {
        let baseDirectory = temporaryGalleryDirectory()
        let store = MomentsGalleryStore(baseDirectory: baseDirectory)
        store.addRecord(
            MomentsGalleryVideoRecord(
                id: "workflow-artifact-1",
                momentId: "moment-1",
                artifactId: "workflow-artifact-1",
                title: "Local title",
                r2Key: "renders/moment-1/artifact-1.mp4",
                localRelativePath: "Videos/missing.mp4",
                createdAt: 1
            )
        )
        let provider = TestGalleryMomentsProvider()
        let viewModel = MomentsGalleryViewModel(galleryStore: store, galleryMomentsProvider: provider)

        provider.publish([Self.galleryMoment(workflowArtifactId: "workflow-artifact-1")])

        XCTAssertEqual(viewModel.videos.count, 1)
        XCTAssertEqual(viewModel.videos[0].availability, .downloadAvailable)
    }

    private func temporaryGalleryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("moments-gallery-\(UUID().uuidString)", isDirectory: true)
    }

    private static func galleryMoment(
        workflowArtifactId: String? = "workflow-artifact-1",
        artifactStatus: String = "available",
        expiresAt: Double = Date().timeIntervalSince1970 * 1000 + 60_000
    ) -> InProgressMoment {
        InProgressMoment(
            id: "moment-1",
            template: .birthdayMessage,
            status: "gallery",
            title: "Remote title",
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            updatedAt: 2,
            finalExport: MomentArtifact(
                id: "artifact-1",
                workflowArtifactId: workflowArtifactId,
                kind: "final_export",
                r2Key: "renders/moment-1/artifact-1.mp4",
                status: artifactStatus,
                hasWatermark: false,
                expiresAt: expiresAt,
                createdAt: 2
            )
        )
    }
}

@MainActor
private final class TestGalleryMomentsProvider: GalleryMomentsListProviding {
    private let momentsSubject = CurrentValueSubject<[InProgressMoment], Never>([])
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)

    var galleryMomentsPublisher: AnyPublisher<[InProgressMoment], Never> {
        momentsSubject.eraseToAnyPublisher()
    }

    var galleryMomentsErrorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    func observeGalleryMoments(ownerUserId: String?) {}
    func clearGalleryMoments() {}

    func publish(_ moments: [InProgressMoment]) {
        momentsSubject.send(moments)
    }
}
