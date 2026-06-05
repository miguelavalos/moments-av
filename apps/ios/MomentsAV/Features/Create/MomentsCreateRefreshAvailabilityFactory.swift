import Foundation

enum MomentsCreateRefreshAvailabilityFactory {
    static func preview(
        momentId: String?,
        job: MomentRenderJob?,
        isAvailable: Bool,
        isConfigured: Bool,
        isRefreshing: Bool
    ) -> RenderJobStatusRefreshAvailability {
        RenderJobStatusRefreshAvailability(
            momentId: momentId,
            job: job,
            isAvailable: isAvailable,
            isConfigured: isConfigured,
            isRefreshing: isRefreshing,
            unavailableMessage: L10n.string("create.refresh.preview.unavailable"),
            notConfiguredMessage: L10n.string("create.refresh.preview.notConfigured"),
            missingMomentMessage: L10n.string("create.refresh.preview.missingMoment"),
            missingJobMessage: L10n.string("create.refresh.preview.missingJob"),
            missingProviderRequestMessage: MomentsRecoveryCopy.previewStatusMissing()
        )
    }
}
