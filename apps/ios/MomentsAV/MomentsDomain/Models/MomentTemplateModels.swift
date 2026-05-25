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
        title: "Birthday Message",
        durationSeconds: 30,
        creditCost: 2,
        minimumAssets: 3,
        maximumAssets: 20,
        summary: "A warm greeting built from selected memories and captions."
    )

    static let partyRecap = MomentTemplate(
        id: .partyRecap,
        title: "Party Recap",
        durationSeconds: 45,
        creditCost: 3,
        minimumAssets: 6,
        maximumAssets: 40,
        summary: "A quick montage for gatherings, trips, and shared celebrations."
    )

    static let softRoast = MomentTemplate(
        id: .softRoast,
        title: "Soft Roast",
        durationSeconds: 30,
        creditCost: 2,
        minimumAssets: 3,
        maximumAssets: 20,
        summary: "Light, affectionate humor for people who are in on the joke."
    )

    static let launchTemplates = [
        birthdayMessage,
        partyRecap,
        softRoast
    ]
}
