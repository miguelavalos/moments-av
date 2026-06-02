import Foundation

struct MomentsCreateWorkflowCapability: Equatable {
    var canAddMedia = false
    var canPlanStory = false
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var canPrepareFinalRenderPlan = false
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
}
