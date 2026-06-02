import Foundation

struct MomentsPreviewRequest: Encodable {
    let appId = "momentsav"
    let momentId: String
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
    let momentId: String
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

    static func canGenerate(moment: InProgressMoment, template: MomentTemplate, balance: MomentsCreditBalance) -> Bool {
        availability(moment: moment, template: template, balance: balance).canGenerate
    }

    static func availability(
        moment: InProgressMoment?,
        template: MomentTemplate,
        balance: MomentsCreditBalance
    ) -> Availability {
        guard let moment else {
            return Availability(canGenerate: false, blockReason: .missingProject)
        }
        if Int(moment.previewCount) >= Int(moment.previewLimit) {
            return Availability(canGenerate: false, blockReason: .previewLimitReached)
        }
        if moment.status != "story_ready" && moment.status != "preview_ready" {
            return Availability(canGenerate: false, blockReason: .storyNotReady)
        }
        return Availability(canGenerate: true, blockReason: nil)
    }

    static func availabilityMessage(
        _ availability: Availability,
        missingMomentMessage: String,
        insufficientCreditsMessage: String
    ) -> String? {
        switch availability.blockReason {
        case nil:
            return nil
        case .missingProject:
            return missingMomentMessage
        case .previewLimitReached:
            return "Story Review limit reached for this Moment."
        case .insufficientCredits:
            return insufficientCreditsMessage
        case .storyNotReady:
            return "Generate a story before reviewing it."
        }
    }
}
