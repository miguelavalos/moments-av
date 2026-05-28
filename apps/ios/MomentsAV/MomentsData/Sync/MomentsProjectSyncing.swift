import Combine
import Foundation

@MainActor
protocol MomentsProjectCreating {
    var isConfigured: Bool { get }
    func createDraft(ownerUserId: String, form: MomentDraftForm) async throws -> String
}

@MainActor
protocol MomentsMediaAssetSaving {
    var isConfigured: Bool { get }
    func saveMediaAsset(
        ownerUserId: String,
        projectId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload
    ) async throws -> String
    func saveMediaAssets(
        ownerUserId: String,
        projectId: String,
        mediaAssets: [MediaAssetPersistenceRequest]
    ) async throws -> [String]
}

@MainActor
protocol MomentsStoryDraftSaving {
    var isConfigured: Bool { get }
    func saveStoryDraft(
        ownerUserId: String,
        projectId: String,
        draft: MomentsStoryDraftResponse,
        storyInputSignature: String
    ) async throws
}

@MainActor
protocol MomentsRenderJobStatusUpdating {
    var isConfigured: Bool { get }
    func updateRenderJobStatus(
        ownerUserId: String,
        renderJobId: String,
        status: String,
        errorCode: String?,
        errorMessage: String?
    ) async throws
}

@MainActor
protocol MomentsPreviewResultSaving: MomentsRenderJobStatusUpdating {
    func savePreviewResult(
        ownerUserId: String,
        projectId: String,
        preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) async throws
}

@MainActor
protocol MomentsFinalRenderResultSaving: MomentsRenderJobStatusUpdating {
    func saveStartedFinalRender(
        ownerUserId: String,
        projectId: String,
        reservationId: String,
        startedWorkflow: MomentsStartWorkflowResponse
    ) async throws -> String

    func saveFinalRenderResult(
        ownerUserId: String,
        projectId: String,
        finalRender: MomentsFinalRenderResponse,
        template: MomentTemplate
    ) async throws
}

@MainActor
protocol MomentsProjectDeleting {
    func deleteProject(ownerUserId: String, projectId: String) async throws
}

@MainActor
protocol MomentsProjectsObserving {
    func observeProjects(ownerUserId: String) throws -> AnyPublisher<[MomentDraftProject], Error>
}

@MainActor
protocol MomentsActiveProjectsObserving {
    var projectsPublisher: AnyPublisher<[MomentDraftProject], Never> { get }
    var projectsErrorPublisher: AnyPublisher<String?, Never> { get }

    func observeProjects(ownerUserId: String?)
    func clearProjects()
}

@MainActor
protocol MomentsWorkspaceObserving {
    func observeProjectWorkspace(
        ownerUserId: String,
        projectId: String
    ) throws -> AnyPublisher<MomentProjectWorkspace?, Error>
}

@MainActor
protocol MomentsActiveWorkspaceObserving {
    var activeWorkspacePublisher: AnyPublisher<MomentProjectWorkspace?, Never> { get }
    var workspaceErrorPublisher: AnyPublisher<String?, Never> { get }

    func observeWorkspace(ownerUserId: String?, projectId: String?)
    func clearWorkspace()
}

extension MomentsProjectRepository:
    MomentsProjectCreating,
    MomentsMediaAssetSaving,
    MomentsStoryDraftSaving,
    MomentsRenderJobStatusUpdating,
    MomentsPreviewResultSaving,
    MomentsFinalRenderResultSaving,
    MomentsProjectDeleting,
    MomentsProjectsObserving,
    MomentsWorkspaceObserving {}
