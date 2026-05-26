import Foundation

enum MomentMusicPreset: String, CaseIterable, Identifiable {
    case warm
    case fun
    case cinematic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warm: "Warm"
        case .fun: "Fun"
        case .cinematic: "Cinematic"
        }
    }
}

enum MomentCreationStyleID: String, CaseIterable, Identifiable {
    case celebration
    case eventRecap
    case travel
    case favoritePeople
    case birthday
    case familyMoments
    case softRoast
    case custom

    var id: String { rawValue }
}

struct MomentCreationStyle: Identifiable, Equatable {
    let id: MomentCreationStyleID
    let title: String
    let subtitle: String
    let assetName: String
    let template: MomentTemplate
    let defaultMusic: MomentMusicPreset
    let allowedMusic: [MomentMusicPreset]
    let tone: MomentDraftTone
    let tempo: MomentDraftTempo
    let isEnabled: Bool

    var durationSeconds: Int { 15 }
    var creditCost: Int { 1 }
    var minimumAssets: Int { 1 }
    var recommendedAssets: ClosedRange<Int> { 3...12 }
    var maximumAssets: Int { 12 }

    static let launchStyles: [MomentCreationStyle] = [
        MomentCreationStyle(
            id: .celebration,
            title: "Celebration",
            subtitle: "Warm, bright, and ready fast.",
            assetName: "StyleCelebration",
            template: .birthdayMessage,
            defaultMusic: .warm,
            allowedMusic: [.warm, .fun, .cinematic],
            tone: .warm,
            tempo: .balanced,
            isEnabled: true
        ),
        MomentCreationStyle(
            id: .eventRecap,
            title: "Event Recap",
            subtitle: "Fast highlights with social energy.",
            assetName: "StyleEventRecap",
            template: .partyRecap,
            defaultMusic: .fun,
            allowedMusic: [.fun, .warm, .cinematic],
            tone: .playful,
            tempo: .upbeat,
            isEnabled: true
        ),
        MomentCreationStyle(
            id: .travel,
            title: "Travel",
            subtitle: "Cinematic, scenic, and relaxed.",
            assetName: "StyleTravel",
            template: .birthdayMessage,
            defaultMusic: .cinematic,
            allowedMusic: [.cinematic, .warm, .fun],
            tone: .cinematic,
            tempo: .gentle,
            isEnabled: true
        ),
        MomentCreationStyle(
            id: .favoritePeople,
            title: "Favorite People",
            subtitle: "Close, personal, and tender.",
            assetName: "StyleFavoritePeople",
            template: .birthdayMessage,
            defaultMusic: .warm,
            allowedMusic: [.warm, .cinematic, .fun],
            tone: .warm,
            tempo: .gentle,
            isEnabled: true
        ),
        MomentCreationStyle(
            id: .birthday,
            title: "Birthday",
            subtitle: "A small video gift.",
            assetName: "StyleBirthday",
            template: .birthdayMessage,
            defaultMusic: .warm,
            allowedMusic: [.warm, .fun, .cinematic],
            tone: .warm,
            tempo: .balanced,
            isEnabled: true
        ),
        MomentCreationStyle(
            id: .familyMoments,
            title: "Family Moments",
            subtitle: "Soft, safe, and everyday-warm.",
            assetName: "StyleFamilyMoments",
            template: .birthdayMessage,
            defaultMusic: .warm,
            allowedMusic: [.warm, .cinematic],
            tone: .warm,
            tempo: .gentle,
            isEnabled: true
        ),
        MomentCreationStyle(
            id: .softRoast,
            title: "Soft Roast",
            subtitle: "Playful, kind, never mean.",
            assetName: "StyleSoftRoast",
            template: .softRoast,
            defaultMusic: .fun,
            allowedMusic: [.fun, .warm],
            tone: .playful,
            tempo: .upbeat,
            isEnabled: true
        ),
        MomentCreationStyle(
            id: .custom,
            title: "Custom",
            subtitle: "Coming soon",
            assetName: "StyleCustom",
            template: .birthdayMessage,
            defaultMusic: .warm,
            allowedMusic: [.warm],
            tone: .warm,
            tempo: .balanced,
            isEnabled: false
        )
    ]
}
