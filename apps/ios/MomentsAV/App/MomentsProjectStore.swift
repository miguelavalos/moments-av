import Combine
@preconcurrency import ConvexMobile
import Foundation

@MainActor
final class MomentsProjectStore: ObservableObject {
    @Published private(set) var projects: [MomentDraftProject] = []
    @Published private(set) var activeProject: MomentDraftProject?
    @Published private(set) var activeWorkspace: MomentProjectWorkspace?
    @Published private(set) var isCreatingDraft = false
    @Published private(set) var isSavingMedia = false
    @Published private(set) var isSavingStory = false
    @Published private(set) var isSavingPreview = false
    @Published private(set) var isSavingFinalRender = false
    @Published private(set) var isDeletingProject = false
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
        activeWorkspace = nil

        guard let client, let ownerUserId, let projectId else { return }

        activeProjectTask = Task { [weak self, client] in
            let updates = client.subscribe(
                to: "moments:getProjectWorkspace",
                with: [
                    "ownerUserId": ownerUserId,
                    "projectId": projectId
                ],
                yielding: MomentProjectWorkspace?.self
            )
            .replaceError(with: nil)
            .values

            for await workspace in updates {
                await MainActor.run {
                    self?.activeWorkspace = workspace
                    self?.activeProject = workspace?.project
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

    func saveMediaAsset(
        ownerUserId: String,
        projectId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload
    ) async -> Bool {
        guard let client else {
            errorMessage = "Project sync is not configured for this build."
            return false
        }

        isSavingMedia = true
        errorMessage = nil

        do {
            let uploadedAt = Date()
            let _: String? = try await client.mutation(
                "moments:addMediaAsset",
                with: [
                    "ownerUserId": ownerUserId,
                    "projectId": projectId,
                    "platformMediaAssetId": preparedUpload.mediaAssetId,
                    "uploadId": preparedUpload.uploadId,
                    "kind": media.kind,
                    "r2Key": preparedUpload.storageKey,
                    "sortOrder": media.sortOrder,
                    "selected": media.selected,
                    "moderationStatus": "pending",
                    "uploadedAt": uploadedAt.timeIntervalSince1970 * 1000,
                    "sourceExpiresAt": uploadedAt.addingTimeInterval(30 * 24 * 60 * 60).timeIntervalSince1970 * 1000
                ]
            )
            isSavingMedia = false
            observeActiveProject(ownerUserId: ownerUserId, projectId: projectId)
            observeProjects(ownerUserId: ownerUserId)
            return true
        } catch {
            isSavingMedia = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    func saveStoryDraft(
        ownerUserId: String,
        projectId: String,
        draft: MomentsStoryDraftResponse
    ) async -> Bool {
        guard let client else {
            errorMessage = "Project sync is not configured for this build."
            return false
        }

        isSavingStory = true
        errorMessage = nil

        do {
            for scene in draft.scenes {
                let mediaAssetIds: [ConvexEncodable?] = scene.mediaAssetIds.map { $0 as ConvexEncodable }
                let _: String? = try await client.mutation(
                    "moments:upsertStoryScene",
                    with: [
                        "ownerUserId": ownerUserId,
                        "projectId": projectId,
                        "sceneIndex": scene.sceneIndex,
                        "mediaAssetIds": mediaAssetIds,
                        "caption": scene.caption,
                        "narrationText": scene.narrationText,
                        "tone": scene.tone,
                        "musicCue": scene.musicCue,
                        "durationMs": scene.durationMs,
                        "createdBy": "avi"
                    ]
                )
            }

            let _: String? = try await client.mutation(
                "moments:markStoryReady",
                with: [
                    "ownerUserId": ownerUserId,
                    "projectId": projectId,
                    "workflowRunId": draft.workflowRunId,
                    "moderationStatus": draft.moderationStatus == "allowed" ? "approved" : "blocked"
                ]
            )
            isSavingStory = false
            observeActiveProject(ownerUserId: ownerUserId, projectId: projectId)
            observeProjects(ownerUserId: ownerUserId)
            return true
        } catch {
            isSavingStory = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    func savePreviewResult(
        ownerUserId: String,
        projectId: String,
        preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) async -> Bool {
        guard let client else {
            errorMessage = "Project sync is not configured for this build."
            return false
        }

        isSavingPreview = true
        errorMessage = nil

        do {
            let renderJobId: String? = try await client.mutation(
                "moments:createRenderJob",
                with: [
                    "ownerUserId": ownerUserId,
                    "projectId": projectId,
                    "kind": "preview",
                    "workflowRunId": preview.workflowRunId,
                    "provider": "mock",
                    "providerRequestId": preview.renderJobId
                ]
            )

            if let renderJobId {
                let _: String? = try await client.mutation(
                    "moments:attachArtifact",
                    with: [
                        "ownerUserId": ownerUserId,
                        "projectId": projectId,
                        "renderJobId": renderJobId,
                        "kind": "preview",
                        "r2Key": preview.r2Key,
                        "status": "available",
                        "durationSeconds": template.durationSeconds,
                        "creditCost": 0,
                        "hasWatermark": preview.hasWatermark,
                        "expiresAt": Date().addingTimeInterval(30 * 24 * 60 * 60).timeIntervalSince1970 * 1000
                    ]
                )

                let _: String? = try await client.mutation(
                    "moments:updateRenderJobStatus",
                    with: [
                        "ownerUserId": ownerUserId,
                        "renderJobId": renderJobId,
                        "status": "completed"
                    ]
                )
            }

            isSavingPreview = false
            observeActiveProject(ownerUserId: ownerUserId, projectId: projectId)
            observeProjects(ownerUserId: ownerUserId)
            return renderJobId != nil
        } catch {
            isSavingPreview = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    func saveFinalRenderResult(
        ownerUserId: String,
        projectId: String,
        finalRender: MomentsFinalRenderResponse,
        template: MomentTemplate
    ) async -> Bool {
        guard let client else {
            errorMessage = "Project sync is not configured for this build."
            return false
        }

        isSavingFinalRender = true
        errorMessage = nil

        do {
            let renderJobId: String? = try await client.mutation(
                "moments:createRenderJob",
                with: [
                    "ownerUserId": ownerUserId,
                    "projectId": projectId,
                    "kind": "final",
                    "workflowRunId": finalRender.workflowRunId,
                    "creditReservationId": finalRender.reservationId,
                    "provider": "mock",
                    "providerRequestId": finalRender.renderJobId
                ]
            )

            if let renderJobId {
                let _: String? = try await client.mutation(
                    "moments:attachArtifact",
                    with: [
                        "ownerUserId": ownerUserId,
                        "projectId": projectId,
                        "renderJobId": renderJobId,
                        "kind": "final_export",
                        "r2Key": finalRender.r2Key,
                        "status": "available",
                        "durationSeconds": template.durationSeconds,
                        "creditCost": finalRender.creditsCommitted,
                        "hasWatermark": false,
                        "expiresAt": Date().addingTimeInterval(30 * 24 * 60 * 60).timeIntervalSince1970 * 1000
                    ]
                )

                let _: String? = try await client.mutation(
                    "moments:updateRenderJobStatus",
                    with: [
                        "ownerUserId": ownerUserId,
                        "renderJobId": renderJobId,
                        "status": "completed"
                    ]
                )
            }

            isSavingFinalRender = false
            observeActiveProject(ownerUserId: ownerUserId, projectId: projectId)
            observeProjects(ownerUserId: ownerUserId)
            return renderJobId != nil
        } catch {
            isSavingFinalRender = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteProject(ownerUserId: String, projectId: String) async -> Bool {
        guard let client else {
            errorMessage = "Project sync is not configured for this build."
            return false
        }

        isDeletingProject = true
        errorMessage = nil

        do {
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
            isDeletingProject = false
            activeProject = nil
            activeWorkspace = nil
            observeProjects(ownerUserId: ownerUserId)
            return true
        } catch {
            isDeletingProject = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
