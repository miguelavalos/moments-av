import Combine
@preconcurrency import ConvexMobile
import Foundation

struct MomentsProjectRemoteClient {
    private let client: ConvexClient?

    init(deploymentURL: String) {
        let trimmedURL = deploymentURL.trimmingCharacters(in: .whitespacesAndNewlines)
        client = trimmedURL.isEmpty ? nil : ConvexClient(deploymentUrl: trimmedURL)
    }

    var isConfigured: Bool {
        client != nil
    }

    func observeProjects(ownerUserId: String) throws -> AnyPublisher<[MomentDraftProject], Never> {
        let client = try requireClient()

        return client.subscribe(
            to: "moments:listProjects",
            with: ["ownerUserId": ownerUserId],
            yielding: [MomentDraftProject].self
        )
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }

    func observeProjectWorkspace(
        ownerUserId: String,
        projectId: String
    ) throws -> AnyPublisher<MomentProjectWorkspace?, Never> {
        let client = try requireClient()

        return client.subscribe(
            to: "moments:getProjectWorkspace",
            with: [
                "ownerUserId": ownerUserId,
                "projectId": projectId
            ],
            yielding: MomentProjectWorkspace?.self
        )
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }

    func createDraftProject(ownerUserId: String, form: MomentDraftForm) async throws -> String {
        let client = try requireClient()

        return try await client.mutation(
            "moments:createDraftProject",
            with: [
                "ownerUserId": ownerUserId,
                "template": form.template.id.rawValue,
                "title": form.title,
                "tone": form.tone.rawValue,
                "tempo": form.tempo.rawValue,
                "occasion": form.occasion,
                "details": form.details
            ]
        )
    }

    func deleteProjectTree(ownerUserId: String, projectId: String) async throws {
        let client = try requireClient()

        let _: String? = try await client.mutation(
            "moments:deleteProject",
            with: [
                "ownerUserId": ownerUserId,
                "projectId": projectId,
                "deleteSourceMedia": true,
                "deleteGeneratedArtifacts": true,
                "reason": "user request"
            ]
        )
    }

    func requireClient() throws -> ConvexClient {
        guard let client else {
            throw MomentsProjectSyncError.notConfigured
        }

        return client
    }

    func storyModerationStatus(for draft: MomentsStoryDraftResponse) -> String {
        draft.moderationStatus == "allowed" ? "approved" : "blocked"
    }

    func convexStringArray(_ values: [String]) -> [ConvexEncodable?] {
        values.map { $0 as ConvexEncodable }
    }

    func milliseconds(from date: Date) -> Double {
        date.timeIntervalSince1970 * 1000
    }

    func expirationMilliseconds(from date: Date = Date()) -> Double {
        date.addingTimeInterval(30 * 24 * 60 * 60).timeIntervalSince1970 * 1000
    }
}
