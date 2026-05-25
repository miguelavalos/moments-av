import Foundation

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
