import SwiftUI

struct MomentsProjectProgressSection: View {
    let workspace: MomentProjectWorkspace

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.subheadline.weight(.semibold))

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
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: phase.state.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(phase.state.tint)
                .frame(width: 18)

            Image(systemName: phase.systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(phase.title)
                    .font(.caption.weight(.semibold))
                Text(phase.detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private extension MomentsProjectProgressState {
    var tint: Color {
        switch self {
        case .complete: MomentsTheme.brandPalette.accent
        case .active: .secondary
        case .waiting: .secondary.opacity(0.7)
        case .failed: .red
        }
    }
}
