import AVAppShellFoundation
import SwiftUI

struct MomentsInProgressWorkspaceSummary: View {
    let workspace: MomentProjectWorkspace
    private var presentation: MomentsInProgressWorkspaceSummaryPresentation {
        MomentsInProgressWorkspaceSummaryPresentation(workspace: workspace)
    }

    var body: some View {
        AVAppShellMetricStrip(metrics: presentation.metrics, minTileHeight: 72)
    }
}
