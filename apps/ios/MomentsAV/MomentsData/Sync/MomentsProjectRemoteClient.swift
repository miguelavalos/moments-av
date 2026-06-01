import Combine
@preconcurrency import ConvexMobile
import Foundation

struct MomentsProjectRemoteClient {
    private let client: ConvexClient?
    private let retryPolicy = MomentsNetworkRetryPolicy()

    init(deploymentURL: String) {
        let trimmedURL = deploymentURL.trimmingCharacters(in: .whitespacesAndNewlines)
        client = trimmedURL.isEmpty ? nil : ConvexClient(deploymentUrl: trimmedURL)
    }

    var isConfigured: Bool {
        client != nil
    }

    func observeProjects(ownerUserId: String) throws -> AnyPublisher<[MomentDraftProject], Error> {
        let client = try requireClient()

        return client.subscribe(
            to: "moments:listProjects",
            with: ["ownerUserId": ownerUserId],
            yielding: [MomentDraftProject].self
        )
        .mapError { $0 as Error }
        .eraseToAnyPublisher()
    }

    func observeProjectWorkspace(
        ownerUserId: String,
        projectId: String
    ) throws -> AnyPublisher<MomentProjectWorkspace?, Error> {
        let client = try requireClient()

        return client.subscribe(
            to: "moments:getProjectWorkspace",
            with: [
                "ownerUserId": ownerUserId,
                "projectId": projectId
            ],
            yielding: MomentProjectWorkspace?.self
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
        request: DraftProjectCreationRequest
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

    func deleteProjectTree(ownerUserId: String, projectId: String) async throws {
        try await deleteProjectTree(
            ownerUserId: ownerUserId,
            request: .userRequested(projectId: projectId)
        )
    }

    func deleteProjectTree(
        ownerUserId: String,
        request: ProjectDeletionRequest
    ) async throws {
        let client = try requireClient()

        let deletedProjectId: String? = try await retryingMutation(
            client: client,
            name: "moments:deleteProject",
            args: [
                "ownerUserId": ownerUserId,
                "projectId": request.projectId,
                "deleteSourceMedia": request.deleteSourceMedia,
                "deleteGeneratedArtifacts": request.deleteGeneratedArtifacts,
                "reason": request.reason
            ]
        )

        guard deletedProjectId != nil else {
            throw MomentsProjectSyncError.unexpectedResponse
        }
    }

    func requireClient() throws -> ConvexClient {
        guard let client else {
            throw MomentsProjectSyncError.notConfigured
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
