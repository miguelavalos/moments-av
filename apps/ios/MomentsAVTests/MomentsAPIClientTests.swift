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
              "provider": "mock",
              "model": "mock-preview-route",
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

        let preview = try await client.generatePreview(
            projectId: "project-1",
            ownerUserId: "user-1",
            template: .birthdayMessage,
            previewIndex: 0
        )

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/previews/generate")
        XCTAssertEqual(preview.provider, "mock")
        XCTAssertEqual(preview.model, "mock-preview-route")
    }

    func testPreviewGenerationSurfacesAPIErrorMessage() async throws {
        let session = makeMockSession(
            statusCode: 409,
            json: """
            {
              "error": {
                "code": "insufficient_moments_credits",
                "message": "Not enough spendable Moments AV credits."
              }
            }
            """
        )
        let client = MomentsPreviewClient(baseURLString: accountAPIBaseURL, session: session)

        do {
            _ = try await client.generatePreview(
                projectId: "project-1",
                ownerUserId: "user-1",
                template: .birthdayMessage,
                previewIndex: 0
            )
            XCTFail("Expected API error")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Not enough spendable Moments AV credits.")
        }
    }

    func testFinalRenderUsesSharedAccountAPIBaseURL() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "projectId": "project-1",
              "renderJobId": "render-1",
              "workflowRunId": "workflow-1",
              "provider": "mock",
              "model": "mock-final-route",
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

        let finalRender = try await client.generateFinalRender(
            projectId: "project-1",
            ownerUserId: "user-1",
            template: .birthdayMessage
        )

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/final-renders/generate")
        XCTAssertEqual(finalRender.provider, "mock")
        XCTAssertEqual(finalRender.model, "mock-final-route")
    }

    func testFinalRenderSurfacesProviderFailureMessage() async throws {
        let session = makeMockSession(
            statusCode: 500,
            json: """
            {
              "error": {
                "code": "moments_final_provider_failed",
                "message": "Final render failed before a usable export was delivered."
              }
            }
            """
        )
        let client = MomentsFinalRenderClient(baseURLString: accountAPIBaseURL, session: session)

        do {
            _ = try await client.generateFinalRender(
                projectId: "project-1",
                ownerUserId: "user-1",
                template: .birthdayMessage
            )
            XCTFail("Expected API error")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Final render failed before a usable export was delivered.")
        }
    }

    func testRenderStatusUsesSharedAccountAPIBaseURL() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "projectId": "project-1",
              "renderJobId": "render-1",
              "workflowRunId": "workflow-1",
              "renderKind": "preview",
              "status": "running",
              "progressPercent": 25,
              "artifactId": null,
              "artifactKind": null,
              "artifactStatus": null,
              "errorCode": null,
              "errorMessage": null,
              "updatedAt": "2026-05-16T16:00:00Z"
            }
            """
        )
        let client = MomentsRenderStatusClient(baseURLString: accountAPIBaseURL, session: session)

        let status = try await client.fetchStatus(renderJobId: "render-1", ownerUserId: "user-1")

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/renders/render-1/status")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "GET")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer user-1")
        XCTAssertEqual(status.status, "running")
        XCTAssertEqual(status.progressPercent, 25)
    }

    func testRenderStatusSurfacesAPIErrorMessage() async throws {
        let session = makeMockSession(
            statusCode: 404,
            json: """
            {
              "error": {
                "code": "moments_render_not_found",
                "message": "Render job was not found."
              }
            }
            """
        )
        let client = MomentsRenderStatusClient(baseURLString: accountAPIBaseURL, session: session)

        do {
            _ = try await client.fetchStatus(renderJobId: "missing-render", ownerUserId: "user-1")
            XCTFail("Expected API error")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Render job was not found.")
        }
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

    private func makeMockSession(statusCode: Int = 200, json: String) -> URLSession {
        MomentsURLProtocolMock.statusCode = statusCode
        MomentsURLProtocolMock.responseData = Data(json.utf8)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MomentsURLProtocolMock.self]
        return URLSession(configuration: configuration)
    }
}

private final class MomentsURLProtocolMock: URLProtocol {
    nonisolated(unsafe) static var statusCode = 200
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
            statusCode: Self.statusCode,
            httpVersion: nil,
            headerFields: ["content-type": "application/json"]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.responseData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    static func reset() {
        statusCode = 200
        responseData = Data()
        lastRequest = nil
    }
}
