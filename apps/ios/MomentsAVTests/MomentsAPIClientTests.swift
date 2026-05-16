import Foundation
import XCTest
@testable import Moments_AV

final class MomentsAPIClientTests: XCTestCase {
    override func tearDown() {
        MomentsURLProtocolMock.reset()
        super.tearDown()
    }

    func testPrepareUploadUsesSharedAccountAPIBaseURL() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "projectId": "project-1",
              "mediaAssetId": "media-1",
              "uploadId": "upload-1",
              "uploadUrl": "https://uploads.example.com/media-1",
              "method": "PUT",
              "headers": { "content-type": "image/jpeg" },
              "storageKey": "momentsav/user/project/source/media-1.jpg",
              "expiresAt": "2026-05-16T17:00:00Z",
              "generatedAt": "2026-05-16T16:00:00Z"
            }
            """
        )
        let client = MomentsUploadClient(baseURLString: accountAPIBaseURL, session: session)
        let media = MomentsSelectedMedia(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            sourceLocalIdentifier: "local-1",
            originalFilename: "photo.jpg",
            contentType: "image/jpeg",
            kind: "photo",
            byteSize: 4,
            sha256: "abcd",
            data: Data([1, 2, 3, 4]),
            sortOrder: 0,
            selected: true
        )

        _ = try await client.prepareUpload(projectId: "project-1", ownerUserId: "user-1", media: media)

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/media/prepare-upload")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer user-1")
    }

    func testUploadUsesPreparedURLAndHeaders() async throws {
        let session = makeMockSession(json: "{}")
        let client = MomentsUploadClient(baseURLString: accountAPIBaseURL, session: session)
        let uploadURL = URL(string: "\(accountAPIBaseURL)/v1/apps/momentsav/uploads/upload-1")!
        let media = MomentsSelectedMedia(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            sourceLocalIdentifier: "local-1",
            originalFilename: "photo.jpg",
            contentType: "image/jpeg",
            kind: "photo",
            byteSize: 4,
            sha256: "abcd",
            data: Data([1, 2, 3, 4]),
            sortOrder: 0,
            selected: true
        )
        let prepared = MomentsPreparedUpload(
            appId: "momentsav",
            projectId: "project-1",
            mediaAssetId: "media-1",
            uploadId: "upload-1",
            uploadUrl: uploadURL,
            method: "PUT",
            headers: [
                "content-type": "image/jpeg",
                "x-appsav-moments-project-id": "project-1",
                "x-appsav-moments-media-asset-id": "media-1"
            ],
            storageKey: "momentsav/user/project/source/media-1",
            expiresAt: "2026-05-16T17:00:00Z",
            generatedAt: "2026-05-16T16:00:00Z"
        )

        try await client.upload(media: media, preparedUpload: prepared)

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, uploadURL.absoluteString)
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "PUT")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "x-appsav-moments-project-id"), "project-1")
    }

    func testStoryDraftUsesSharedAccountAPIBaseURL() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "projectId": "project-1",
              "workflowRunId": "workflow-1",
              "status": "ready",
              "provider": "mock",
              "model": "mock",
              "moderationStatus": "allowed",
              "errorCode": null,
              "errorMessage": null,
              "narrationVoice": "avi_clear",
              "helperCopy": "Ready.",
              "scenes": [],
              "generatedAt": "2026-05-16T16:00:00Z"
            }
            """
        )
        let client = MomentsStoryClient(baseURLString: accountAPIBaseURL, session: session)

        _ = try await client.generateDraft(
            projectId: "project-1",
            ownerUserId: "user-1",
            form: MomentDraftForm(template: .birthdayMessage),
            mediaAssets: []
        )

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/story/drafts")
    }

    func testPreviewGenerationUsesSharedAccountAPIBaseURL() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "projectId": "project-1",
              "renderJobId": "render-1",
              "workflowRunId": "workflow-1",
              "artifactId": "artifact-1",
              "artifactKind": "preview",
              "status": "completed",
              "progressPercent": 100,
              "progressState": "ready",
              "r2Key": "momentsav/user/project/previews/preview-1.mp4",
              "expiresAt": "2026-06-16T16:00:00Z",
              "hasWatermark": true,
              "generatedAt": "2026-05-16T16:00:00Z"
            }
            """
        )
        let client = MomentsPreviewClient(baseURLString: accountAPIBaseURL, session: session)

        _ = try await client.generatePreview(
            projectId: "project-1",
            ownerUserId: "user-1",
            template: .birthdayMessage,
            previewIndex: 0
        )

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/previews/generate")
    }

    func testFinalRenderUsesSharedAccountAPIBaseURL() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "projectId": "project-1",
              "renderJobId": "render-1",
              "workflowRunId": "workflow-1",
              "reservationId": "reservation-1",
              "artifactId": "artifact-1",
              "artifactKind": "final_export",
              "status": "completed",
              "progressPercent": 100,
              "r2Key": "momentsav/user/project/final/final-1.mp4",
              "expiresAt": "2026-06-16T16:00:00Z",
              "hasWatermark": false,
              "creditsCommitted": 2,
              "generatedAt": "2026-05-16T16:00:00Z"
            }
            """
        )
        let client = MomentsFinalRenderClient(baseURLString: accountAPIBaseURL, session: session)

        _ = try await client.generateFinalRender(
            projectId: "project-1",
            ownerUserId: "user-1",
            template: .birthdayMessage
        )

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/final-renders/generate")
    }

    func testDeletionUsesSharedAccountAPIBaseURL() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "projectId": "project-1",
              "status": "requested",
              "requestedAt": "2026-05-16T16:00:00Z"
            }
            """
        )
        let client = MomentsDeletionClient(baseURLString: accountAPIBaseURL, session: session)

        _ = try await client.deleteProject(projectId: "project-1", ownerUserId: "user-1")

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/deletions")
    }

    private var accountAPIBaseURL: String {
        "https://api-account-av-preview.avalsys.com"
    }

    private func makeMockSession(json: String) -> URLSession {
        MomentsURLProtocolMock.responseData = Data(json.utf8)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MomentsURLProtocolMock.self]
        return URLSession(configuration: configuration)
    }
}

private final class MomentsURLProtocolMock: URLProtocol {
    nonisolated(unsafe) static var responseData = Data()
    nonisolated(unsafe) static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lastRequest = request
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["content-type": "application/json"]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.responseData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    static func reset() {
        responseData = Data()
        lastRequest = nil
    }
}
