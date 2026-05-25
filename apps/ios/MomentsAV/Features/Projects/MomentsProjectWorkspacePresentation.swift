import Foundation

struct MomentsProjectWorkspaceDetailPresentation: Equatable {
    let title = "Project detail"
    let nextAction: MomentsProjectNextAction
    let continuationRequest: MomentsProjectContinuationRequest

    init(workspace: MomentProjectWorkspace) {
        nextAction = MomentsProjectStatusRules.nextAction(for: workspace)
        continuationRequest = MomentsProjectContinuationRequest(
            project: workspace.project,
            focus: nextAction.continuationFocus
        )
    }
}

struct MomentsProjectWorkspaceHeaderPresentation: Equatable {
    let title: String
    let updatedAtTitle: String
    let countsTitle: String

    init(workspace: MomentProjectWorkspace) {
        title = workspace.project.title
        updatedAtTitle = MomentsProjectFormatting.updatedAt(workspace.project)
        countsTitle = [
            Self.countTitle(workspace.mediaAssets.count, singular: "media item", plural: "media items"),
            Self.countTitle(workspace.storyScenes.count, singular: "scene", plural: "scenes"),
            Self.countTitle(workspace.renderJobs.count, singular: "job", plural: "jobs")
        ].joined(separator: " · ")
    }

    private static func countTitle(_ count: Int, singular: String, plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }
}

struct MomentsProjectWorkspaceSummaryPresentation: Equatable {
    let tiles: [MomentsProjectSummaryTilePresentation]

    init(workspace: MomentProjectWorkspace) {
        let latestPreview = workspace.artifacts.last { $0.kind == "preview" }
        let finalExport = workspace.artifacts.last { $0.kind == "final_export" }
        let latestRenderJob = workspace.renderJobs.sorted { $0.updatedAt < $1.updatedAt }.last

        tiles = [
            MomentsProjectSummaryTilePresentation(
                title: "Status",
                value: MomentsProjectStatusRules.displayTitle(for: workspace.project.status),
                systemImage: "circle.dashed"
            ),
            MomentsProjectSummaryTilePresentation(
                title: "Preview",
                value: Self.summaryValue(for: latestPreview),
                systemImage: "play.rectangle"
            ),
            MomentsProjectSummaryTilePresentation(
                title: "Final",
                value: Self.summaryValue(for: finalExport),
                systemImage: "square.and.arrow.up"
            ),
            MomentsProjectSummaryTilePresentation(
                title: "Latest job",
                value: Self.latestJobValue(latestRenderJob),
                systemImage: "gearshape.2"
            )
        ]
    }

    private static func latestJobValue(_ latestRenderJob: MomentRenderJob?) -> String {
        guard let latestRenderJob else { return "Not started" }
        return "\(MomentsProjectStatusRules.displayKind(latestRenderJob.kind)) · \(MomentsProjectStatusRules.displayTitle(for: latestRenderJob.status))"
    }

    private static func summaryValue(for artifact: MomentArtifact?) -> String {
        guard let artifact else { return "Not ready" }
        return MomentsProjectStatusRules.displayTitle(for: artifact.status)
    }
}

struct MomentsProjectSummaryTilePresentation: Identifiable, Equatable {
    let title: String
    let value: String
    let systemImage: String

    var id: String { title }
}

struct MomentsProjectMediaSectionPresentation: Equatable {
    let title = "Media"
    let emptySystemImage = "photo.badge.plus"
    let emptyMessage = "Add photos or clips from Create to unlock story drafting."
    let mediaAssets: [MomentsProjectMediaAssetPresentation]

    init(mediaAssets: [MomentMediaAsset]) {
        self.mediaAssets = MomentsProjectMediaAssetPresentation.sorted(mediaAssets)
    }
}

struct MomentsProjectStorySectionPresentation: Equatable {
    let title = "Story"
    let emptySystemImage = "text.bubble"
    let emptyMessage = "Generate a story draft after the project has enough media."
    let storyScenes: [MomentsProjectStoryScenePresentation]

    init(storyScenes: [MomentStoryScene]) {
        self.storyScenes = MomentsProjectStoryScenePresentation.sorted(storyScenes)
    }
}

struct MomentsProjectMediaAssetPresentation: Identifiable, Equatable {
    let id: String
    let systemImage: String
    let title: String
    let detail: String

    init(mediaAsset: MomentMediaAsset) {
        id = mediaAsset.id
        systemImage = mediaAsset.kind == "video" ? "video" : "photo"
        title = "\(MomentsProjectStatusRules.displayKind(mediaAsset.kind)) \(Int(mediaAsset.sortOrder) + 1)"
        detail = MomentsProjectFormatting.mediaAssetDetail(mediaAsset)
    }

    static func sorted(_ mediaAssets: [MomentMediaAsset]) -> [MomentsProjectMediaAssetPresentation] {
        mediaAssets
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(MomentsProjectMediaAssetPresentation.init)
    }
}

struct MomentsProjectStoryScenePresentation: Identifiable, Equatable {
    let id: String
    let title: String
    let caption: String

    init(scene: MomentStoryScene) {
        id = scene.id
        title = "Scene \(Int(scene.sceneIndex) + 1)"
        caption = scene.caption
    }

    static func sorted(_ scenes: [MomentStoryScene]) -> [MomentsProjectStoryScenePresentation] {
        scenes
            .sorted { $0.sceneIndex < $1.sceneIndex }
            .map(MomentsProjectStoryScenePresentation.init)
    }
}
