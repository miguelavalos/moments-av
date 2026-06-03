import Combine
import Foundation

@MainActor
protocol MomentsCreating {
    var isConfigured: Bool { get }
    func createMoment(ownerUserId: String, form: MomentSetupForm) async throws -> String
}

@MainActor
protocol MomentsMediaAssetSaving {
    var isConfigured: Bool { get }
    func saveMediaAsset(
        ownerUserId: String,
        momentId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload
    ) async throws -> String
    func saveMediaAssets(
        ownerUserId: String,
        momentId: String,
        mediaAssets: [MediaAssetPersistenceRequest]
    ) async throws -> [String]
}

@MainActor
protocol MomentsStoryPlanSaving {
    var isConfigured: Bool { get }
    func saveStoryPlan(
        ownerUserId: String,
        momentId: String,
        plan: MomentsStoryPlanResponse,
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
        phase: String?,
        progressPercent: Int?,
        userMessage: String?,
        canEditSetup: Bool?,
        canRetry: Bool?,
        errorCode: String?,
        errorMessage: String?
    ) async throws
}

@MainActor
protocol MomentsPreviewResultSaving: MomentsRenderJobStatusUpdating {
    func savePreviewResult(
        ownerUserId: String,
        momentId: String,
        preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) async throws
}

@MainActor
protocol MomentsFinalRenderResultSaving: MomentsRenderJobStatusUpdating {
    func saveStartedFinalRender(
        ownerUserId: String,
        momentId: String,
        reservationId: String,
        startedWorkflow: MomentsStartWorkflowResponse
    ) async throws -> String

    func saveFinalRenderResult(
        ownerUserId: String,
        momentId: String,
        finalRender: MomentsFinalRenderResponse,
        template: MomentTemplate
    ) async throws

    func saveCompletedFinalRenderStatusArtifact(
        ownerUserId: String,
        momentId: String,
        renderJobId: String,
        status: MomentsRenderStatusResponse
    ) async throws
}

@MainActor
protocol MomentsDeleting {
    func deleteMoment(ownerUserId: String, momentId: String) async throws
}

@MainActor
protocol InProgressMomentsObserving {
    func observeInProgressMoments(ownerUserId: String) throws -> AnyPublisher<[InProgressMoment], Error>
}

@MainActor
protocol InProgressMomentsListProviding {
    var momentsPublisher: AnyPublisher<[InProgressMoment], Never> { get }
    var momentsErrorPublisher: AnyPublisher<String?, Never> { get }

    func observeInProgressMoments(ownerUserId: String?)
    func clearInProgressMoments()
}

@MainActor
protocol MomentWorkspaceObserving {
    func observeMomentWorkspace(
        ownerUserId: String,
        momentId: String
    ) throws -> AnyPublisher<MomentWorkspace?, Error>
}

@MainActor
protocol MomentsActiveWorkspaceObserving {
    var activeWorkspacePublisher: AnyPublisher<MomentWorkspace?, Never> { get }
    var workspaceErrorPublisher: AnyPublisher<String?, Never> { get }

    func observeWorkspace(ownerUserId: String?, momentId: String?)
    func clearWorkspace()
}

extension MomentsRepository:
    MomentsCreating,
    MomentsMediaAssetSaving,
    MomentsStoryPlanSaving,
    MomentsRenderJobStatusUpdating,
    MomentsPreviewResultSaving,
    MomentsFinalRenderResultSaving,
    MomentsDeleting,
    InProgressMomentsObserving,
    MomentWorkspaceObserving {}
