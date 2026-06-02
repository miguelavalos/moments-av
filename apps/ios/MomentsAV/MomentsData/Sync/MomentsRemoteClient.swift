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
            to: "moments:listProjects",
            with: ["ownerUserId": ownerUserId],
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
            to: "moments:getProjectWorkspace",
            with: [
                "ownerUserId": ownerUserId,
                "momentId": momentId
            ],
            yielding: MomentWorkspace?.self
        )
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }

    func createDraftProject(ownerUserId: String, form: MomentDraftForm) async throws -> String {
        try await createDraftProject(
            ownerUserId: ownerUserId,
            request: .draft(form)
        )
    }

    func createDraftProject(
        ownerUserId: String,
        request: MomentCreationRequest
    ) async throws -> String {
        let client = try requireClient()

        return try await retryingMutation(
            client: client,
            name: "moments:createDraftProject",
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

        let deletedProjectId: String? = try await retryingMutation(
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

        guard deletedProjectId != nil else {
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
