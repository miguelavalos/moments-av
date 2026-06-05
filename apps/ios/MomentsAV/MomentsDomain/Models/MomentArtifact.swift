import Foundation

struct MomentArtifact: Identifiable, Decodable, Equatable {
    let id: String
    let workflowArtifactId: String?
    let kind: String
    let r2Key: String
    let status: String
    let hasWatermark: Bool?
    let expiresAt: Double

    init(
        id: String,
        workflowArtifactId: String? = nil,
        kind: String,
        r2Key: String,
        status: String,
        hasWatermark: Bool?,
        expiresAt: Double
    ) {
        self.id = id
        self.workflowArtifactId = workflowArtifactId
        self.kind = kind
        self.r2Key = r2Key
        self.status = status
        self.hasWatermark = hasWatermark
        self.expiresAt = expiresAt
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case workflowArtifactId
        case kind
        case r2Key
        case status
        case hasWatermark
        case expiresAt
    }
}
