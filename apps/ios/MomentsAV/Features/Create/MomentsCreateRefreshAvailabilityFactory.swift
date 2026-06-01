import Foundation

enum MomentsCreateRefreshAvailabilityFactory {
    static func preview(
        projectId: String?,
        job: MomentRenderJob?,
        isAvailable: Bool,
        isConfigured: Bool,
        isRefreshing: Bool
    ) -> RenderJobStatusRefreshAvailability {
        RenderJobStatusRefreshAvailability(
            projectId: projectId,
            job: job,
            isAvailable: isAvailable,
            isConfigured: isConfigured,
            isRefreshing: isRefreshing,
            unavailableMessage: "Story review refresh is not available yet.",
            notConfiguredMessage: "Story review refresh is not configured for this build.",
            missingProjectMessage: "Open a project before refreshing story review status.",
            missingJobMessage: "No story review job is available yet.",
            missingProviderRequestMessage: MomentsRecoveryCopy.previewStatusMissing()
        )
    }

    static func finalRender(
        projectId: String?,
        job: MomentRenderJob?,
        isAvailable: Bool,
        isConfigured: Bool,
        isRefreshing: Bool
    ) -> RenderJobStatusRefreshAvailability {
        RenderJobStatusRefreshAvailability(
            projectId: projectId,
            job: job,
            isAvailable: isAvailable,
            isConfigured: isConfigured,
            isRefreshing: isRefreshing,
            unavailableMessage: "Final status refresh is not available yet.",
            notConfiguredMessage: "Final status refresh is not configured for this build.",
            missingProjectMessage: "Open a project before refreshing final status.",
            missingJobMessage: "No final video is available yet.",
            missingProviderRequestMessage: MomentsRecoveryCopy.finalRenderStatusMissing()
        )
    }
}
