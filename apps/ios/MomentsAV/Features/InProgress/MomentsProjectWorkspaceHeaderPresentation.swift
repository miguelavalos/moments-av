import Foundation

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

