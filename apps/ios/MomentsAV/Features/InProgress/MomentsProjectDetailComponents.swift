import AVAppShellFoundation
import SwiftUI

struct MomentsProjectWorkspaceSummary: View {
    let workspace: MomentProjectWorkspace
    private var presentation: MomentsProjectWorkspaceSummaryPresentation {
        MomentsProjectWorkspaceSummaryPresentation(workspace: workspace)
    }

    var body: some View {
        AVAppShellMetricStrip(metrics: presentation.metrics, minTileHeight: 72)
    }
}
