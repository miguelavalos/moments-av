import Foundation

struct MomentsNetworkRetryPolicy: Sendable {
    var maximumRetries = 2
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

    func run<T>(_ operation: () async throws -> T) async throws -> T {
        var attempt = 0

        while true {
            do {
                return try await operation()
            } catch {
                guard shouldRetry(error: error, attempt: attempt) else {
                    throw error
                }

                attempt += 1
                try await Task.sleep(nanoseconds: delayNanoseconds(forAttempt: attempt))
            }
        }
    }
}

struct MomentsFinalRenderClient {
    var baseURLString: String
    var session: URLSession = .shared
    var retryPolicy = MomentsNetworkRetryPolicy()

    var isConfigured: Bool {
        URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func generateFinalRender(
        momentId: String,
        bearerToken: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentSetupForm
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
            momentId: momentId,
            creationMode: form.creationMode.rawValue,
            look: form.look.rawValue,
            theme: form.theme.rawValue,
            mood: form.tone.rawValue,
            duration: form.duration.rawValue,
            mediaUse: form.mediaUse.rawValue,
            occasion: form.occasion,
            details: form.details,
            creditCost: template.creditCost,
            removeWatermark: false,
            idempotencyKey: "final:\(momentId)"
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await retryPolicy.run {
            try await session.data(for: request)
        }
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_final_render_failed",
                fallbackMessage: MomentsFinalRenderError.generationFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsFinalRenderResponse.self, from: data)
    }

    func reserveFinalRenderCredits(
        momentId: String,
        bearerToken: String,
        template: MomentTemplate,
        removesWatermark: Bool,
        balance: MomentsCreditBalance,
        operationId: String
    ) async throws -> MomentsCreditReservationResponse {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsFinalRenderError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("credits")
            .appendingPathComponent("reservations")
        let body = MomentsCreditReservationRequest(
            momentId: momentId,
            amount: finalRenderCreditCost(template: template, removesWatermark: removesWatermark, balance: balance),
            idempotencyKey: "final-reservation:\(momentId):\(template.id.rawValue):\(removesWatermark ? "clean" : "watermarked"):\(operationId)"
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await retryPolicy.run {
            try await session.data(for: request)
        }
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_credit_reservation_failed",
                fallbackMessage: MomentsFinalRenderError.reservationFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsCreditReservationResponse.self, from: data)
    }

    func prepareRenderPlan(
        momentId: String,
        bearerToken: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentSetupForm,
        removesWatermark: Bool
    ) async throws -> MomentsRenderPlanResponse {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsFinalRenderError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("renders")
            .appendingPathComponent("plan")
        let body = MomentsRenderPlanRequest(
            momentId: momentId,
            creationMode: form.creationMode.rawValue,
            look: form.look.rawValue,
            theme: form.theme.rawValue,
            mood: form.tone.rawValue,
            duration: form.duration.rawValue,
            mediaUse: form.mediaUse.rawValue,
            occasion: form.occasion,
            details: form.details,
            creditCost: template.creditCost,
            removeWatermark: removesWatermark,
            renderOptionId: nil
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await retryPolicy.run {
            try await session.data(for: request)
        }
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_render_plan_failed",
                fallbackMessage: MomentsFinalRenderError.planFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsRenderPlanResponse.self, from: data)
    }

    func confirmFinalRender(
        momentId: String,
        bearerToken: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentSetupForm,
        removesWatermark: Bool,
        planId: String,
        renderOptionId: String?,
        operationId: String
    ) async throws -> MomentsConfirmFinalRenderResponse {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsFinalRenderError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("renders")
            .appendingPathComponent("final")
            .appendingPathComponent("confirm")
        let body = MomentsConfirmFinalRenderRequest(
            momentId: momentId,
            creationMode: form.creationMode.rawValue,
            look: form.look.rawValue,
            theme: form.theme.rawValue,
            mood: form.tone.rawValue,
            duration: form.duration.rawValue,
            mediaUse: form.mediaUse.rawValue,
            occasion: form.occasion,
            details: form.details,
            creditCost: template.creditCost,
            removeWatermark: removesWatermark,
            renderOptionId: renderOptionId,
            planId: planId,
            idempotencyKey: "final-confirm:\(momentId):\(template.id.rawValue):\(removesWatermark ? "clean" : "watermarked"):\(operationId)"
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await retryPolicy.run {
            try await session.data(for: request)
        }
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_final_render_confirm_failed",
                fallbackMessage: MomentsFinalRenderError.generationFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsConfirmFinalRenderResponse.self, from: data)
    }

