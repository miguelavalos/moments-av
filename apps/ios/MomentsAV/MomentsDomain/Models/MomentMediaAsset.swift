import Foundation

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
