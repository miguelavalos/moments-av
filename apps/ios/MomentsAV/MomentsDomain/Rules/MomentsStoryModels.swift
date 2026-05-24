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
    enum BlockReason {
        case missingMedia
        case tooFewSelectedMedia(missingCount: Int)
        case tooManySelectedMedia(extraCount: Int)
    }

    struct Availability {
        let canDraft: Bool
        let blockReason: BlockReason?
    }

    static func canDraft(mediaAssets: [MomentMediaAsset], template: MomentTemplate) -> Bool {
        availability(mediaAssets: mediaAssets, template: template).canDraft
    }

    static func availability(
        mediaAssets: [MomentMediaAsset]?,
        template: MomentTemplate
    ) -> Availability {
        guard let mediaAssets else {
            return Availability(canDraft: false, blockReason: .missingMedia)
        }

        let selectedCount = mediaAssets.filter(\.selected).count
        switch MomentsMediaRules.availability(template: template, selectedCount: selectedCount).blockReason {
        case nil:
            return Availability(canDraft: true, blockReason: nil)
        case .tooFewSelected(let missingCount):
            return Availability(
                canDraft: false,
                blockReason: .tooFewSelectedMedia(missingCount: missingCount)
            )
        case .tooManySelected(let extraCount):
            return Availability(
                canDraft: false,
                blockReason: .tooManySelectedMedia(extraCount: extraCount)
            )
        }
    }

    static func availabilityMessage(_ availability: Availability, missingMediaMessage: String) -> String? {
        switch availability.blockReason {
        case nil:
            return nil
        case .missingMedia:
            return missingMediaMessage
        case .tooFewSelectedMedia(let missingCount):
            return "Add \(missingCount) more synced media assets before drafting."
        case .tooManySelectedMedia(let extraCount):
            return "Remove \(extraCount) synced media assets before drafting."
        }
    }
}
