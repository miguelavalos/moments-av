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
            unavailableMessage: L10n.string("create.refresh.preview.unavailable"),
            notConfiguredMessage: L10n.string("create.refresh.preview.notConfigured"),
            missingProjectMessage: L10n.string("create.refresh.preview.missingProject"),
            missingJobMessage: L10n.string("create.refresh.preview.missingJob"),
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
            unavailableMessage: L10n.string("create.refresh.final.unavailable"),
            notConfiguredMessage: L10n.string("create.refresh.final.notConfigured"),
            missingProjectMessage: L10n.string("create.refresh.final.missingProject"),
            missingJobMessage: L10n.string("create.refresh.final.missingJob"),
            missingProviderRequestMessage: MomentsRecoveryCopy.finalRenderStatusMissing()
        )
    }
}
