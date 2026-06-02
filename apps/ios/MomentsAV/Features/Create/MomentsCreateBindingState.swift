import Foundation

struct MomentsCreateAccountState {
    let isSignedIn: Bool
    let balance: MomentsCreditBalance
}

struct MomentsCreateMomentCreationState {
    let isCreatingDraft: Bool
    let activeMomentId: String?
    let draftErrorMessage: String?
}

struct MomentsCreateMediaUploadState {
    let selectedMedia: [MomentsSelectedMedia]
    let statusMessage: String?
    let isImporting: Bool
    let importProgress: MomentsMediaImportProgress?
}

struct MomentsCreateStoryDraftState {
    let savedScenes: [MomentStoryScene]
    let generatedScenes: [MomentsStoryDraftScene]
    let statusMessage: String?
    let isDrafting: Bool
}

struct MomentsCreatePreviewGenerationState {
    let activeWorkspace: MomentWorkspace?
    let latestPreview: MomentArtifact?
    let latestPreviewJob: MomentRenderJob?
    let statusMessage: String?
    let isGenerating: Bool
    let isRefreshingStatus: Bool
}

struct MomentsCreateFinalRenderState {
    let finalExport: MomentArtifact?
    let latestFinalJob: MomentRenderJob?
    let renderPlan: MomentsRenderPlanResponse?
    var pendingGalleryVideo: MomentsGalleryVideoRecord? = nil
    var canRetryFinalVideoDownload = false
    let statusMessage: String?
    let isGenerating: Bool
    let isRefreshingStatus: Bool
}
