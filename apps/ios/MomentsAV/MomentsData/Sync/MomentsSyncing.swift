import Combine
import Foundation

@MainActor
protocol MomentsCreating {
    var isConfigured: Bool { get }
    func createMoment(ownerUserId: String, form: MomentSetupForm) async throws -> String
    func updateMomentSetup(ownerUserId: String, momentId: String, form: MomentSetupForm) async throws
}

@MainActor
protocol MomentsMediaAssetSaving {
    var isConfigured: Bool { get }
    func saveMediaAsset(
        ownerUserId: String,
        momentId: String,
        media: MomentsSelectedMedia,
        preparedUpload: MomentsPreparedUpload,
        uploadCompletion: MomentsUploadCompletion
    ) async throws -> String
    func saveMediaAssets(
        ownerUserId: String,
        momentId: String,
        mediaAssets: [MediaAssetPersistenceRequest]
    ) async throws -> [String]
}

@MainActor
protocol MomentsStorySaving {
    var isConfigured: Bool { get }
    func saveStory(
        ownerUserId: String,
        momentId: String,
        plan: MomentsStoryResponse,
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
protocol MomentsDeleting {
    func deleteMoment(ownerUserId: String, momentId: String) async throws
}

@MainActor
protocol MomentsTitleUpdating {
    func updateMomentTitle(ownerUserId: String, momentId: String, title: String) async throws
}

@MainActor
protocol MomentsGalleryMarking {
    func markMomentMovedToGallery(ownerUserId: String, momentId: String) async throws
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
    MomentsStorySaving,
    MomentsRenderJobStatusUpdating,
    MomentsDeleting,
    MomentsTitleUpdating,
    MomentsGalleryMarking,
    InProgressMomentsObserving,
    MomentWorkspaceObserving {}
