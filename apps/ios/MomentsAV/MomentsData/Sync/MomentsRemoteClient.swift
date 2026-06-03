import Combine
@preconcurrency import ConvexMobile
import Foundation

struct MomentsRemoteClient {
    private let client: ConvexClient?
    private let retryPolicy = MomentsNetworkRetryPolicy()

    init(deploymentURL: String) {
        let trimmedURL = deploymentURL.trimmingCharacters(in: .whitespacesAndNewlines)
        client = trimmedURL.isEmpty ? nil : ConvexClient(deploymentUrl: trimmedURL)
    }

    var isConfigured: Bool {
        client != nil
    }

    func observeInProgressMoments(ownerUserId: String) throws -> AnyPublisher<[InProgressMoment], Error> {
        let client = try requireClient()

        return client.subscribe(
            to: "moments:listMoments",
            with: [
                "ownerUserId": ownerUserId,
                "collection": "in_progress"
            ],
            yielding: [InProgressMoment].self
        )
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }

    func observeMomentWorkspace(
        ownerUserId: String,
        momentId: String
    ) throws -> AnyPublisher<MomentWorkspace?, Error> {
        let client = try requireClient()

        return client.subscribe(
            to: "moments:getMomentWorkspace",
            with: [
                "ownerUserId": ownerUserId,
                "momentId": momentId
            ],
            yielding: MomentWorkspace?.self
        )
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }

    func createMoment(ownerUserId: String, form: MomentSetupForm) async throws -> String {
        try await createMoment(
            ownerUserId: ownerUserId,
            request: .setup(form)
        )
    }

    func createMoment(
        ownerUserId: String,
        request: MomentCreationRequest
    ) async throws -> String {
        let client = try requireClient()

        return try await retryingMutation(
            client: client,
            name: "moments:createMoment",
            args: [
                "ownerUserId": ownerUserId,
                "creationMode": request.creationMode,
                "look": request.look,
                "theme": request.theme,
                "mood": request.mood,
                "duration": request.duration,
                "mediaUse": request.mediaUse,
                "title": request.title,
                "occasion": request.occasion,
                "details": request.details
            ]
        )
    }

    func deleteMomentTree(ownerUserId: String, momentId: String) async throws {
        try await deleteMomentTree(
            ownerUserId: ownerUserId,
            request: .userRequested(momentId: momentId)
        )
    }

    func deleteMomentTree(
        ownerUserId: String,
        request: MomentDeletionRequest
    ) async throws {
        let client = try requireClient()

        let deletedMomentId: String? = try await retryingMutation(
            client: client,
            name: "moments:deleteMoment",
            args: [
                "ownerUserId": ownerUserId,
                "momentId": request.momentId,
                "deleteSourceMedia": request.deleteSourceMedia,
                "deleteGeneratedArtifacts": request.deleteGeneratedArtifacts,
                "reason": request.reason
            ]
        )

        guard deletedMomentId != nil else {
            throw MomentsSyncError.unexpectedResponse
        }
    }

    func requireClient() throws -> ConvexClient {
        guard let client else {
            throw MomentsSyncError.notConfigured
        }

        return client
    }

    func retryingMutation<T: Decodable>(
        client: ConvexClient,
        name: String,
        args: [String: ConvexEncodable?]
    ) async throws -> T {
        try await retryPolicy.run {
            try await client.mutation(name, with: args)
        }
    }
}
