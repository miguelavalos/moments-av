import Foundation

struct MomentsStoryClient {
    var baseURLString: String
    var session: URLSession = .shared

    var isConfigured: Bool {
        URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func generateDraft(
        projectId: String,
        ownerUserId: String,
        form: MomentDraftForm,
        mediaAssets: [MomentMediaAsset]
    ) async throws -> MomentsStoryDraftResponse {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsStoryError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("story")
            .appendingPathComponent("drafts")

        let selectedMedia = mediaAssets
            .filter(\.selected)
            .sorted { left, right in left.sortOrder < right.sortOrder }
            .map {
                MomentsStoryDraftMedia(
                    mediaAssetId: $0.id,
                    mediaKind: $0.kind,
                    sortOrder: Int($0.sortOrder),
                    selected: $0.selected,
                    moderationStatus: $0.moderationStatus
                )
            }
        let requestBody = MomentsStoryDraftRequest(
            projectId: projectId,
            template: form.template.id.rawValue,
            tone: form.tone.rawValue,
            tempo: form.tempo.rawValue,
            occasion: form.occasion,
            details: form.details,
            media: selectedMedia,
            idempotencyKey: "story:\(projectId):\(selectedMedia.count):\(form.tone.rawValue):\(form.tempo.rawValue)"
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ownerUserId)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_story_draft_failed",
                fallbackMessage: MomentsStoryError.draftFailed.localizedDescription
            )
        }

        let draft = try JSONDecoder().decode(MomentsStoryDraftResponse.self, from: data)
        if draft.status == "blocked" {
            throw MomentsStoryError.blocked(draft.errorMessage ?? "Avi needs safer inputs before drafting this story.")
        }
        if draft.status == "provider_failed" {
            throw MomentsStoryError.providerFailed(draft.errorMessage ?? "Story draft failed.")
        }

        return draft
    }
}

enum MomentsStoryError: LocalizedError {
    case apiNotConfigured
    case draftFailed
    case blocked(String)
    case providerFailed(String)

    var errorDescription: String? {
        switch self {
        case .apiNotConfigured: "Story drafting is not configured for this build."
        case .draftFailed: "Story draft request failed."
        case .blocked(let message): message
        case .providerFailed(let message): message
        }
    }
}
