import Foundation

struct MomentsUploadClient {
    var baseURLString: String
    var session: URLSession = .shared

    var isConfigured: Bool {
        URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func prepareUpload(projectId: String, ownerUserId: String, media: MomentsSelectedMedia) async throws -> MomentsPreparedUpload {
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
        request.setValue("Bearer \(ownerUserId)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(MomentsPrepareUploadRequest(projectId: projectId, media: media))

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_upload_prepare_failed",
                fallbackMessage: MomentsUploadError.prepareFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsPreparedUpload.self, from: data)
    }

    func upload(media: MomentsSelectedMedia, preparedUpload: MomentsPreparedUpload) async throws {
        guard let uploadURL = preparedUpload.uploadUrl else {
            throw MomentsUploadError.signedUploadUnavailable
        }

        var request = URLRequest(url: uploadURL)
        request.httpMethod = preparedUpload.method
        preparedUpload.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (_, response) = try await session.upload(for: request, from: media.data)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsUploadError.uploadFailed
        }
    }
}

private struct MomentsPrepareUploadRequest: Encodable {
    let appId = "momentsav"
    let projectId: String
    let mediaKind: String
    let sourceLocalIdentifier: String
    let originalFilename: String
    let contentType: String
    let byteSize: Int
    let sha256: String

    init(projectId: String, media: MomentsSelectedMedia) {
        self.projectId = projectId
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

    var errorDescription: String? {
        switch self {
        case .unreadableSelection: "The selected item could not be read."
        case .apiNotConfigured: "Media upload preparation is not configured for this build."
        case .prepareFailed: "Upload preparation failed."
        case .signedUploadUnavailable: "Signed upload storage is not enabled for this build."
        case .uploadFailed: "Media upload failed."
        }
    }
}
