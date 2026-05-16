import Foundation

struct MomentsStoryDraftMedia: Encodable {
    let mediaAssetId: String
    let mediaKind: String
    let sortOrder: Int
    let selected: Bool
    let moderationStatus: String
}

struct MomentsStoryDraftRequest: Encodable {
    let appId = "momentsav"
    let projectId: String
    let template: String
    let tone: String
    let tempo: String
    let occasion: String
    let details: String
    let narrationVoice = "avi_clear"
    let media: [MomentsStoryDraftMedia]
    let safetyAcknowledged = true
    let idempotencyKey: String
}

struct MomentsStoryDraftScene: Decodable, Identifiable, Equatable {
    var id: Int { sceneIndex }
    let sceneIndex: Int
    let mediaAssetIds: [String]
    let caption: String
    let narrationText: String
    let tone: String?
    let musicCue: String?
    let durationMs: Int
    let createdBy: String
    let editable: Bool
}

struct MomentsStoryDraftResponse: Decodable, Equatable {
    let appId: String
    let projectId: String
    let workflowRunId: String
    let status: String
    let provider: String?
    let model: String?
    let moderationStatus: String
    let errorCode: String?
    let errorMessage: String?
    let narrationVoice: String
    let helperCopy: String
    let scenes: [MomentsStoryDraftScene]
    let generatedAt: String
}

enum MomentsStoryDraftRules {
    static func canDraft(mediaAssets: [MomentMediaAsset], template: MomentTemplate) -> Bool {
        MomentsMediaRules.canStartPreview(
            template: template,
            selectedCount: mediaAssets.filter(\.selected).count
        )
    }
}
