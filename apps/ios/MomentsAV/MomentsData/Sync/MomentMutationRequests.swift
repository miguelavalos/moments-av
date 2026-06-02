import Foundation

struct MomentCreationRequest {
    let creationMode: String
    let look: String
    let theme: String
    let mood: String
    let duration: String
    let mediaUse: String
    let title: String
    let occasion: String
    let details: String
}

struct MomentDeletionRequest {
    let momentId: String
    let deleteSourceMedia: Bool
    let deleteGeneratedArtifacts: Bool
    let reason: String
}

extension MomentCreationRequest {
    static func draft(_ form: MomentDraftForm) -> MomentCreationRequest {
        MomentCreationRequest(
            creationMode: form.creationMode.rawValue,
            look: form.look.rawValue,
            theme: form.theme.rawValue,
            mood: form.tone.rawValue,
            duration: form.duration.rawValue,
            mediaUse: form.mediaUse.rawValue,
            title: form.title,
            occasion: form.occasion,
            details: form.details
        )
    }
}

extension MomentDeletionRequest {
    static func userRequested(momentId: String) -> MomentDeletionRequest {
        MomentDeletionRequest(
            momentId: momentId,
            deleteSourceMedia: true,
            deleteGeneratedArtifacts: true,
            reason: "user request"
        )
    }
}
