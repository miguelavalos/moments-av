import Foundation

struct MomentsUploadClient: Sendable {
    var baseURLString: String
    var session: URLSession = .shared
    var uploadRetryPolicy = MomentsUploadRetryPolicy()
    var networkRetryPolicy = MomentsNetworkRetryPolicy()

    var isConfigured: Bool {
        URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func prepareUpload(momentId: String, bearerToken: String, media: MomentsSelectedMedia) async throws -> MomentsPreparedUpload {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsUploadError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("media")
            .appendingPathComponent("prepare-upload")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(MomentsPrepareUploadRequest(momentId: momentId, media: media))

        let (data, response) = try await retryingData(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_upload_prepare_failed",
                fallbackMessage: MomentsUploadError.prepareFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsPreparedUpload.self, from: data)
    }

    func upload(media: MomentsSelectedMedia, preparedUpload: MomentsPreparedUpload) async throws -> MomentsUploadCompletion {
        guard let uploadURL = preparedUpload.uploadUrl else {
            throw MomentsUploadError.signedUploadUnavailable
        }

        var request = URLRequest(url: uploadURL)
        request.httpMethod = preparedUpload.method
        request.timeoutInterval = 45
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.networkServiceType = .responsiveData
        preparedUpload.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let completionUrl = preparedUpload.completionUrl {
            _ = try await uploadWithRetry(request: request, data: media.data)
            return try await completeUpload(uploadId: preparedUpload.uploadId, completionUrl: completionUrl)
        }

        let uploadResponseData = try await uploadWithRetry(request: request, data: media.data)
        return try JSONDecoder().decode(MomentsUploadCompletion.self, from: uploadResponseData)
    }

    private func completeUpload(uploadId: String, completionUrl: URL) async throws -> MomentsUploadCompletion {
        var request = URLRequest(url: completionUrl)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let (data, response) = try await retryingData(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_upload_complete_failed",
                fallbackMessage: MomentsUploadError.uploadFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsUploadCompletion.self, from: data)
    }

    private func uploadWithRetry(request: URLRequest, data: Data) async throws -> Data {
        var attempt = 0

        while true {
            do {
                let (responseData, response) = try await session.upload(for: request, from: data)
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw MomentsAPIError.decode(
                        from: responseData,
                        fallbackCode: "moments_upload_failed",
                        fallbackMessage: MomentsUploadError.uploadFailed.localizedDescription
                    )
                }
                return responseData
            } catch {
                guard uploadRetryPolicy.shouldRetry(error: error, attempt: attempt) else {
                    throw error
                }

                attempt += 1
                try await Task.sleep(nanoseconds: uploadRetryPolicy.delayNanoseconds(forAttempt: attempt))
            }
        }
    }

    private func retryingData(for request: URLRequest) async throws -> (Data, URLResponse) {
        var attempt = 0

        while true {
            do {
                return try await session.data(for: request)
            } catch {
                guard networkRetryPolicy.shouldRetry(error: error, attempt: attempt) else {
                    throw error
                }

                attempt += 1
                try await Task.sleep(nanoseconds: networkRetryPolicy.delayNanoseconds(forAttempt: attempt))
            }
        }
    }
}

struct MomentsUploadRetryPolicy: Sendable {
    var maximumRetries = 3
    var baseDelayNanoseconds: UInt64 = 300_000_000

    func shouldRetry(error: Error, attempt: Int) -> Bool {
        guard attempt < maximumRetries else { return false }

        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else { return false }

        switch nsError.code {
        case NSURLErrorNetworkConnectionLost,
             NSURLErrorTimedOut,
             NSURLErrorCannotConnectToHost,
             NSURLErrorCannotFindHost,
             NSURLErrorDNSLookupFailed,
             NSURLErrorNotConnectedToInternet:
            return true
        default:
            return false
        }
    }

    func delayNanoseconds(forAttempt attempt: Int) -> UInt64 {
        baseDelayNanoseconds * UInt64(1 << max(attempt - 1, 0))
    }
}

private struct MomentsPrepareUploadRequest: Encodable {
    let appId = "momentsav"
    let momentId: String
    let mediaKind: String
    let sourceLocalIdentifier: String
    let originalFilename: String
    let contentType: String
    let byteSize: Int
    let sha256: String

    init(momentId: String, media: MomentsSelectedMedia) {
        self.momentId = momentId
        mediaKind = media.kind
        sourceLocalIdentifier = media.sourceLocalIdentifier
        originalFilename = media.originalFilename
        contentType = media.contentType
        byteSize = media.byteSize
        sha256 = media.sha256
    }
}

enum MomentsUploadError: LocalizedError {
    case unreadableSelection
    case apiNotConfigured
    case prepareFailed
    case signedUploadUnavailable
    case uploadFailed
    case photoLibraryAccessDenied

    var errorDescription: String? {
        switch self {
        case .unreadableSelection: "The selected item could not be read."
        case .apiNotConfigured: "Media upload preparation is not configured for this build."
        case .prepareFailed: "Upload preparation failed."
        case .signedUploadUnavailable: "Signed upload storage is not enabled for this build."
        case .uploadFailed: "Media upload failed."
        case .photoLibraryAccessDenied: "Allow Photos access to import recent photos."
        }
    }
}
