import Foundation

enum MomentDraftTone: String, CaseIterable, Identifiable {
    case warm
    case playful
    case cinematic
    case calm
    case upbeat

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warm: L10n.string("create.tone.warm.title")
        case .playful: L10n.string("create.tone.playful.title")
        case .cinematic: L10n.string("create.tone.cinematic.title")
        case .calm: L10n.string("create.tone.calm.title")
        case .upbeat: L10n.string("create.tone.upbeat.title")
        }
    }
}

enum MomentDraftTempo: String, CaseIterable, Identifiable {
    case gentle
    case balanced
    case upbeat

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle: L10n.string("create.tempo.gentle.title")
        case .balanced: L10n.string("create.tempo.balanced.title")
        case .upbeat: L10n.string("create.tempo.upbeat.title")
        }
    }
}

extension MomentDraftTone {
    init(musicPreset: MomentMusicPreset) {
        switch musicPreset {
        case .warm:
            self = .warm
        case .fun:
            self = .playful
        case .cinematic:
            self = .cinematic
        case .calm:
            self = .calm
        case .upbeat:
            self = .upbeat
        }
    }
}

struct MomentDraftForm: Equatable {
    var creationMode: MomentCreationMode = .quick
    var look: MomentLook = .real
    var theme: MomentCreationStyleID = .celebration
    var duration: MomentDuration = .auto
    var mediaUse: MomentMediaUse = .aviPick
    var template: MomentTemplate
    var occasion = "Birthday"
    var recipient = ""
    var tone: MomentDraftTone = .warm
    var tempo: MomentDraftTempo = .balanced
    var details = ""

    var title: String {
        let trimmedRecipient = recipient.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedOccasion = occasion.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectTitle = trimmedOccasion.isEmpty ? template.title : trimmedOccasion
        return trimmedRecipient.isEmpty ? projectTitle : "\(projectTitle) for \(trimmedRecipient)"
    }

    var canCreateDraft: Bool {
        !occasion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func continuing(
        moment: InProgressMoment,
        templates: [MomentTemplate]
    ) -> MomentDraftForm? {
        guard let template = templates.first(where: { $0.id == moment.template }) else {
            return nil
        }

        var form = MomentDraftForm(
            template: template,
            occasion: moment.occasion ?? "",
            recipient: "",
            tone: MomentDraftTone(rawValue: moment.mood ?? moment.tone ?? "") ?? .warm,
            tempo: MomentDraftTempo(rawValue: moment.tempo ?? "") ?? .balanced,
            details: moment.details ?? ""
        )
        form.creationMode = MomentCreationMode(rawValue: moment.creationMode) ?? .quick
        form.look = MomentLook(rawValue: moment.look) ?? .real
        form.theme = MomentCreationStyleID(rawValue: moment.theme) ?? .celebration
        form.duration = MomentDuration(rawValue: moment.duration) ?? .auto
        form.mediaUse = MomentMediaUse(rawValue: moment.mediaUse) ?? .aviPick
        return form
    }
}

enum MomentDraftRules {
    enum BlockReason {
        case missingOccasion
    }

    struct Availability {
        let canCreateDraft: Bool
        let blockReason: BlockReason?
    }

    static func availability(
        form: MomentDraftForm,
        balance: MomentsCreditBalance
    ) -> Availability {
        guard !form.occasion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Availability(canCreateDraft: false, blockReason: .missingOccasion)
        }

        return Availability(canCreateDraft: true, blockReason: nil)
    }

    static func availabilityMessage(_ availability: Availability) -> String? {
        switch availability.blockReason {
        case nil:
            return nil
        case .missingOccasion:
            return L10n.string("create.rules.missingOccasion")
        }
    }
}
