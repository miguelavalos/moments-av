import Foundation

struct RenderResultPersistenceRequest {
    let renderKind: String
    let artifactKind: String
    let workflowRunId: String
    let creditReservationId: String?
    let provider: String
    let model: String
    let providerRequestId: String
    let r2Key: String
    let durationSeconds: Int
    let creditCost: Int
    let hasWatermark: Bool
    let status: String
}

extension RenderResultPersistenceRequest {
    static func preview(
        _ preview: MomentsPreviewResponse,
        template: MomentTemplate
    ) -> RenderResultPersistenceRequest {
        RenderResultPersistenceRequest(
            renderKind: "preview",
            artifactKind: "preview",
            workflowRunId: preview.workflowRunId,
            creditReservationId: nil,
            provider: preview.provider,
            model: preview.model,
            providerRequestId: preview.renderJobId,
            r2Key: preview.r2Key,
            durationSeconds: template.durationSeconds,
            creditCost: 0,
            hasWatermark: preview.hasWatermark,
            status: preview.status
        )
    }

}
