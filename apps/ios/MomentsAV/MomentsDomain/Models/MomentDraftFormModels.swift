import Foundation

enum MomentDraftTone: String, CaseIterable, Identifiable {
    case warm
    case playful
    case cinematic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warm: "Warm"
        case .playful: "Playful"
        case .cinematic: "Cinematic"
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
        case .gentle: "Gentle"
        case .balanced: "Balanced"
        case .upbeat: "Upbeat"
        }
    }
}

struct MomentDraftForm: Equatable {
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
        project: MomentDraftProject,
        templates: [MomentTemplate]
    ) -> MomentDraftForm? {
        guard let template = templates.first(where: { $0.id == project.template }) else {
            return nil
        }

        return MomentDraftForm(
            template: template,
            occasion: project.occasion ?? "",
            recipient: "",
            tone: MomentDraftTone(rawValue: project.tone ?? "") ?? .warm,
            tempo: MomentDraftTempo(rawValue: project.tempo ?? "") ?? .balanced,
            details: project.details ?? ""
        )
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
            return "Complete the occasion before starting a project."
        }
    }
}
