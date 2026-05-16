import Foundation

struct MomentsFinalRenderRequest: Encodable {
    let appId = "momentsav"
    let projectId: String
    let template: String
    let creditCost: Int
    let safetyAcknowledged = true
    let idempotencyKey: String
}

struct MomentsFinalRenderResponse: Decodable, Equatable {
    let appId: String
    let projectId: String
    let renderJobId: String
    let workflowRunId: String
    let reservationId: String
    let artifactId: String
    let artifactKind: String
    let status: String
    let progressPercent: Int
    let r2Key: String
    let expiresAt: String
    let hasWatermark: Bool
    let creditsCommitted: Int
    let generatedAt: String
}

enum MomentsFinalRenderRules {
    static func canGenerate(
        project: MomentDraftProject,
        template: MomentTemplate,
        balance: MomentsCreditBalance,
        latestPreview: MomentArtifact?
    ) -> Bool {
        latestPreview != nil
            && MomentsCreditGate.canAfford(template, balance: balance)
            && (project.status == "preview_ready" || project.status == "export_ready")
    }
}
