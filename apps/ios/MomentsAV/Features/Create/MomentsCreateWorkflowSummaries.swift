import Foundation

struct MomentsCreateWorkspaceSummary: Equatable {
    var mediaCount = 0
    var sceneCount = 0
    var renderJobCount = 0
    var hasPreviewArtifact = false
    var hasFinalExport = false

    var mediaDetail: String {
        "\(mediaCount) added"
    }

    var storyDetail: String {
        Self.countTitle(sceneCount, singular: "scene", plural: "scenes")
    }

    var previewDetail: String {
        hasPreviewArtifact ? "Ready" : "Not made yet"
    }

    static func make(
        workspace: MomentProjectWorkspace?,
        latestPreview: MomentArtifact?,
        finalExport: MomentArtifact?
    ) -> MomentsCreateWorkspaceSummary {
        MomentsCreateWorkspaceSummary(
            mediaCount: workspace?.mediaAssets.count ?? 0,
            sceneCount: workspace?.storyScenes.count ?? 0,
            renderJobCount: workspace?.renderJobs.count ?? 0,
            hasPreviewArtifact: latestPreview != nil,
            hasFinalExport: finalExport != nil
        )
    }

    private static func countTitle(_ count: Int, singular: String, plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }
}

struct MomentsCreateMediaSummary: Equatable {
    var selectedMedia: [MomentsSelectedMedia] = []
    var syncedMediaAssets: [MomentMediaAsset] = []
    var isImporting = false
    var importProgress: MomentsMediaImportProgress?
    var statusMessage: String?

    var selectedCount: Int {
        selectedMedia.filter(\.selected).count
    }

    var reviewCount: Int {
        if selectedCount > 0 {
            return selectedCount
        }

        let selectedBackendCount = temporaryBackendMediaCount
        return selectedBackendCount > 0 ? selectedBackendCount : syncedMediaAssets.count
    }

    var hasTemporaryBackendMedia: Bool {
        selectedMedia.isEmpty && savedBackendMediaCount > 0
    }

    var temporaryBackendMediaCount: Int {
        syncedMediaAssets.filter(\.selected).count
    }

    var savedBackendMediaCount: Int {
        let selectedBackendCount = temporaryBackendMediaCount
        return selectedBackendCount > 0 ? selectedBackendCount : syncedMediaAssets.count
    }

    func remainingSlots(template: MomentTemplate) -> Int {
        MomentsMediaRules.remainingSlots(template: template, selectedCount: reviewCount)
    }
}

struct MomentsMediaImportProgress: Equatable {
    var completedCount = 0
    var totalCount = 0

    var fractionCompleted: Double? {
        guard totalCount > 0 else { return nil }
        return min(max(Double(completedCount) / Double(totalCount), 0), 1)
    }

    var title: String {
        guard totalCount > 0 else { return "Reading media" }
        return "\(min(completedCount, totalCount)) of \(totalCount)"
    }
}

struct MomentsCreateStorySummary: Equatable {
    var savedScenes: [MomentStoryScene] = []
    var generatedScenes: [MomentsStoryDraftScene] = []
    var isDrafting = false
    var statusMessage: String?

    var hasScenes: Bool {
        !savedScenes.isEmpty || !generatedScenes.isEmpty
    }

    var reviewScenes: [MomentsCreateStoryReviewScene] {
        if !savedScenes.isEmpty {
            return savedScenes
                .sorted { $0.sceneIndex < $1.sceneIndex }
                .map {
                    MomentsCreateStoryReviewScene(
                        title: Self.sceneTitle(Int($0.sceneIndex)),
                        caption: $0.caption,
                        detail: $0.narrationText
                    )
                }
        }

        return generatedScenes
            .sorted { $0.sceneIndex < $1.sceneIndex }
            .map {
                MomentsCreateStoryReviewScene(
                    title: Self.sceneTitle($0.sceneIndex),
                    caption: $0.caption,
                    detail: $0.narrationText
                )
            }
    }

    private static func sceneTitle(_ index: Int) -> String {
        switch index {
        case 0:
            return "Opening"
        case 1:
            return "Main moments"
        case 2:
            return "Ending"
        default:
            return "Scene \(index + 1)"
        }
    }
}

struct MomentsCreateStoryReviewScene: Equatable, Identifiable {
    var id: String { "\(title)-\(caption)" }
    let title: String
    let caption: String
    let detail: String?
}

struct MomentsCreatePreviewSummary: Equatable {
    var activeProject: MomentDraftProject?
    var latestPreview: MomentArtifact?
    var latestPreviewJob: MomentRenderJob?
    var isGenerating = false
    var isRefreshingStatus = false
    var statusMessage: String?
}

struct MomentsCreateFinalRenderSummary: Equatable {
    var creditCost = 0
    var renderPlan: MomentsRenderPlanResponse?
    var finalExport: MomentArtifact?
    var latestFinalJob: MomentRenderJob?
    var isGenerating = false
    var isRefreshingStatus = false
    var statusMessage: String?
}
