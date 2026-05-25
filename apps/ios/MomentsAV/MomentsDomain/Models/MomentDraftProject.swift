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
