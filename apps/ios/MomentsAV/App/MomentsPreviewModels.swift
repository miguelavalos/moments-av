import Foundation

struct MomentsPreviewRequest: Encodable {
    let appId = "momentsav"
    let projectId: String
    let template: String
    let creditCost: Int
    let safetyAcknowledged = true
    let idempotencyKey: String
}

struct MomentsPreviewResponse: Decodable, Equatable {
    let appId: String
    let projectId: String
    let renderJobId: String
    let workflowRunId: String
    let provider: String
    let model: String
    let artifactId: String
    let artifactKind: String
    let status: String
    let progressPercent: Int
    let progressState: String
    let r2Key: String
    let expiresAt: String
    let hasWatermark: Bool
    let generatedAt: String
}

enum MomentsPreviewRules {
    static func canGenerate(project: MomentDraftProject, template: MomentTemplate, balance: MomentsCreditBalance) -> Bool {
        Int(project.previewCount) < Int(project.previewLimit)
            && MomentsCreditGate.canAfford(template, balance: balance)
            && (project.status == "story_ready" || project.status == "preview_ready")
    }
}
