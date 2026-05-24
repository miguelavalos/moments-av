import Foundation

struct DraftProjectCreationRequest {
    let template: String
    let title: String
    let tone: String
    let tempo: String
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
            template: form.template.id.rawValue,
            title: form.title,
            tone: form.tone.rawValue,
            tempo: form.tempo.rawValue,
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
