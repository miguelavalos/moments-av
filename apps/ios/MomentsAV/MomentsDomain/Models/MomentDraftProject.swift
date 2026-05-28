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
    let storyInputSignature: String?
    let durationSeconds: Double
    let creditCost: Double
    let previewCount: Double
    let previewLimit: Double
    let updatedAt: Double

    init(
        id: String,
        template: MomentTemplateID,
        status: String,
        title: String,
        tone: String?,
        tempo: String?,
        occasion: String?,
        details: String?,
        storyInputSignature: String? = nil,
        durationSeconds: Double,
        creditCost: Double,
        previewCount: Double,
        previewLimit: Double,
        updatedAt: Double
    ) {
        self.id = id
        self.template = template
        self.status = status
        self.title = title
        self.tone = tone
        self.tempo = tempo
        self.occasion = occasion
        self.details = details
        self.storyInputSignature = storyInputSignature
        self.durationSeconds = durationSeconds
        self.creditCost = creditCost
        self.previewCount = previewCount
        self.previewLimit = previewLimit
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case template
        case status
        case title
        case tone
        case tempo
        case occasion
        case details
        case storyInputSignature
        case durationSeconds
        case creditCost
        case previewCount
        case previewLimit
        case updatedAt
    }
}
