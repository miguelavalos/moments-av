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
            unavailableMessage: "Preview status refresh is not available yet.",
            notConfiguredMessage: "Preview status refresh is not configured for this build.",
            missingProjectMessage: "Open a project before refreshing preview status.",
            missingJobMessage: "No preview render job is available yet.",
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
            missingJobMessage: "No final render job is available yet.",
            missingProviderRequestMessage: MomentsRecoveryCopy.finalRenderStatusMissing()
        )
    }
}
