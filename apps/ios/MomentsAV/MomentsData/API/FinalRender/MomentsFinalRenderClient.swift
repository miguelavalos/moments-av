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
        projectId: String,
        bearerToken: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentDraftForm
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
            creationStyle: creationStyle?.rawValue,
            tone: form.tone.rawValue,
            tempo: form.tempo.rawValue,
            occasion: form.occasion,
            details: form.details,
            creditCost: template.creditCost,
            idempotencyKey: "final:\(projectId)"
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
        projectId: String,
        bearerToken: String,
        template: MomentTemplate,
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
            projectId: projectId,
            amount: template.creditCost,
            idempotencyKey: "final-reservation:\(projectId):\(template.id.rawValue):\(operationId)"
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
        projectId: String,
        bearerToken: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentDraftForm
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
            projectId: projectId,
            template: template.id.rawValue,
            creationStyle: creationStyle?.rawValue,
            tone: form.tone.rawValue,
            tempo: form.tempo.rawValue,
            occasion: form.occasion,
            details: form.details,
            creditCost: template.creditCost
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

    func startFinalRenderWorkflow(
        projectId: String,
        bearerToken: String,
        template: MomentTemplate,
        creationStyle: MomentCreationStyleID?,
        form: MomentDraftForm,
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
            projectId: projectId,
            renderKind: "final",
            template: template.id.rawValue,
            creationStyle: creationStyle?.rawValue,
            tone: form.tone.rawValue,
            tempo: form.tempo.rawValue,
            occasion: form.occasion,
            details: form.details,
            idempotencyKey: "final-workflow:\(projectId):\(template.id.rawValue):\(operationId)",
            reservationId: reservationId
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
}

enum MomentsFinalRenderError: LocalizedError {
    case apiNotConfigured
    case planFailed
    case reservationFailed
    case generationFailed

    var errorDescription: String? {
        switch self {
        case .apiNotConfigured: "Final render is not configured for this build."
        case .planFailed: "Avi could not prepare the final video plan."
        case .reservationFailed: "Credits could not be reserved for the final video."
        case .generationFailed: "Final render failed before delivery. Credits were not committed unless an export was delivered."
        }
    }
}
