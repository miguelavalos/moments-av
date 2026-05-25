import Foundation

enum MomentTemplateID: String, CaseIterable, Identifiable, Codable {
    case birthdayMessage = "birthday_message"
    case partyRecap = "party_recap"
    case softRoast = "soft_roast"

    var id: String { rawValue }
}

struct MomentTemplate: Identifiable, Equatable {
    let id: MomentTemplateID
    let title: String
    let durationSeconds: Int
    let creditCost: Int
    let minimumAssets: Int
    let maximumAssets: Int
    let summary: String

    var duration: String {
        "\(durationSeconds) sec"
    }

    var mediaRange: String {
        "\(minimumAssets)-\(maximumAssets) photos or clips"
    }

    static let birthdayMessage = MomentTemplate(
        id: .birthdayMessage,
        title: "Birthday Message",
        durationSeconds: 30,
        creditCost: 2,
        minimumAssets: 3,
        maximumAssets: 20,
        summary: "A warm greeting built from selected memories and captions."
    )

    static let partyRecap = MomentTemplate(
        id: .partyRecap,
        title: "Party Recap",
        durationSeconds: 45,
        creditCost: 3,
        minimumAssets: 6,
        maximumAssets: 40,
        summary: "A quick montage for gatherings, trips, and shared celebrations."
    )

    static let softRoast = MomentTemplate(
        id: .softRoast,
        title: "Soft Roast",
        durationSeconds: 30,
        creditCost: 2,
        minimumAssets: 3,
        maximumAssets: 20,
        summary: "Light, affectionate humor for people who are in on the joke."
    )

    static let launchTemplates = [
        birthdayMessage,
        partyRecap,
        softRoast
    ]
}

enum MomentDraftTone: String, CaseIterable, Identifiable {
    case warm
    case playful
    case cinematic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warm: "Warm"
        case .playful: "Playful"
        case .cinematic: "Cinematic"
        }
    }
}

enum MomentDraftTempo: String, CaseIterable, Identifiable {
    case gentle
    case balanced
    case upbeat

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle: "Gentle"
        case .balanced: "Balanced"
        case .upbeat: "Upbeat"
        }
    }
}

struct MomentDraftForm: Equatable {
    var template: MomentTemplate
    var occasion = "Birthday"
    var recipient = ""
    var tone: MomentDraftTone = .warm
    var tempo: MomentDraftTempo = .balanced
    var details = ""

    var title: String {
        let trimmedRecipient = recipient.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedRecipient.isEmpty ? template.title : "\(template.title) for \(trimmedRecipient)"
    }

    var canCreateDraft: Bool {
        !occasion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

enum MomentDraftRules {
    enum BlockReason {
        case missingOccasion
        case insufficientCredits(missingCount: Int)
    }

    struct Availability {
        let canCreateDraft: Bool
        let blockReason: BlockReason?
    }

    static func availability(
        form: MomentDraftForm,
        balance: MomentsCreditBalance
    ) -> Availability {
        guard !form.occasion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Availability(canCreateDraft: false, blockReason: .missingOccasion)
        }

        let missingCredits = max(form.template.creditCost - balance.spendable, 0)
        guard missingCredits == 0 else {
            return Availability(canCreateDraft: false, blockReason: .insufficientCredits(missingCount: missingCredits))
        }

        return Availability(canCreateDraft: true, blockReason: nil)
    }

    static func availabilityMessage(_ availability: Availability) -> String? {
        switch availability.blockReason {
        case nil:
            return nil
        case .missingOccasion:
            return "Complete the occasion before creating a draft."
        case .insufficientCredits(let missingCount):
            return "Add \(missingCount) more \(creditLabel(missingCount)) for this template."
        }
    }

    private static func creditLabel(_ count: Int) -> String {
        count == 1 ? "credit" : "credits"
    }
}

struct MomentDraftProject: Identifiable, Decodable, Equatable {
    let id: String
    let template: MomentTemplateID
    let status: String
    let title: String
    let tone: String?
    let tempo: String?
    let occasion: String?
    let details: String?
    let durationSeconds: Double
    let creditCost: Double
    let previewCount: Double
    let previewLimit: Double
    let updatedAt: Double

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case template
        case status
        case title
        case tone
        case tempo
        case occasion
        case details
        case durationSeconds
        case creditCost
        case previewCount
        case previewLimit
        case updatedAt
    }
}

struct MomentMediaAsset: Identifiable, Decodable, Equatable {
    let id: String
    let platformMediaAssetId: String?
    let uploadId: String?
    let kind: String
    let sortOrder: Double
    let selected: Bool
    let moderationStatus: String
    let uploadedAt: Double?
    let sourceExpiresAt: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case platformMediaAssetId
        case uploadId
        case kind
        case sortOrder
        case selected
        case moderationStatus
        case uploadedAt
        case sourceExpiresAt
    }
}

struct MomentStoryScene: Identifiable, Decodable, Equatable {
    let id: String
    let sceneIndex: Double
    let mediaAssetIds: [String]
    let caption: String
    let narrationText: String?
    let tone: String?
    let musicCue: String?
    let durationMs: Double
    let createdBy: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case sceneIndex
        case mediaAssetIds
        case caption
        case narrationText
        case tone
        case musicCue
        case durationMs
        case createdBy
    }
}

struct MomentArtifact: Identifiable, Decodable, Equatable {
    let id: String
    let kind: String
    let r2Key: String
    let status: String
    let hasWatermark: Bool?
    let expiresAt: Double

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case kind
        case r2Key
        case status
        case hasWatermark
        case expiresAt
    }
}

struct MomentRenderJob: Identifiable, Decodable, Equatable {
    let id: String
    let kind: String
    let status: String
    let workflowRunId: String?
    let provider: String?
    let model: String?
    let providerRequestId: String?
    let errorCode: String?
    let errorMessage: String?
    let createdAt: Double
    let updatedAt: Double

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case kind
        case status
        case workflowRunId
        case provider
        case model
        case providerRequestId
        case errorCode
        case errorMessage
        case createdAt
        case updatedAt
    }
}

struct MomentProjectWorkspace: Decodable, Equatable {
    let project: MomentDraftProject
    let mediaAssets: [MomentMediaAsset]
    let storyScenes: [MomentStoryScene]
    let renderJobs: [MomentRenderJob]
    let artifacts: [MomentArtifact]
}
