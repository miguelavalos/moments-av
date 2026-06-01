import Foundation

struct MomentsPreviewRequest: Encodable {
    let appId = "momentsav"
    let projectId: String
    let creationMode: String
    let look: String
    let theme: String
    let mood: String
    let duration: String
    let mediaUse: String
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
    enum BlockReason {
        case missingProject
        case previewLimitReached
        case insufficientCredits
        case storyNotReady
    }

    struct Availability {
        let canGenerate: Bool
        let blockReason: BlockReason?
    }

    static func canGenerate(project: MomentDraftProject, template: MomentTemplate, balance: MomentsCreditBalance) -> Bool {
        availability(project: project, template: template, balance: balance).canGenerate
    }

    static func availability(
        project: MomentDraftProject?,
        template: MomentTemplate,
        balance: MomentsCreditBalance
    ) -> Availability {
        guard let project else {
            return Availability(canGenerate: false, blockReason: .missingProject)
        }
        if Int(project.previewCount) >= Int(project.previewLimit) {
            return Availability(canGenerate: false, blockReason: .previewLimitReached)
        }
        if project.status != "story_ready" && project.status != "preview_ready" {
            return Availability(canGenerate: false, blockReason: .storyNotReady)
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
        case .previewLimitReached:
            return "Story Review limit reached for this project."
        case .insufficientCredits:
            return insufficientCreditsMessage
        case .storyNotReady:
            return "Generate a story before reviewing it."
        }
    }
}
