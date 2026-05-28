import Foundation

struct MomentsFinalRenderClient {
    var baseURLString: String
    var session: URLSession = .shared

    var isConfigured: Bool {
        URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func generateFinalRender(
        projectId: String,
        bearerToken: String,
        template: MomentTemplate
    ) async throws -> MomentsFinalRenderResponse {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsFinalRenderError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("final-renders")
            .appendingPathComponent("generate")
        let body = MomentsFinalRenderRequest(
            projectId: projectId,
            template: template.id.rawValue,
            creditCost: template.creditCost,
            idempotencyKey: "final:\(projectId)"
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_final_render_failed",
                fallbackMessage: MomentsFinalRenderError.generationFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsFinalRenderResponse.self, from: data)
    }
}

enum MomentsFinalRenderError: LocalizedError {
    case apiNotConfigured
    case generationFailed

    var errorDescription: String? {
        switch self {
        case .apiNotConfigured: "Final render is not configured for this build."
        case .generationFailed: "Final render failed before delivery. Credits were not committed unless an export was delivered."
        }
    }
}
