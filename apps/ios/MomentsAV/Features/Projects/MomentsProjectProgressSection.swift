import SwiftUI

struct MomentsProjectProgressSection: View {
    let workspace: MomentProjectWorkspace

    private var phases: [MomentsProjectProgressPhase] {
        [
            MomentsProjectProgressPhase(
                title: "Draft",
                detail: MomentsProjectStatusRules.displayTitle(for: workspace.project.status),
                systemImage: "doc.text",
                state: .complete
            ),
            MomentsProjectProgressPhase(
                title: "Media",
                detail: workspace.mediaAssets.isEmpty ? "No media yet" : "\(workspace.mediaAssets.count) assets",
                systemImage: "photo.on.rectangle",
                state: workspace.mediaAssets.isEmpty ? .waiting : .complete
            ),
            MomentsProjectProgressPhase(
                title: "Story",
                detail: workspace.storyScenes.isEmpty ? "Not drafted" : "\(workspace.storyScenes.count) scenes",
                systemImage: "text.bubble",
                state: workspace.storyScenes.isEmpty ? .waiting : .complete
            ),
            MomentsProjectProgressPhase(
                title: "Preview",
                detail: renderDetail(kind: "preview", fallback: "Not generated"),
                systemImage: "play.rectangle",
                state: renderState(kind: "preview", artifactKind: "preview")
            ),
            MomentsProjectProgressPhase(
                title: "Final",
                detail: renderDetail(kind: "final", fallback: "Not rendered"),
                systemImage: "square.and.arrow.up",
                state: renderState(kind: "final", artifactKind: "final_export")
            )
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 10) {
                ForEach(phases) { phase in
                    MomentsProjectProgressRow(phase: phase)
                }
            }
        }
    }

    private func renderDetail(kind: String, fallback: String) -> String {
        if let artifact = workspace.artifacts.last(where: { $0.kind == artifactKind(for: kind) }) {
            return MomentsProjectStatusRules.displayTitle(for: artifact.status)
        }

        guard let job = workspace.renderJobs
            .filter({ $0.kind == kind })
            .sorted(by: { $0.updatedAt < $1.updatedAt })
            .last else {
            return fallback
        }

        return MomentsProjectStatusRules.displayTitle(for: job.status)
    }

    private func renderState(kind: String, artifactKind: String) -> MomentsProjectProgressState {
        if workspace.artifacts.contains(where: { $0.kind == artifactKind && $0.status == "available" }) {
            return .complete
        }

        guard let job = workspace.renderJobs
            .filter({ $0.kind == kind })
            .sorted(by: { $0.updatedAt < $1.updatedAt })
            .last else {
            return .waiting
        }

        return MomentsProjectProgressState(status: job.status)
    }

    private func artifactKind(for renderKind: String) -> String {
        renderKind == "final" ? "final_export" : renderKind
    }
}

private struct MomentsProjectProgressPhase: Identifiable {
    let title: String
    let detail: String
    let systemImage: String
    let state: MomentsProjectProgressState

    var id: String {
        title
    }
}

private enum MomentsProjectProgressState {
    case complete
    case active
    case waiting
    case failed

    init(status: String) {
        switch status {
        case "completed", "available", "succeeded":
            self = .complete
        case "failed", "error", "blocked":
            self = .failed
        case "queued", "running", "processing", "pending":
            self = .active
        default:
            self = .active
        }
    }

    var systemImage: String {
        switch self {
        case .complete: "checkmark.circle.fill"
        case .active: "clock.fill"
        case .waiting: "circle"
        case .failed: "exclamationmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .complete: MomentsTheme.brandPalette.accent
        case .active: .secondary
        case .waiting: .secondary.opacity(0.7)
        case .failed: .red
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
