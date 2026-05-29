import Foundation

struct MomentRenderJob: Identifiable, Decodable, Equatable {
    let id: String
    let kind: String
    let status: String
    let phase: String?
    let progressPercent: Double?
    let userMessage: String?
    let canEditDraft: Bool?
    let canRetry: Bool?
    let targetDurationMs: Double?
    let plannedAssetCount: Double?
    let usedAssetCount: Double?
    let rejectedAssetCount: Double?
    let rendererMode: String?
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
        case phase
        case progressPercent
        case userMessage
        case canEditDraft
        case canRetry
        case targetDurationMs
        case plannedAssetCount
        case usedAssetCount
        case rejectedAssetCount
        case rendererMode
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
