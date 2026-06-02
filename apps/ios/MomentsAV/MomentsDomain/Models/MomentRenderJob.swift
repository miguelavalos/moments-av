import Foundation

struct MomentRenderJob: Identifiable, Decodable, Equatable {
    let id: String
    let kind: String
    let status: String
    let phase: String?
    let progressPercent: Double?
    let userMessage: String?
    let canEditSetup: Bool?
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

    init(
        id: String,
        kind: String,
        status: String,
        phase: String? = nil,
        progressPercent: Double? = nil,
        userMessage: String? = nil,
        canEditSetup: Bool? = nil,
        canRetry: Bool? = nil,
        targetDurationMs: Double? = nil,
        plannedAssetCount: Double? = nil,
        usedAssetCount: Double? = nil,
        rejectedAssetCount: Double? = nil,
        rendererMode: String? = nil,
        workflowRunId: String? = nil,
        provider: String? = nil,
        model: String? = nil,
        providerRequestId: String? = nil,
        errorCode: String? = nil,
        errorMessage: String? = nil,
        createdAt: Double,
        updatedAt: Double
    ) {
        self.id = id
        self.kind = kind
        self.status = status
        self.phase = phase
        self.progressPercent = progressPercent
        self.userMessage = userMessage
        self.canEditSetup = canEditSetup
        self.canRetry = canRetry
        self.targetDurationMs = targetDurationMs
        self.plannedAssetCount = plannedAssetCount
        self.usedAssetCount = usedAssetCount
        self.rejectedAssetCount = rejectedAssetCount
        self.rendererMode = rendererMode
        self.workflowRunId = workflowRunId
        self.provider = provider
        self.model = model
        self.providerRequestId = providerRequestId
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case kind
        case status
        case phase
        case progressPercent
        case userMessage
        case canEditSetup
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
