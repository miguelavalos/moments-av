import Foundation

struct MomentsPreviewClient {
    var baseURLString: String
    var session: URLSession = .shared

    var isConfigured: Bool {
        URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func generatePreview(
        projectId: String,
        ownerUserId: String,
        template: MomentTemplate,
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
            projectId: projectId,
            template: template.id.rawValue,
            creditCost: template.creditCost,
            idempotencyKey: "preview:\(projectId):\(previewIndex)"
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ownerUserId)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_preview_failed",
                fallbackMessage: MomentsPreviewError.generationFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsPreviewResponse.self, from: data)
    }
}

enum MomentsPreviewError: LocalizedError {
    case apiNotConfigured
    case generationFailed

    var errorDescription: String? {
        switch self {
        case .apiNotConfigured: "Preview generation is not configured for this build."
        case .generationFailed: "Preview generation failed."
        }
    }
}
