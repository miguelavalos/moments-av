import Foundation

struct MomentsProjectArtifactPresentation: Equatable {
    let status: String
    let kindTitle: String
    let watermarkTitle: String
    let expiresAtTitle: String
    let storageKey: String

    init(artifact: MomentArtifact) {
        status = artifact.status
        kindTitle = MomentsProjectStatusRules.displayKind(artifact.kind)
        watermarkTitle = artifact.hasWatermark == true ? "Included" : "None"
        expiresAtTitle = MomentsDateFormatting.formattedDate(milliseconds: artifact.expiresAt)
        storageKey = artifact.r2Key
    }

    static func preview(in artifacts: [MomentArtifact]) -> MomentsProjectArtifactPresentation? {
        artifacts.last { $0.kind == "preview" }.map(MomentsProjectArtifactPresentation.init)
    }

    static func finalExport(in artifacts: [MomentArtifact]) -> MomentsProjectArtifactPresentation? {
        artifacts.last { $0.kind == "final_export" }.map(MomentsProjectArtifactPresentation.init)
    }
}

struct MomentsProjectRenderJobPresentation: Identifiable, Equatable {
    let id: String
    let status: String
    let kindTitle: String
    let providerTitle: String
    let modelTitle: String
    let createdAtTitle: String
    let updatedAtTitle: String
    let workflowRunId: String?
    let providerRequestId: String?
    let errorCode: String?
    let errorMessage: String?

    init(renderJob: MomentRenderJob) {
        id = renderJob.id
        status = renderJob.status
        kindTitle = MomentsProjectStatusRules.displayKind(renderJob.kind)
        providerTitle = renderJob.provider ?? "Unknown"
        modelTitle = renderJob.model ?? "Unknown"
        createdAtTitle = MomentsDateFormatting.formattedDate(milliseconds: renderJob.createdAt)
        updatedAtTitle = MomentsDateFormatting.formattedDate(milliseconds: renderJob.updatedAt)
        workflowRunId = renderJob.workflowRunId
        providerRequestId = renderJob.providerRequestId
        errorCode = renderJob.errorCode
        errorMessage = renderJob.errorMessage
    }

    static func sorted(_ renderJobs: [MomentRenderJob]) -> [MomentsProjectRenderJobPresentation] {
        renderJobs
            .sorted { $0.updatedAt > $1.updatedAt }
            .map(MomentsProjectRenderJobPresentation.init)
    }
}
