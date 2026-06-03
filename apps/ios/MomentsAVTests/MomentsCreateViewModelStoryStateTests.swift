import XCTest
import Combine
@testable import MomentsAV

@MainActor
final class MomentsCreateViewModelStoryStateTests: XCTestCase {
    func testBeginNewMomentWithoutPickerRequestShowsMediaChoice() {
        let viewModel = MomentsCreateViewModel()
        viewModel.beginNewMoment()

        XCTAssertTrue(viewModel.hasLocalMomentWorkspace)
        XCTAssertEqual(viewModel.mediaPickerOpenRequest, 0)
        XCTAssertTrue(viewModel.workflowPresentation.showsMediaFirstWorkspace)
    }

    func testBeginNewMomentCanExplicitlyOpenPhotoPicker() {
        let viewModel = MomentsCreateViewModel()
        viewModel.beginNewMoment(openMediaPicker: true)

        XCTAssertTrue(viewModel.hasLocalMomentWorkspace)
        XCTAssertEqual(viewModel.mediaPickerOpenRequest, 1)
        XCTAssertEqual(viewModel.albumPickerOpenRequest, 0)
    }

    func testBeginNewMomentCanExplicitlyOpenAlbumPicker() {
        let viewModel = MomentsCreateViewModel()
        viewModel.beginNewMoment(openAlbumPicker: true)

        XCTAssertTrue(viewModel.hasLocalMomentWorkspace)
        XCTAssertEqual(viewModel.mediaPickerOpenRequest, 0)
        XCTAssertEqual(viewModel.albumPickerOpenRequest, 1)
    }

    func testStoryScenesClearStaleErrorAndMarkCurrentInputPrepared() {
        let viewModel = MomentsCreateViewModel()
        let media = MomentsCreateTestFixtures.makeSelectedMedia(
            id: "00000000-0000-0000-0000-000000000001"
        )

        viewModel.applyMomentCreationState(
            MomentsCreateMomentCreationState(
                isCreatingMoment: false,
                activeMomentId: "moment-1",
                setupErrorMessage: nil
            )
        )
        viewModel.applyMediaUploadState(
            MomentsCreateMediaUploadState(
                selectedMedia: [media],
                statusMessage: nil,
                isImporting: false,
                importProgress: nil
            )
        )
        viewModel.applyStoryPlanState(
            MomentsCreateStoryPlanState(
                savedScenes: [],
                generatedScenes: [],
                statusMessage: MomentsRecoveryCopy.storyFailure(),
                isPlanning: false
            )
        )

        XCTAssertEqual(viewModel.storySummary.statusMessage, MomentsRecoveryCopy.storyFailure())
        XCTAssertFalse(viewModel.isStoryPreparedForCurrentInput)

        viewModel.applyStoryPlanState(
            MomentsCreateStoryPlanState(
                savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
                generatedScenes: [],
                statusMessage: MomentsRecoveryCopy.storyFailure(),
                isPlanning: false
            )
        )

        XCTAssertNil(viewModel.storySummary.statusMessage)
        XCTAssertTrue(viewModel.isStoryPreparedForCurrentInput)
    }

    func testCurrentStorySignaturePrefersLocalMediaWhenWorkspaceHasUploadedMedia() {
        let viewModel = MomentsCreateViewModel()
        let localMedia = MomentsCreateTestFixtures.makeSelectedMedia(
            id: "00000000-0000-0000-0000-000000000001",
            sourceLocalIdentifier: "local-asset-1"
        )

        viewModel.applyMomentCreationState(
            MomentsCreateMomentCreationState(
                isCreatingMoment: false,
                activeMomentId: "moment-1",
                setupErrorMessage: nil
            )
        )
        viewModel.applyMediaUploadState(
            MomentsCreateMediaUploadState(
                selectedMedia: [localMedia],
                statusMessage: nil,
                isImporting: false,
                importProgress: nil
            )
        )

        viewModel.applyPreviewGenerationState(
            MomentsCreatePreviewGenerationState(
                activeWorkspace: MomentWorkspace(
                moment: MomentsCreateTestFixtures.makeMoment(id: "moment-1"),
                mediaAssets: [
                    MomentsCreateTestFixtures.makeMediaAsset(
                        id: "backend-media-1",
                        sortOrder: 0
                    )
                ],
                storyScenes: [],
                renderJobs: [],
                artifacts: []
                ),
                latestPreview: nil,
                latestPreviewJob: nil,
                statusMessage: nil,
                isGenerating: false,
                isRefreshingStatus: false
            )
        )

        let expectedLocalSignature = viewModel.currentStoryPlanInputSignature(
            momentId: "moment-1",
            persistedMedia: [
                MomentsStoryPlanMedia(
                    mediaAssetId: localMedia.id.uuidString,
                    mediaKind: localMedia.kind,
                    sortOrder: localMedia.sortOrder,
                    selected: localMedia.selected,
                    moderationStatus: "pending"
                )
            ]
        )
        let backendMediaSignature = viewModel.currentStoryPlanInputSignature(
            momentId: "moment-1",
            persistedMedia: [
                MomentsStoryPlanMedia(
                    mediaAssetId: "backend-media-1",
                    mediaKind: "image",
                    sortOrder: 0,
                    selected: true,
                    moderationStatus: "approved"
                )
            ]
        )

        XCTAssertEqual(viewModel.currentStoryPlanInputSignature(momentId: "moment-1"), expectedLocalSignature)
        XCTAssertNotEqual(viewModel.currentStoryPlanInputSignature(momentId: "moment-1"), backendMediaSignature)
    }

