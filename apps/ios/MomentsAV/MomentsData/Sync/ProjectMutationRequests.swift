import Foundation

struct DraftProjectCreationRequest {
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

struct ProjectDeletionRequest {
    let projectId: String
    let deleteSourceMedia: Bool
    let deleteGeneratedArtifacts: Bool
    let reason: String
}

extension DraftProjectCreationRequest {
    static func draft(_ form: MomentDraftForm) -> DraftProjectCreationRequest {
        DraftProjectCreationRequest(
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

extension ProjectDeletionRequest {
    static func userRequested(projectId: String) -> ProjectDeletionRequest {
        ProjectDeletionRequest(
            projectId: projectId,
            deleteSourceMedia: true,
            deleteGeneratedArtifacts: true,
            reason: "user request"
        )
    }
}
