import SwiftUI

struct MomentsCreateRenderJobStatusRow: View {
    let renderJob: MomentRenderJob

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(MomentsProjectStatusRules.displayTitle(for: renderJob.status))
                .font(.subheadline.weight(.medium))

            if let errorMessage = renderJob.errorMessage, renderJob.status == "failed" {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if let model = renderJob.model {
                Text(model)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
