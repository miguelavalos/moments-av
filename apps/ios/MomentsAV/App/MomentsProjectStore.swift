import Combine
@preconcurrency import ConvexMobile
import Foundation

@MainActor
final class MomentsProjectStore: ObservableObject {
    @Published private(set) var projects: [MomentDraftProject] = []
    @Published private(set) var activeProject: MomentDraftProject?
    @Published private(set) var isCreatingDraft = false
    @Published var errorMessage: String?

    private nonisolated(unsafe) let client: ConvexClient?
    private var projectListTask: Task<Void, Never>?
    private var activeProjectTask: Task<Void, Never>?

    init(deploymentURL: String = AppConfig.momentsConvexURL) {
        let trimmedURL = deploymentURL.trimmingCharacters(in: .whitespacesAndNewlines)
        client = trimmedURL.isEmpty ? nil : ConvexClient(deploymentUrl: trimmedURL)
    }

    var isConfigured: Bool {
        client != nil
    }

    func observeProjects(ownerUserId: String?) {
        projectListTask?.cancel()
        projects = []

        guard let client, let ownerUserId else { return }

        projectListTask = Task { [weak self, client] in
            let updates = client.subscribe(
                to: "moments:listProjects",
                with: ["ownerUserId": ownerUserId],
                yielding: [MomentDraftProject].self
            )
            .replaceError(with: [])
            .values

            for await projects in updates {
                await MainActor.run {
                    self?.projects = projects
                }
            }
        }
    }

    func observeActiveProject(ownerUserId: String?, projectId: String?) {
        activeProjectTask?.cancel()
        activeProject = nil

        guard let client, let ownerUserId, let projectId else { return }

        activeProjectTask = Task { [weak self, client] in
            let updates = client.subscribe(
                to: "moments:getProject",
                with: [
                    "ownerUserId": ownerUserId,
                    "projectId": projectId
                ],
                yielding: MomentDraftProject?.self
            )
            .replaceError(with: nil)
            .values

            for await project in updates {
                await MainActor.run {
                    self?.activeProject = project
                }
            }
        }
    }

    func createDraft(ownerUserId: String, form: MomentDraftForm) async -> String? {
        guard let client else {
            errorMessage = "Project sync is not configured for this build."
            return nil
        }

        guard form.canCreateDraft else {
            errorMessage = "Add the occasion before creating a draft."
            return nil
        }

        isCreatingDraft = true
        errorMessage = nil

        do {
            let projectId: String = try await client.mutation(
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
            isCreatingDraft = false
            observeActiveProject(ownerUserId: ownerUserId, projectId: projectId)
            observeProjects(ownerUserId: ownerUserId)
            return projectId
        } catch {
            isCreatingDraft = false
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
