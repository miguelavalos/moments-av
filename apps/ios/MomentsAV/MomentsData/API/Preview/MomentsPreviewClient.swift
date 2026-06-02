import Foundation

struct MomentsPreviewClient {
    var baseURLString: String
    var session: URLSession = .shared
    var retryPolicy = MomentsNetworkRetryPolicy()

    var isConfigured: Bool {
        URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func generatePreview(
        momentId: String,
        bearerToken: String,
        template: MomentTemplate,
        form: MomentSetupForm,
        previewIndex: Int
    ) async throws -> MomentsPreviewResponse {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsPreviewError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("previews")
            .appendingPathComponent("generate")
        let body = MomentsPreviewRequest(
            momentId: momentId,
            creationMode: form.creationMode.rawValue,
            look: form.look.rawValue,
            theme: form.theme.rawValue,
            mood: form.tone.rawValue,
            duration: form.duration.rawValue,
            mediaUse: form.mediaUse.rawValue,
            idempotencyKey: "preview:\(momentId):\(previewIndex)"
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await retryingData(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_preview_failed",
                fallbackMessage: MomentsPreviewError.generationFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsPreviewResponse.self, from: data)
    }

    private func retryingData(for request: URLRequest) async throws -> (Data, URLResponse) {
        var attempt = 0

        while true {
            do {
                return try await session.data(for: request)
            } catch {
                guard retryPolicy.shouldRetry(error: error, attempt: attempt) else {
                    throw error
                }

                attempt += 1
                try await Task.sleep(nanoseconds: retryPolicy.delayNanoseconds(forAttempt: attempt))
            }
        }
    }
}

enum MomentsPreviewError: LocalizedError {
    case apiNotConfigured
    case generationFailed

    var errorDescription: String? {
        switch self {
        case .apiNotConfigured: "Avi's Cut is not configured for this build."
        case .generationFailed: "Avi's Cut failed."
        }
    }
}