    func testWorkspaceSignatureReconcilesAfterStoryScenesArriveFirst() {
        let viewModel = MomentsCreateViewModel()
        let localMedia = MomentsCreateTestFixtures.makeSelectedMedia(
            id: "00000000-0000-0000-0000-000000000001",
            sourceLocalIdentifier: "local-asset-1"
        )
        let backendMedia = makeBackendMedia()
        let backendSignature = viewModel.currentStoryPlanInputSignature(
            momentId: "moment-1",
            persistedMedia: [makeStoryPlanMedia(from: backendMedia)]
        )

        viewModel.applyMomentCreationState(
            MomentsCreateMomentCreationState(
                isCreatingMoment: false,
                activeMomentId: "moment-1",
                setupErrorMessage: nil
            )
        )
        viewModel.applyMediaUploadState(
            MomentsCreateMediaUploadState(
                selectedMedia: [localMedia],
                statusMessage: nil,
                isImporting: false,
                importProgress: nil
            )
        )

        viewModel.applyStoryPlanState(
            MomentsCreateStoryPlanState(
                savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
                generatedScenes: [],
                statusMessage: nil,
                isPlanning: false
            )
        )
        XCTAssertTrue(viewModel.isStoryPreparedForCurrentInput)

        viewModel.applyPreviewGenerationState(
            MomentsCreatePreviewGenerationState(
                activeWorkspace: MomentWorkspace(
                    moment: MomentsCreateTestFixtures.makeMoment(
                        id: "moment-1",
                        occasion: "Birthday",
                        storyInputSignature: backendSignature
                    ),
                    mediaAssets: [backendMedia],
                    storyScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
                    renderJobs: [],
                    artifacts: []
                ),
                latestPreview: nil,
                latestPreviewJob: nil,
                statusMessage: nil,
                isGenerating: false,
                isRefreshingStatus: false
            )
        )

        XCTAssertEqual(viewModel.lastPreparedStoryInputSignature, backendSignature)
        XCTAssertTrue(viewModel.isStoryPreparedForCurrentInput)
    }

    func testRestoredLocalMediaDoesNotInvalidatePreparedBackendStory() {
        let viewModel = MomentsCreateViewModel()
        let syncedLocalMedia = MomentsCreateTestFixtures.makeSelectedMedia(
            id: "00000000-0000-0000-0000-000000000001",
            sourceLocalIdentifier: "local-asset-1"
        )
        let extraRestoredMedia = MomentsCreateTestFixtures.makeSelectedMedia(
            id: "00000000-0000-0000-0000-000000000002",
            sourceLocalIdentifier: "local-asset-extra"
        )
        let preparedStory = applyPreparedBackendStory(to: viewModel)
        viewModel.applyMediaUploadState(
            MomentsCreateMediaUploadState(
                selectedMedia: [syncedLocalMedia, extraRestoredMedia],
                statusMessage: nil,
                isImporting: false,
                importProgress: nil
            )
        )

        XCTAssertNotEqual(viewModel.currentStoryPlanInputSignature(momentId: "moment-1"), preparedStory.signature)
        XCTAssertTrue(viewModel.isStoryPreparedForCurrentInput)
    }

