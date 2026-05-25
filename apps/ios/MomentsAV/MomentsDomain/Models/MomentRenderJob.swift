import Foundation

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
