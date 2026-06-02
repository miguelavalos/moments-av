import Foundation

struct MomentsStoryClient {
    var baseURLString: String
    var session: URLSession = .shared
    var retryPolicy = MomentsNetworkRetryPolicy()

    var isConfigured: Bool {
        URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func generateDraft(
        momentId: String,
        ownerUserId: String,
        bearerToken: String,
        form: MomentDraftForm,
        mediaAssets: [MomentMediaAsset]
    ) async throws -> MomentsStoryDraftResponse {
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

        return try await generateDraft(
            momentId: momentId,
            ownerUserId: ownerUserId,
            bearerToken: bearerToken,
            form: form,
            selectedMedia: selectedMedia
        )
    }

    func generateDraft(
        momentId: String,
        ownerUserId: String,
        bearerToken: String,
        form: MomentDraftForm,
        selectedMedia: [MomentsStoryDraftMedia]
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

        let requestBody = MomentsStoryDraftRequest(
            momentId: momentId,
            creationMode: form.creationMode.rawValue,
            look: form.look.rawValue,
            theme: form.theme.rawValue,
            mood: form.tone.rawValue,
            duration: form.duration.rawValue,
            mediaUse: form.mediaUse.rawValue,
            occasion: form.occasion,
            details: form.details,
            media: selectedMedia,
            idempotencyKey: "story:\(momentId):\(MomentsStoryDraftInputSignature.make(momentId: momentId, form: form, selectedMedia: selectedMedia))"
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await retryingData(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            let apiError = MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_story_draft_failed",
                fallbackMessage: MomentsStoryError.draftFailed.localizedDescription
            )
            if apiError.code == "moments_review_allowance_exhausted" {
                throw MomentsStoryError.reviewAllowanceExhausted(apiError.message)
            }
            throw apiError
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

enum MomentsStoryError: LocalizedError {
    case apiNotConfigured
    case draftFailed
    case blocked(String)
    case providerFailed(String)
    case reviewAllowanceExhausted(String)

    var errorDescription: String? {
        switch self {
        case .apiNotConfigured: "Story drafting is not configured for this build."
        case .draftFailed: "Story draft request failed."
        case .blocked(let message): message
        case .providerFailed(let message): message
        case .reviewAllowanceExhausted(let message): message
        }
    }
}
