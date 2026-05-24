import Foundation

struct MomentsCreateAccountState {
    let isSignedIn: Bool
    let balance: MomentsCreditBalance
}

struct MomentsCreateProjectCreationState {
    let isCreatingDraft: Bool
    let createdProjectId: String?
    let draftErrorMessage: String?
}

struct MomentsCreateMediaUploadState {
    let selectedMedia: [MomentsSelectedMedia]
    let statusMessage: String?
    let isImporting: Bool
}

struct MomentsCreateStoryDraftState {
    let savedScenes: [MomentStoryScene]
    let generatedScenes: [MomentsStoryDraftScene]
    let statusMessage: String?
    let isDrafting: Bool
}

struct MomentsCreatePreviewGenerationState {
    let activeWorkspace: MomentProjectWorkspace?
    let latestPreview: MomentArtifact?
    let latestPreviewJob: MomentRenderJob?
    let statusMessage: String?
    let isGenerating: Bool
    let isRefreshingStatus: Bool
}

struct MomentsCreateFinalRenderState {
    let finalExport: MomentArtifact?
    let latestFinalJob: MomentRenderJob?
    let statusMessage: String?
    let isGenerating: Bool
    let isRefreshingStatus: Bool
}