    func testDirectionChangeInvalidatesPreparedBackendStoryWithRestoredLocalMedia() {
        let viewModel = MomentsCreateViewModel()
        applyPreparedBackendStory(to: viewModel)

        XCTAssertTrue(viewModel.isStoryPreparedForCurrentInput)

        viewModel.form.details = "Make this more cinematic."

        XCTAssertFalse(viewModel.isStoryPreparedForCurrentInput)
    }

    func testExplicitMediaEditInvalidatesPreparedBackendStory() {
        let viewModel = MomentsCreateViewModel()
        let preparedStory = applyPreparedBackendStory(to: viewModel)

        XCTAssertTrue(viewModel.isStoryPreparedForCurrentInput)

        viewModel.markPreparedStoryMediaEdited()
        viewModel.applyMediaUploadState(
            MomentsCreateMediaUploadState(
                selectedMedia: [
                    MomentsCreateTestFixtures.makeSelectedMedia(
                        id: "00000000-0000-0000-0000-000000000002",
                        sourceLocalIdentifier: "local-asset-extra"
                    )
                ],
                statusMessage: nil,
                isImporting: false,
                importProgress: nil
            )
        )

        XCTAssertFalse(viewModel.isStoryPreparedForCurrentInput)

        viewModel.applyPreviewGenerationState(
            MomentsCreatePreviewGenerationState(
                activeWorkspace: MomentWorkspace(
                    moment: MomentsCreateTestFixtures.makeMoment(
                        id: "moment-1",
                        occasion: "Birthday",
                        storyInputSignature: preparedStory.signature
                    ),
                    mediaAssets: [preparedStory.media],
                    storyScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
                    renderJobs: [],
                    artifacts: []
                ),
                latestPreview: nil,
                latestPreviewJob: nil,
                statusMessage: nil,
                isGenerating: false,
                isRefreshingStatus: false
            )
        )

        XCTAssertFalse(viewModel.isStoryPreparedForCurrentInput)
    }

    func testGenerateStoryPlanShowsImmediateMomentCreationError() async {
        let harness = MomentCreationFailureHarness(error: MomentsSyncError.notConfigured)
        let viewModel = MomentsCreateViewModel()
        viewModel.bind(
            accountStateProvider: harness,
            momentCreationWorkflow: harness.momentCreationWorkflow,
            mediaUploadWorkflow: harness.mediaUploadWorkflow,
            storyPlanWorkflow: harness.storyPlanWorkflow,
            previewGenerationWorkflow: harness.previewGenerationWorkflow,
            finalRenderWorkflow: harness.finalRenderWorkflow
        )
        await Task.yield()
        await Task.yield()
        viewModel.applyAccountState(
            MomentsCreateAccountState(
                isSignedIn: true,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 15, purchased: 0),
                creditBalanceLoadState: .loaded
            )
        )
        viewModel.beginNewMoment(openMediaPicker: false)
        viewModel.applyMediaUploadState(
            MomentsCreateMediaUploadState(
                selectedMedia: [
                    MomentsCreateTestFixtures.makeSelectedMedia(
                        id: "00000000-0000-0000-0000-000000000001"
                    )
                ],
                statusMessage: nil,
                isImporting: false,
                importProgress: nil
            )
        )

        viewModel.generateStoryPlan()
        await fulfillment(of: [harness.createAttemptExpectation], timeout: 1)
        await waitForStoryStatusMessage(in: viewModel)

