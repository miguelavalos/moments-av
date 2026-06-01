import Foundation

struct MomentsProjectRenderJobsSectionPresentation: Equatable {
    let title = MomentsL10n.string("project.activity.title")
    let emptySystemImage = "gearshape.2"
    let emptyMessage = MomentsL10n.string("project.activity.empty")
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
            title: MomentsL10n.string("project.kind.storyReview"),
            emptySystemImage: "text.bubble",
            emptyMessage: MomentsL10n.string("project.artifact.preview.empty"),
            artifact: MomentsProjectArtifactPresentation.preview(in: artifacts)
        )
    }

    static func finalExport(artifacts: [MomentArtifact]) -> MomentsProjectArtifactSectionPresentation {
        MomentsProjectArtifactSectionPresentation(
            title: MomentsL10n.string("project.artifact.final.title"),
            emptySystemImage: "video.fill",
            emptyMessage: MomentsL10n.string("project.artifact.final.empty"),
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
        watermarkTitle = artifact.hasWatermark == true ? MomentsL10n.string("project.artifact.included") : MomentsL10n.string("project.artifact.none")
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
        providerTitle = renderJob.provider == nil ? MomentsL10n.string("project.job.notRecorded") : MomentsL10n.string("project.job.recorded")
        modelTitle = renderJob.model == nil ? MomentsL10n.string("project.job.notRecorded") : MomentsL10n.string("project.job.configured")
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
