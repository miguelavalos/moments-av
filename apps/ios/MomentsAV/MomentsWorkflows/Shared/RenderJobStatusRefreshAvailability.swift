import Foundation

struct RenderJobStatusRefreshAvailability {
    let momentId: String?
    let job: MomentRenderJob?
    let isAvailable: Bool
    let isConfigured: Bool
    let isRefreshing: Bool
    let unavailableMessage: String
    let notConfiguredMessage: String
    let missingMomentMessage: String
    let missingJobMessage: String
    let missingProviderRequestMessage: String

    var message: String? {
        guard momentId != nil else { return missingMomentMessage }
        if !isAvailable { return unavailableMessage }
        if isRefreshing { return nil }
        if !isConfigured { return notConfiguredMessage }
        guard let job else { return missingJobMessage }
        if job.providerRequestId == nil { return missingProviderRequestMessage }
        return nil
    }

    var canRefresh: Bool {
        momentId != nil
            && !isRefreshing
            && isAvailable
            && isConfigured
            && job?.providerRequestId != nil
    }
}
