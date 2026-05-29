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
        title: "Celebration",
        durationSeconds: 15,
        creditCost: 1,
        minimumAssets: 1,
        maximumAssets: 20,
        summary: "A warm, edited memory video from selected photos and clips."
    )

    static let partyRecap = MomentTemplate(
        id: .partyRecap,
        title: "Event Recap",
        durationSeconds: 15,
        creditCost: 1,
        minimumAssets: 1,
        maximumAssets: 20,
        summary: "A faster, rhythmic recap using the strongest moments."
    )

    static let softRoast = MomentTemplate(
        id: .softRoast,
        title: "Soft Roast",
        durationSeconds: 15,
        creditCost: 1,
        minimumAssets: 1,
        maximumAssets: 20,
        summary: "Light, affectionate humor edited from real moments."
    )

    static let launchTemplates = [
        birthdayMessage,
        partyRecap,
        softRoast
    ]
}