        XCTAssertEqual(viewModel.storySummary.statusMessage, MomentsSyncError.notConfigured.localizedDescription)
    }

    @discardableResult
    private func applyPreparedBackendStory(
        to viewModel: MomentsCreateViewModel,
        momentId: String = "moment-1"
    ) -> (media: MomentMediaAsset, signature: String) {
        let media = makeBackendMedia()
        let signature = viewModel.currentStoryPlanInputSignature(
            momentId: momentId,
            persistedMedia: [makeStoryPlanMedia(from: media)]
        )

        viewModel.applyMomentCreationState(
            MomentsCreateMomentCreationState(
                isCreatingMoment: false,
                activeMomentId: momentId,
                setupErrorMessage: nil
            )
        )
        viewModel.applyPreviewGenerationState(
            MomentsCreatePreviewGenerationState(
                activeWorkspace: MomentWorkspace(
                    moment: MomentsCreateTestFixtures.makeMoment(
                        id: momentId,
                        occasion: "Birthday",
                        storyInputSignature: signature
                    ),
                    mediaAssets: [media],
                    storyScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
                    renderJobs: [],
                    artifacts: []
                ),
                latestPreview: nil,
                latestPreviewJob: nil,
                statusMessage: nil,
                isGenerating: false,
                isRefreshingStatus: false
            )
        )
        viewModel.applyStoryPlanState(
            MomentsCreateStoryPlanState(
                savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
                generatedScenes: [],
                statusMessage: nil,
                isPlanning: false
            )
        )

        return (media, signature)
    }

    private func makeBackendMedia() -> MomentMediaAsset {
        MomentMediaAsset(
            id: "backend-media-1",
            platformMediaAssetId: "local-asset-1",
            uploadId: "upload-backend-media-1",
            kind: "image",
            sortOrder: 0,
            selected: true,
            moderationStatus: "approved",
            uploadedAt: nil,
            sourceExpiresAt: nil
        )
    }

    private func makeStoryPlanMedia(from media: MomentMediaAsset) -> MomentsStoryPlanMedia {
        MomentsStoryPlanMedia(
            mediaAssetId: media.id,
            mediaKind: media.kind,
            sortOrder: Int(media.sortOrder),
            selected: media.selected,
            moderationStatus: media.moderationStatus
        )
    }

    private func waitForStoryStatusMessage(in viewModel: MomentsCreateViewModel) async {
        for _ in 0..<20 where viewModel.storySummary.statusMessage == nil {
            try? await Task.sleep(nanoseconds: 25_000_000)
        }
    }
}

