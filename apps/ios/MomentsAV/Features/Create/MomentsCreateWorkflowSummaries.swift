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

    var realtimeStatus: MomentsRenderRealtimePresentation? {
        latestFinalJob.map { MomentsRenderRealtimePresentation(renderJob: $0) }
    }
}

struct MomentsRenderRealtimePresentation: Equatable {
    let title: String
    let detail: String
    let progressFraction: Double?
    let systemImage: String
    let isActive: Bool
    let canEditDraft: Bool

    init(renderJob: MomentRenderJob) {
        isActive = renderJob.isActiveRender
        canEditDraft = renderJob.canEditDraft ?? !renderJob.isActiveRender
        title = Self.title(status: renderJob.status, phase: renderJob.phase)
        detail = Self.detail(renderJob)
        progressFraction = Self.progressFraction(renderJob.progressPercent)
        systemImage = Self.systemImage(status: renderJob.status, phase: renderJob.phase)
    }

    private static func title(status: String, phase: String?) -> String {
        if status == "completed" { return "Ready" }
        if status == "failed" { return "Needs attention" }

        switch phase {
        case "preparing":
            return "Preparing"
        case "uploading":
            return "Uploading"
        case "composing":
            return "Composing"
        case "rendering":
            return "Rendering"
        case "saving":
            return "Saving"
        case "ready":
            return "Ready"
        case "failed":
            return "Needs attention"
        default:
            return status == "queued" ? "Queued" : "Working"
        }
    }

    private static func detail(_ renderJob: MomentRenderJob) -> String {
        if renderJob.status == "failed" {
            return MomentsRecoveryCopy.failedRenderDetail(
                userMessage: renderJob.userMessage,
                errorMessage: renderJob.errorMessage
            )
        }

        if let userMessage = renderJob.userMessage, !userMessage.isEmpty {
            return userMessage
        }

        switch renderJob.phase {
        case "preparing":
            return "Avi is preparing the render."
        case "uploading":
            return "Avi is sending the media for rendering."
        case "composing":
            return "Avi is arranging the selected moments."
        case "rendering":
            return "Avi is creating the video."
        case "saving":
            return "Avi is saving the finished video."
        default:
            return renderJob.isActiveRender ? "Avi is updating the video status in realtime." : "Render status is available."
        }
    }

    private static func progressFraction(_ progressPercent: Double?) -> Double? {
        guard let progressPercent else { return nil }
        return min(max(progressPercent / 100, 0), 1)
    }

    private static func systemImage(status: String, phase: String?) -> String {
        if status == "completed" { return "checkmark.circle.fill" }
        if status == "failed" { return "exclamationmark.triangle.fill" }

        switch phase {
        case "uploading":
            return "icloud.and.arrow.up.fill"
        case "composing":
            return "rectangle.stack.fill"
        case "rendering":
            return "gearshape.2.fill"
        case "saving":
            return "square.and.arrow.down.fill"
        default:
            return "sparkles"
        }
    }
}
