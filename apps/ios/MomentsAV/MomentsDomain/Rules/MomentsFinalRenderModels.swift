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
    let provider: String
    let model: String
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
    enum BlockReason {
        case missingProject
        case missingPreview
        case insufficientCredits
        case previewNotReady
    }

    struct Availability {
        let canGenerate: Bool
        let blockReason: BlockReason?
    }

    static func canGenerate(
        project: MomentDraftProject,
        template: MomentTemplate,
        balance: MomentsCreditBalance,
        latestPreview: MomentArtifact?
    ) -> Bool {
        availability(
            project: project,
            template: template,
            balance: balance,
            latestPreview: latestPreview
        ).canGenerate
    }

    static func availability(
        project: MomentDraftProject?,
        template: MomentTemplate,
        balance: MomentsCreditBalance,
        latestPreview: MomentArtifact?
    ) -> Availability {
        guard let project else {
            return Availability(canGenerate: false, blockReason: .missingProject)
        }
        if latestPreview == nil {
            return Availability(canGenerate: false, blockReason: .missingPreview)
        }
        if !MomentsCreditGate.canAfford(template, balance: balance) {
            return Availability(canGenerate: false, blockReason: .insufficientCredits)
        }
        if project.status != "preview_ready" && project.status != "export_ready" {
            return Availability(canGenerate: false, blockReason: .previewNotReady)
        }
        return Availability(canGenerate: true, blockReason: nil)
    }

    static func availabilityMessage(
        _ availability: Availability,
        missingProjectMessage: String,
        insufficientCreditsMessage: String
    ) -> String? {
        switch availability.blockReason {
        case nil:
            return nil
        case .missingProject:
            return missingProjectMessage
        case .missingPreview:
            return "Generate a preview before rendering the final export."
        case .insufficientCredits:
            return insufficientCreditsMessage
        case .previewNotReady:
            return "Wait for a ready preview before rendering the final export."
        }
    }
}