@MainActor
private final class MomentCreationFailureHarness:
    MomentsAccountStateProviding,
    MomentsCurrentUserProviding,
    MomentsAuthTokenProviding,
    MomentsCreditBalanceProviding,
    MomentsCreating,
    MomentsDeleting,
    MomentsMediaAssetSaving,
    MomentsStoryPlanSaving,
    MomentsPreviewResultSaving,
    MomentsFinalRenderResultSaving,
    MomentsActiveWorkspaceObserving
{
    let createAttemptExpectation = XCTestExpectation(description: "Moment creation attempted")
    private let creationError: Error
    private let signedInSubject = CurrentValueSubject<Bool, Never>(true)
    private let currentUserSubject = CurrentValueSubject<String?, Never>("user-1")
    private let displayNameSubject = CurrentValueSubject<String?, Never>("Ava")
    private let balanceSubject = CurrentValueSubject<MomentsCreditBalance, Never>(
        MomentsCreditBalance(proMonthly: 0, promotional: 15, purchased: 0)
    )
    private let creditBalanceLoadStateSubject = CurrentValueSubject<MomentsCreditBalanceLoadState, Never>(.loaded)
    private let workspaceSubject = CurrentValueSubject<MomentWorkspace?, Never>(nil)
    private let workspaceErrorSubject = CurrentValueSubject<String?, Never>(nil)

    init(error: Error) {
        creationError = error
    }

    var momentCreationWorkflow: MomentCreationWorkflow {
        MomentCreationWorkflow(
            currentUserProvider: self,
            creditBalanceProvider: self,
            momentCreator: self,
            momentDeleter: self,
            workspaceObserver: self
        )
    }

    var mediaUploadWorkflow: MediaUploadWorkflow {
        MediaUploadWorkflow(
            currentUserProvider: self,
            authTokenProvider: self,
            mediaAssetSaver: self,
            workspaceObserver: self,
            uploadClient: MomentsUploadClient(baseURLString: "https://api.example.com")
        )
    }

    var storyPlanWorkflow: StoryPlanWorkflow {
        StoryPlanWorkflow(
            currentUserProvider: self,
            authTokenProvider: self,
            storyPlanSaver: self,
            workspaceObserver: self,
            storyClient: MomentsStoryClient(baseURLString: "https://api.example.com")
        )
    }

    var previewGenerationWorkflow: PreviewGenerationWorkflow {
        PreviewGenerationWorkflow(
            currentUserProvider: self,
            authTokenProvider: self,
            previewResultSaver: self,
            workspaceObserver: self,
            previewClient: MomentsPreviewClient(baseURLString: "https://api.example.com"),
            statusClient: MomentsRenderStatusClient(baseURLString: "https://api.example.com")
        )
    }

    var finalRenderWorkflow: FinalRenderWorkflow {
        FinalRenderWorkflow(
            currentUserProvider: self,
            authTokenProvider: self,
            creditBalanceProvider: self,
            finalRenderResultSaver: self,
            workspaceObserver: self,
            finalRenderClient: MomentsFinalRenderClient(baseURLString: "https://api.example.com"),
            statusClient: MomentsRenderStatusClient(baseURLString: "https://api.example.com"),
            galleryStore: TestGalleryStore()
        )
    }

    var isSignedInPublisher: AnyPublisher<Bool, Never> {
        signedInSubject.eraseToAnyPublisher()
    }

    var currentUserIdPublisher: AnyPublisher<String?, Never> {
        currentUserSubject.eraseToAnyPublisher()
    }

    var displayNamePublisher: AnyPublisher<String?, Never> {
        displayNameSubject.eraseToAnyPublisher()
    }

    var creditBalancePublisher: AnyPublisher<MomentsCreditBalance, Never> {
        balanceSubject.eraseToAnyPublisher()
    }

    var creditBalanceLoadStatePublisher: AnyPublisher<MomentsCreditBalanceLoadState, Never> {
        creditBalanceLoadStateSubject.eraseToAnyPublisher()
    }

    var currentUserId: String? {
        currentUserSubject.value
    }

    var currentCreditBalance: MomentsCreditBalance {
        balanceSubject.value
    }

    var isConfigured: Bool {
        true
    }

    var activeWorkspacePublisher: AnyPublisher<MomentWorkspace?, Never> {
        workspaceSubject.eraseToAnyPublisher()
    }

    var workspaceErrorPublisher: AnyPublisher<String?, Never> {
        workspaceErrorSubject.eraseToAnyPublisher()
    }

    func currentBearerToken() async throws -> String? {
        "token-1"
    }

    func createMoment(ownerUserId: String, form: MomentSetupForm) async throws -> String {
        createAttemptExpectation.fulfill()
        throw creationError
    }

    func deleteMoment(ownerUserId: String, momentId: String) async throws {}

    func observeWorkspace(ownerUserId: String?, momentId: String?) {}

    func clearWorkspace() {
        workspaceSubject.send(nil)
    }

    func saveMediaAsset(
        ownerUserId: String,
        momentId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload
    ) async throws -> String {
        media.id.uuidString
    }

    func saveMediaAssets(
        ownerUserId: String,
        momentId: String,
        mediaAssets: [MediaAssetPersistenceRequest]
    ) async throws -> [String] {
        mediaAssets.map(\.platformMediaAssetId)
    }

    func saveStoryPlan(
        ownerUserId: String,
        momentId: String,
        plan: MomentsStoryPlanResponse,
        storyInputSignature: String
    ) async throws {}

    func updateRenderJobStatus(
        ownerUserId: String,
        renderJobId: String,
        status: String,
        phase: String?,
        progressPercent: Int?,
        userMessage: String?,
        canEditSetup: Bool?,
        canRetry: Bool?,
        errorCode: String?,
        errorMessage: String?
    ) async throws {}

    func savePreviewResult(
        ownerUserId: String,
        momentId: String,
        preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) async throws {}

    func saveStartedFinalRender(
        ownerUserId: String,
        momentId: String,
        reservationId: String,
        startedWorkflow: MomentsStartWorkflowResponse
    ) async throws -> String {
        "render-job-1"
    }

    func saveFinalRenderResult(
        ownerUserId: String,
        momentId: String,
        finalRender: MomentsFinalRenderResponse,
        template: MomentTemplate
    ) async throws {}
}

private struct TestGalleryStore: MomentsGalleryStoring {
    func loadRecords() -> [MomentsGalleryVideoRecord] { [] }
    func saveRecords(_ records: [MomentsGalleryVideoRecord]) {}
    func localFileExists(for record: MomentsGalleryVideoRecord) -> Bool { false }
    func localFileURL(for record: MomentsGalleryVideoRecord) -> URL { URL(fileURLWithPath: "/tmp/\(record.id).mp4") }
    func contains(artifactId: String) -> Bool { false }
    func saveDownloadedVideo(
        temporaryFileURL: URL,
        momentId: String,
        artifactId: String,
        title: String,
        r2Key: String,
        createdAt: Date
    ) throws -> MomentsGalleryVideoRecord {
        MomentsGalleryVideoRecord(
            id: artifactId,
            momentId: momentId,
            artifactId: artifactId,
            title: title,
            r2Key: r2Key,
            localRelativePath: "\(artifactId).mp4",
            createdAt: createdAt.timeIntervalSince1970 * 1000
        )
    }
    func addRecord(_ record: MomentsGalleryVideoRecord) {}
    func deleteRecord(_ record: MomentsGalleryVideoRecord, deleteLocalFile: Bool) {}
}
