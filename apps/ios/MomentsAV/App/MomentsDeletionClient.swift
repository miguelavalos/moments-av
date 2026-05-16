import Foundation

struct MomentsDeletionRequest: Encodable {
    let appId = "momentsav"
    let projectId: String
    let deleteSourceMedia = true
    let deleteGeneratedArtifacts = true
    let reason: String
}

struct MomentsDeletionResponse: Decodable, Equatable {
    let appId: String
    let projectId: String
    let status: String
    let requestedAt: String
}

struct MomentsDeletionClient {
    var baseURLString: String
    var session: URLSession = .shared

    var isConfigured: Bool {
        URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func deleteProject(projectId: String, ownerUserId: String) async throws -> MomentsDeletionResponse {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsDeletionError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("deletions")
        let body = MomentsDeletionRequest(projectId: projectId, reason: "user requested project deletion")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ownerUserId)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsDeletionError.deletionFailed
        }

        return try JSONDecoder().decode(MomentsDeletionResponse.self, from: data)
    }
}

enum MomentsDeletionError: LocalizedError {
    case apiNotConfigured
    case deletionFailed

    var errorDescription: String? {
        switch self {
        case .apiNotConfigured: "Project deletion is not configured for this build."
        case .deletionFailed: "Project deletion could not be requested."
        }
    }
}
