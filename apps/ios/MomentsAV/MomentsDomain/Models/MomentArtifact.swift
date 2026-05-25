import Foundation

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
