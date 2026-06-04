import Foundation

struct MomentsFinalRenderRequest: Encodable {
    let appId = "momentsav"
    let momentId: String
    let creationMode: String
    let look: String
    let theme: String
    let mood: String
    let duration: String
    let mediaUse: String
    let occasion: String?
    let details: String?
    let creditCost: Int
    let removeWatermark: Bool
    let safetyAcknowledged = true
    let idempotencyKey: String
}

struct MomentsFinalRenderResponse: Decodable, Equatable {
    let appId: String
    let momentId: String
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
    let baseCreditCost: Int?
    let watermarkRemovalCreditCost: Int?
    let creditsCommitted: Int
    let generatedAt: String
}

struct MomentsCreditReservationRequest: Encodable {
    let appId = "momentsav"
    let momentId: String
    let amount: Int
    let idempotencyKey: String
}

struct MomentsCreditReservationResponse: Decodable, Equatable {
    let id: String
    let appId: String
    let userId: String?
    let momentId: String
    let workflowRunId: String?
    let amount: Int
    let status: String
    let idempotencyKey: String?
    let expiresAt: String
    let createdAt: String
    let updatedAt: String
}

struct MomentsStartWorkflowRequest: Encodable {
    let appId = "momentsav"
    let momentId: String
    let renderKind: String
    let creationMode: String
    let look: String
    let theme: String
    let mood: String
    let duration: String
    let mediaUse: String
    let occasion: String?
    let details: String?
    let creditCost: Int
    let removeWatermark: Bool
    let safetyAcknowledged = true
    let idempotencyKey: String
    let reservationId: String
    let renderOptionId: String?
}

struct MomentsStartWorkflowResponse: Decodable, Equatable {
    let appId: String
    let momentId: String
    let renderJobId: String
    let workflowRunId: String
    let status: String
    let startedAt: String
}

struct MomentsRenderPlanRequest: Encodable {
    let appId = "momentsav"
    let momentId: String
    let creationMode: String
    let look: String
    let theme: String
    let mood: String
    let duration: String
    let mediaUse: String
    let occasion: String?
    let details: String?
    let creditCost: Int
    let removeWatermark: Bool
    let renderOptionId: String?
}

struct MomentsConfirmFinalRenderRequest: Encodable {
    let appId = "momentsav"
    let momentId: String
    let creationMode: String
    let look: String
    let theme: String
    let mood: String
    let duration: String
    let mediaUse: String
    let occasion: String?
    let details: String?
    let creditCost: Int
    let removeWatermark: Bool
    let renderOptionId: String?
    let planId: String
    let idempotencyKey: String
}

struct MomentsConfirmFinalRenderResponse: Decodable, Equatable {
    let appId: String
    let momentId: String
    let planId: String
    let reservation: MomentsCreditReservationResponse
    let workflow: MomentsStartWorkflowResponse
    let renderPlan: MomentsRenderPlanResponse
    let confirmedAt: String
}

struct MomentsRenderPlanResponse: Decodable, Equatable {
    let appId: String
    let momentId: String
    let planId: String
    let watermark: MomentsRenderWatermarkPlan?
    let plan: MomentsRenderPlan
    let canCreateVideo: Bool
    let generatedAt: String
}

struct MomentsRenderWatermarkPlan: Decodable, Equatable {
    let includedForPro: Bool
    let userHasWatermarkFree: Bool
    let nonProRemovalCreditCost: Int
    let selectedRemoveWatermark: Bool
    let watermarkCreditCost: Int
}

struct MomentsArtifactDownloadRequest: Encodable {
    let appId = "momentsav"
    let momentId: String
    let artifactId: String
}

struct MomentsArtifactDownloadResponse: Decodable, Equatable {
    let appId: String
    let momentId: String
    let artifactId: String
    let artifactKind: String
    let downloadUrl: String
    let method: String
    let headers: [String: String]
    let r2Key: String
    let expiresAt: String
    let generatedAt: String
}

struct MomentsRenderPlan: Decodable, Equatable {
    let schemaVersion: Int?
    let targetDurationMs: Int
    let creditCost: Int
    let totalCreditCost: Int
    let secondsPerCredit: Int
    let plannedAssetCount: Int
    let usedAssetCount: Int
    let rejectedAssetCount: Int
    let rendererMode: String
    let renderOptionId: String?
    let renderOptionTitle: String?
    let userMessage: String
    let qualityWarnings: [String]
}

enum MomentsFinalRenderRules {
    enum BlockReason {
        case missingMoment
        case insufficientCredits
        case storyNotReady
    }

    struct Availability {
        let canGenerate: Bool
        let blockReason: BlockReason?
    }

    static func canGenerate(
        moment: InProgressMoment,
        template: MomentTemplate,
        balance: MomentsCreditBalance,
        storySceneCount: Int = 0
    ) -> Bool {
        availability(
            moment: moment,
            template: template,
            balance: balance,
            storySceneCount: storySceneCount
        ).canGenerate
    }

    static func canPreparePlan(moment: InProgressMoment?, storySceneCount: Int = 0) -> Bool {
        if storySceneCount > 0 { return true }
        guard let moment else { return false }
        return moment.status == "story_ready"
            || moment.status == "preview_ready"
            || moment.status == "gallery_ready"
    }

    static func availability(
        moment: InProgressMoment?,
        template: MomentTemplate,
        balance: MomentsCreditBalance,
        storySceneCount: Int = 0
    ) -> Availability {
        guard let moment else {
            return Availability(canGenerate: false, blockReason: .missingMoment)
        }
        if !canPreparePlan(moment: moment, storySceneCount: storySceneCount) {
            return Availability(canGenerate: false, blockReason: .storyNotReady)
        }
        if !MomentsCreditGate.canAfford(template, balance: balance) {
            return Availability(canGenerate: false, blockReason: .insufficientCredits)
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
        case .missingMoment:
            return missingMomentMessage
        case .insufficientCredits:
            return insufficientCreditsMessage
        case .storyNotReady:
            return "Prepare the story before creating the final video."
        }
    }
}
