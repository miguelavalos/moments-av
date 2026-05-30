import Foundation

struct MomentsProjectRenderJobsSectionPresentation: Equatable {
    let title = "Render jobs"
    let emptySystemImage = "gearshape.2"
    let emptyMessage = "Preview and final render jobs will appear here."
    let jobs: [MomentsProjectRenderJobPresentation]

    init(renderJobs: [MomentRenderJob]) {
        jobs = MomentsProjectRenderJobPresentation.sorted(renderJobs)
    }
}

struct MomentsProjectArtifactSectionPresentation: Equatable {
    let title: String
    let emptySystemImage: String
    let emptyMessage: String
    let artifact: MomentsProjectArtifactPresentation?

    static func preview(artifacts: [MomentArtifact]) -> MomentsProjectArtifactSectionPresentation {
        MomentsProjectArtifactSectionPresentation(
            title: "Preview",
            emptySystemImage: "play.rectangle",
            emptyMessage: "Generate a preview after the story draft is ready.",
            artifact: MomentsProjectArtifactPresentation.preview(in: artifacts)
        )
    }

    static func finalExport(artifacts: [MomentArtifact]) -> MomentsProjectArtifactSectionPresentation {
        MomentsProjectArtifactSectionPresentation(
            title: "Final export",
            emptySystemImage: "square.and.arrow.up",
            emptyMessage: "Render the final export after approving a preview.",
            artifact: MomentsProjectArtifactPresentation.finalExport(in: artifacts)
        )
    }
}

struct MomentsProjectArtifactPresentation: Equatable {
    let status: String
    let kindTitle: String
    let watermarkTitle: String
    let expiresAtTitle: String
    let storageKey: String
    let actionDetail: String

    init(artifact: MomentArtifact) {
        status = artifact.status
        kindTitle = MomentsProjectStatusRules.displayKind(artifact.kind)
        watermarkTitle = artifact.hasWatermark == true ? "Included" : "None"
        expiresAtTitle = MomentsDateFormatting.formattedDate(milliseconds: artifact.expiresAt)
        storageKey = artifact.r2Key
        actionDetail = MomentsRecoveryCopy.artifactActionDetail(kind: artifact.kind, status: artifact.status)
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
        errorMessage = renderJob.status == "failed"
            ? MomentsRecoveryCopy.failedRenderDetail(
                userMessage: renderJob.userMessage,
                errorMessage: renderJob.errorMessage
            )
            : renderJob.errorMessage
    }

    static func sorted(_ renderJobs: [MomentRenderJob]) -> [MomentsProjectRenderJobPresentation] {
        renderJobs
            .sorted { $0.updatedAt > $1.updatedAt }
            .map(MomentsProjectRenderJobPresentation.init)
    }
}
