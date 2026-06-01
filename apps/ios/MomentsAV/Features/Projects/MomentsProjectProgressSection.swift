import AVAppShellFoundation
import SwiftUI

struct MomentsProjectProgressSection: View {
    let workspace: MomentProjectWorkspace

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AVAppShellSectionHeader(title: MomentsL10n.string("project.progress.title"))

            VStack(alignment: .leading, spacing: 10) {
                ForEach(MomentsProjectProgressModel(workspace: workspace).phases) { phase in
                    MomentsProjectProgressRow(phase: phase)
                }
            }
        }
    }
}

private struct MomentsProjectProgressRow: View {
    let phase: MomentsProjectProgressPhase

    var body: some View {
        AVAppShellProgressRow(
            title: phase.title,
            detail: phase.detail,
            systemImage: phase.systemImage,
            stateSystemImage: phase.state.systemImage,
            stateTint: phase.state.tint
        )
    }
}

private extension MomentsProjectProgressState {
    var tint: Color {
        switch self {
        case .complete: MomentsTheme.highlight
        case .active: .secondary
        case .waiting: .secondary.opacity(0.7)
        case .failed: .red
        }
    }
}
