import Foundation
import XCTest
@testable import MomentsAV

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
            capturedAt: nil,
            sortOrder: 0,
            selected: true
        )

        _ = try await client.prepareUpload(projectId: "project-1", bearerToken: "token-1", media: media)

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/media/prepare-upload")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
    }

    func testPrepareUploadRetriesTransientNetworkLoss() async throws {
        MomentsURLProtocolMock.failuresBeforeSuccess = 1
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
        let client = MomentsUploadClient(
            baseURLString: accountAPIBaseURL,
            session: session,
            networkRetryPolicy: MomentsNetworkRetryPolicy(maximumRetries: 1, baseDelayNanoseconds: 1)
        )
        let media = MomentsSelectedMedia(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
            sourceLocalIdentifier: "local-1",
            originalFilename: "photo.jpg",
            contentType: "image/jpeg",
            kind: "photo",
            byteSize: 4,
            sha256: "abcd",
            data: Data([1, 2, 3, 4]),
            capturedAt: nil,
            sortOrder: 0,
            selected: true
        )

        _ = try await client.prepareUpload(projectId: "project-1", bearerToken: "token-1", media: media)

        XCTAssertEqual(MomentsURLProtocolMock.requestCount, 2)
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
            capturedAt: nil,
            sortOrder: 0,
            selected: true
        )
        let prepared = MomentsPreparedUpload(
            appId: "momentsav",
            projectId: "project-1",
            mediaAssetId: "media-1",
            uploadId: "upload-1",
            uploadUrl: uploadURL,
            completionUrl: nil,
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
        XCTAssertNil(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "x-appsav-moments-project-id"), "project-1")
    }

    func testUploadWithoutSignedURLFailsBeforeSavingMedia() async throws {
        let session = makeMockSession(json: "{}")
        let client = MomentsUploadClient(baseURLString: accountAPIBaseURL, session: session)
        let media = MomentsSelectedMedia(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
            sourceLocalIdentifier: "local-1",
            originalFilename: "photo.jpg",
            contentType: "image/jpeg",
            kind: "photo",
            byteSize: 4,
            sha256: "abcd",
            data: Data([1, 2, 3, 4]),
            capturedAt: nil,
            sortOrder: 0,
            selected: true
        )
        let prepared = MomentsPreparedUpload(
            appId: "momentsav",
            projectId: "project-1",
            mediaAssetId: "media-1",
            uploadId: "upload-1",
            uploadUrl: nil,
            completionUrl: nil,
            method: "PUT",
            headers: ["content-type": "image/jpeg"],
            storageKey: "momentsav/user/project/source/media-1",
            expiresAt: "2026-05-16T17:00:00Z",
            generatedAt: "2026-05-16T16:00:00Z"
        )

        do {
            try await client.upload(media: media, preparedUpload: prepared)
            XCTFail("Expected missing upload URL to fail.")
        } catch MomentsUploadError.signedUploadUnavailable {
            XCTAssertEqual(MomentsURLProtocolMock.requestCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDirectUploadCompletesPreparedUploadAfterR2Put() async throws {
        let session = makeMockSession(json: "{}")
        let client = MomentsUploadClient(baseURLString: accountAPIBaseURL, session: session)
        let uploadURL = URL(string: "https://account-1.r2.cloudflarestorage.com/appsav-assets-preview/momentsav/user/project/source/media-1?X-Amz-Signature=test")!
        let completionURL = URL(string: "\(accountAPIBaseURL)/v1/apps/momentsav/uploads/upload-1/complete")!
        let media = MomentsSelectedMedia(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            sourceLocalIdentifier: "local-1",
            originalFilename: "photo.jpg",
            contentType: "image/jpeg",
            kind: "photo",
            byteSize: 4,
            sha256: "abcd",
            data: Data([1, 2, 3, 4]),
            capturedAt: nil,
            sortOrder: 0,
            selected: true
        )
        let prepared = MomentsPreparedUpload(
            appId: "momentsav",
            projectId: "project-1",
            mediaAssetId: "media-1",
            uploadId: "upload-1",
            uploadUrl: uploadURL,
            completionUrl: completionURL,
            method: "PUT",
            headers: [
                "content-type": "image/jpeg",
                "x-amz-meta-upload-id": "upload-1"
            ],
            storageKey: "momentsav/user/project/source/media-1",
            expiresAt: "2026-05-16T17:00:00Z",
            generatedAt: "2026-05-16T16:00:00Z"
        )

        try await client.upload(media: media, preparedUpload: prepared)

        XCTAssertEqual(MomentsURLProtocolMock.requestCount, 2)
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, completionURL.absoluteString)
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "POST")
    }

    func testUploadRetriesTransientNetworkLoss() async throws {
        MomentsURLProtocolMock.failuresBeforeSuccess = 1
        let session = makeMockSession(json: "{}")
        let client = MomentsUploadClient(
            baseURLString: accountAPIBaseURL,
            session: session,
            uploadRetryPolicy: MomentsUploadRetryPolicy(maximumRetries: 1, baseDelayNanoseconds: 1)
        )
        let uploadURL = URL(string: "\(accountAPIBaseURL)/v1/apps/momentsav/uploads/upload-1")!
        let media = MomentsSelectedMedia(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            sourceLocalIdentifier: "local-1",
            originalFilename: "photo.jpg",
            contentType: "image/jpeg",
            kind: "photo",
            byteSize: 4,
            sha256: "abcd",
            data: Data([1, 2, 3, 4]),
            capturedAt: nil,
            sortOrder: 0,
            selected: true
        )
        let prepared = MomentsPreparedUpload(
            appId: "momentsav",
            projectId: "project-1",
            mediaAssetId: "media-1",
            uploadId: "upload-1",
            uploadUrl: uploadURL,
            completionUrl: nil,
            method: "PUT",
            headers: ["content-type": "image/jpeg"],
            storageKey: "momentsav/user/project/source/media-1",
            expiresAt: "2026-05-16T17:00:00Z",
            generatedAt: "2026-05-16T16:00:00Z"
        )

        try await client.upload(media: media, preparedUpload: prepared)

        XCTAssertEqual(MomentsURLProtocolMock.requestCount, 2)
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
            bearerToken: "token-1",
            form: MomentDraftForm(template: .birthdayMessage),
            mediaAssets: []
        )

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/story/drafts")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
    }

    func testStoryDraftRetriesTransientNetworkLoss() async throws {
        MomentsURLProtocolMock.failuresBeforeSuccess = 1
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
        let client = MomentsStoryClient(
            baseURLString: accountAPIBaseURL,
            session: session,
            retryPolicy: MomentsNetworkRetryPolicy(maximumRetries: 1, baseDelayNanoseconds: 1)
        )

        _ = try await client.generateDraft(
            projectId: "project-1",
            ownerUserId: "user-1",
            bearerToken: "token-1",
            form: MomentDraftForm(template: .birthdayMessage),
            mediaAssets: []
        )

        XCTAssertEqual(MomentsURLProtocolMock.requestCount, 2)
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
            bearerToken: "token-1",
            template: .birthdayMessage,
            previewIndex: 0
        )

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/previews/generate")
        XCTAssertEqual(preview.provider, "mock")
        XCTAssertEqual(preview.model, "mock-preview-route")
    }

    func testPreviewGenerationRetriesTransientNetworkLoss() async throws {
        MomentsURLProtocolMock.failuresBeforeSuccess = 1
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
        let client = MomentsPreviewClient(
            baseURLString: accountAPIBaseURL,
            session: session,
            retryPolicy: MomentsNetworkRetryPolicy(maximumRetries: 1, baseDelayNanoseconds: 1)
        )

        _ = try await client.generatePreview(
            projectId: "project-1",
            bearerToken: "token-1",
            template: .birthdayMessage,
            previewIndex: 0
        )

        XCTAssertEqual(MomentsURLProtocolMock.requestCount, 2)
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
                bearerToken: "token-1",
                template: .birthdayMessage,
                previewIndex: 0
            )
            XCTFail("Expected API error")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Not enough spendable Moments AV credits.")
        }
    }

    func testFinalRenderReservationUsesSharedAccountAPIBaseURL() async throws {
        let session = makeMockSession(
            json: """
            {
              "id": "reservation-1",
              "appId": "momentsav",
              "projectId": "project-1",
              "amount": 2,
              "status": "reserved",
              "expiresAt": "2026-06-16T16:00:00Z",
              "createdAt": "2026-05-16T16:00:00Z",
              "updatedAt": "2026-05-16T16:00:00Z"
            }
            """
        )
        let client = MomentsFinalRenderClient(baseURLString: accountAPIBaseURL, session: session)

        let reservation = try await client.reserveFinalRenderCredits(
            projectId: "project-1",
            bearerToken: "token-1",
            template: .birthdayMessage,
            removesWatermark: false,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 2, purchased: 0),
            operationId: "operation-1"
        )

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/credits/reservations")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "POST")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
        XCTAssertEqual(reservation.id, "reservation-1")
        XCTAssertEqual(reservation.status, "reserved")
    }

    func testFinalRenderStartWorkflowUsesAsyncEndpoint() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "projectId": "project-1",
              "renderJobId": "render-1",
              "workflowRunId": "workflow-1",
              "status": "running",
              "startedAt": "2026-05-16T16:00:00Z"
            }
            """
        )
        let client = MomentsFinalRenderClient(baseURLString: accountAPIBaseURL, session: session)

        let workflow = try await client.startFinalRenderWorkflow(
            projectId: "project-1",
            bearerToken: "token-1",
            template: .birthdayMessage,
            creationStyle: nil,
            form: MomentDraftForm(template: .birthdayMessage),
            removesWatermark: false,
            reservationId: "reservation-1",
            operationId: "operation-1"
        )

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/workflows/start")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "POST")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
        XCTAssertEqual(workflow.renderJobId, "render-1")
        XCTAssertEqual(workflow.status, "running")
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
            _ = try await client.startFinalRenderWorkflow(
                projectId: "project-1",
                bearerToken: "token-1",
                template: .birthdayMessage,
                creationStyle: nil,
                form: MomentDraftForm(template: .birthdayMessage),
                removesWatermark: false,
                reservationId: "reservation-1",
                operationId: "operation-1"
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

        let status = try await client.fetchStatus(renderJobId: "render-1", bearerToken: "token-1")

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/renders/render-1/status")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "GET")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
        XCTAssertEqual(status.status, "running")
        XCTAssertEqual(status.progressPercent, 25)
    }

    func testRenderStatusReconcileUsesAsyncFinalEndpoint() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "projectId": "project-1",
              "renderJobId": "render-1",
              "workflowRunId": "workflow-1",
              "renderKind": "final",
              "status": "running",
              "progressPercent": 45,
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

        let status = try await client.reconcileFinalRender(renderJobId: "render-1", bearerToken: "token-1")

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/renders/render-1/reconcile")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "POST")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
        XCTAssertEqual(status.renderKind, "final")
        XCTAssertEqual(status.status, "running")
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
            _ = try await client.fetchStatus(renderJobId: "missing-render", bearerToken: "token-1")
            XCTFail("Expected API error")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Render job was not found.")
        }
    }

    func testCreditBalanceUsesBackendBucketsAndBearerToken() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "userId": "user-1",
              "spendableCredits": 10,
              "reservedCredits": 0,
              "proMonthlyCredits": 0,
              "promotionalGrantedCredits": 10,
              "purchasedCredits": 0,
              "hasProFeatures": true,
              "proSource": "promo",
              "proExpiresAt": "2026-06-25T00:00:00.000Z",
              "canStartProject": true,
              "minimumRenderCredits": 1,
              "generatedAt": "2026-05-26T10:00:00.000Z"
            }
            """
        )
        let client = MomentsCreditBalanceClient(baseURLString: accountAPIBaseURL, session: session)

        let balance = try await client.fetchBalance(bearerToken: "token-1")

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/credits/balance")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "GET")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
        XCTAssertEqual(balance, MomentsCreditBalance(proMonthly: 0, promotional: 10, purchased: 0))
    }

    func testPromoCodeRedeemUsesBackendAndReturnsUpdatedBalance() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "userId": "user-1",
              "code": "MOMENTS-DEMO-2026",
              "campaignId": "demo_credit_flow",
              "creditsGranted": 5,
              "redemptionId": "promo-redemption-1",
              "ledgerEntryId": "promo-ledger-1",
              "balance": {
                "appId": "momentsav",
                "userId": "user-1",
                "spendableCredits": 5,
                "reservedCredits": 0,
                "proMonthlyCredits": 0,
                "promotionalGrantedCredits": 5,
                "purchasedCredits": 0,
                "hasProFeatures": false,
                "proSource": "none",
                "proExpiresAt": null,
                "canStartProject": true,
                "minimumRenderCredits": 1,
                "generatedAt": "2026-05-27T10:00:00.000Z"
              },
              "generatedAt": "2026-05-27T10:00:00.000Z"
            }
            """
        )
        let client = MomentsPromoCodeClient(baseURLString: accountAPIBaseURL, session: session)

        let response = try await client.redeem(code: "MOMENTS-DEMO-2026", bearerToken: "token-1")

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/credits/promotions/redeem")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "POST")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
        XCTAssertEqual(response.creditsGranted, 5)
        XCTAssertEqual(response.balance, MomentsCreditBalance(proMonthly: 0, promotional: 5, purchased: 0))
    }

    func testReviewBundlePurchaseUsesBackendAndReturnsUpdatedBalance() async throws {
        let session = makeMockSession(
            json: """
            {
              "appId": "momentsav",
              "userId": "user-1",
              "reviewsGranted": 10,
              "creditsCommitted": 1,
              "creditLedgerEntryId": "credit-ledger-1",
              "reviewLedgerEntryId": "review-ledger-1",
              "balance": {
                "appId": "momentsav",
                "userId": "user-1",
                "spendableCredits": 4,
                "reservedCredits": 0,
                "proMonthlyCredits": 0,
                "promotionalGrantedCredits": 4,
                "purchasedCredits": 0,
                "hasProFeatures": false,
                "proSource": "none",
                "proExpiresAt": null,
                "reviewAllowanceRemaining": 10,
                "includedReviewsRemaining": 10,
                "canReview": true,
                "canCreateDirectly": true,
                "canBuyReviewBundle": true,
                "reviewBundleCreditCost": 1,
                "reviewBundleReviewCount": 2,
                "watermarkRemovalCreditCost": 1,
                "watermarkFreeIncluded": false,
                "canStartProject": true,
                "minimumRenderCredits": 1,
                "generatedAt": "2026-05-29T10:00:00.000Z"
              },
              "generatedAt": "2026-05-29T10:00:00.000Z"
            }
            """
        )
        let client = MomentsReviewBundleClient(baseURLString: accountAPIBaseURL, session: session)

        let response = try await client.purchase(bearerToken: "token-1")

        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.url?.absoluteString, "\(accountAPIBaseURL)/v1/apps/momentsav/credits/review-bundles")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.httpMethod, "POST")
        XCTAssertEqual(MomentsURLProtocolMock.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
        XCTAssertEqual(response.reviewsGranted, 10)
        XCTAssertEqual(response.creditsCommitted, 1)
        XCTAssertEqual(response.balance.reviewAllowanceRemaining, 10)
        XCTAssertEqual(response.balance.spendable, 4)
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
    nonisolated(unsafe) static var requestCount = 0
    nonisolated(unsafe) static var failuresBeforeSuccess = 0

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lastRequest = request
        Self.requestCount += 1
        if Self.failuresBeforeSuccess > 0 {
            Self.failuresBeforeSuccess -= 1
            client?.urlProtocol(self, didFailWithError: URLError(.networkConnectionLost))
            return
        }
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
        requestCount = 0
        failuresBeforeSuccess = 0
    }
}
