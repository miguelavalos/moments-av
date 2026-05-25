import AVAppShellFoundation
import SwiftUI

struct MomentsCreateRefreshableRenderJobSection: View {
    let renderJob: MomentRenderJob?
    let refreshButtonTitle: String
    let canRefresh: Bool
    let refreshAvailabilityMessage: String?
    let refreshStatus: () -> Void

    @ViewBuilder
    var body: some View {
        if let renderJob {
            MomentsCreateRenderJobStatusRow(renderJob: renderJob)

            Button(action: refreshStatus) {
                Text(refreshButtonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!canRefresh)

            if let refreshAvailabilityMessage {
                AVAppShellInlineMessage(message: refreshAvailabilityMessage)
            }
        }
    }
}