    func startFinalRenderWorkflow(
        momentId: String,
        bearerToken: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentSetupForm,
        removesWatermark: Bool,
        reservationId: String,
        operationId: String
    ) async throws -> MomentsStartWorkflowResponse {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsFinalRenderError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("workflows")
            .appendingPathComponent("start")
        let body = MomentsStartWorkflowRequest(
            momentId: momentId,
            renderKind: "final",
            creationMode: form.creationMode.rawValue,
            look: form.look.rawValue,
            theme: form.theme.rawValue,
            mood: form.tone.rawValue,
            duration: form.duration.rawValue,
            mediaUse: form.mediaUse.rawValue,
            occasion: form.occasion,
            details: form.details,
            creditCost: template.creditCost,
            removeWatermark: removesWatermark,
            idempotencyKey: "final-workflow:\(momentId):\(template.id.rawValue):\(operationId)",
            reservationId: reservationId,
            renderOptionId: nil
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await retryPolicy.run {
            try await session.data(for: request)
        }
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_final_render_failed",
                fallbackMessage: MomentsFinalRenderError.generationFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsStartWorkflowResponse.self, from: data)
    }

    func prepareFinalArtifactDownload(
        momentId: String,
        artifactId: String,
        bearerToken: String
    ) async throws -> MomentsArtifactDownloadResponse {
        guard let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw MomentsFinalRenderError.apiNotConfigured
        }

        let endpoint = baseURL
            .appendingPathComponent("v1")
            .appendingPathComponent("apps")
            .appendingPathComponent("momentsav")
            .appendingPathComponent("artifacts")
            .appendingPathComponent(artifactId)
            .appendingPathComponent("download")
        let body = MomentsArtifactDownloadRequest(
            momentId: momentId,
            artifactId: artifactId
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await retryPolicy.run {
            try await session.data(for: request)
        }
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsAPIError.decode(
                from: data,
                fallbackCode: "moments_artifact_download_failed",
                fallbackMessage: MomentsFinalRenderError.downloadPreparationFailed.localizedDescription
            )
        }

        return try JSONDecoder().decode(MomentsArtifactDownloadResponse.self, from: data)
    }

    func downloadFinalArtifact(from response: MomentsArtifactDownloadResponse) async throws -> URL {
        guard let downloadURL = URL(string: response.downloadUrl) else {
            throw MomentsFinalRenderError.downloadPreparationFailed
        }

        var request = URLRequest(url: downloadURL)
        request.httpMethod = response.method
        response.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (fileURL, urlResponse) = try await retryPolicy.run {
            try await session.download(for: request)
        }
        guard let httpResponse = urlResponse as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MomentsFinalRenderError.downloadFailed
        }

        return fileURL
    }

    private func finalRenderCreditCost(
        template: MomentTemplate,
        removesWatermark: Bool,
        balance: MomentsCreditBalance
    ) -> Int {
        MomentsCreditGate.finalRenderCreditCost(
            template: template,
            removesWatermark: removesWatermark,
            balance: balance
        )
    }
}

enum MomentsFinalRenderError: LocalizedError {
    case apiNotConfigured
    case planFailed
    case reservationFailed
    case generationFailed
    case downloadPreparationFailed
    case downloadFailed

    var errorDescription: String? {
        switch self {
        case .apiNotConfigured: "Final render is not configured for this build."
        case .planFailed: "Avi could not prepare the final video plan."
        case .reservationFailed: "Credits could not be reserved for the final video."
        case .generationFailed: "Final render failed before delivery. Credits were not committed unless an export was delivered."
        case .downloadPreparationFailed: "The final video download could not be prepared."
        case .downloadFailed: "The final video could not be downloaded."
        }
    }
}
