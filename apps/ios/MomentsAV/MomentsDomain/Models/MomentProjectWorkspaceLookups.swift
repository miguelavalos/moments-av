import Foundation

extension MomentProjectWorkspace {
    func latestArtifact(kind: String) -> MomentArtifact? {
        artifacts.last { $0.kind == kind }
    }

    func hasAvailableArtifact(kind: String) -> Bool {
        artifacts.contains { $0.kind == kind && $0.status == "available" }
    }

    func latestRenderJob(kind: String? = nil) -> MomentRenderJob? {
        renderJobs
            .filter { job in
                guard let kind else { return true }
                return job.kind == kind
            }
            .max { $0.updatedAt < $1.updatedAt }
    }

    var activeFinalRenderJob: MomentRenderJob? {
        renderJobs.first { job in
            job.kind == "final" && ["queued", "running"].contains(job.status)
        }
    }

    var canEditDraftDuringRender: Bool {
        guard let activeFinalRenderJob else { return true }
        return activeFinalRenderJob.canEditDraft ?? false
    }
}

extension MomentRenderJob {
    var isActiveRender: Bool {
        ["queued", "running", "processing", "in_progress"].contains(status)
    }
}
