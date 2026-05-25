import Foundation

struct MomentProjectWorkspace: Decodable, Equatable {
    let project: MomentDraftProject
    let mediaAssets: [MomentMediaAsset]
    let storyScenes: [MomentStoryScene]
    let renderJobs: [MomentRenderJob]
    let artifacts: [MomentArtifact]
}
