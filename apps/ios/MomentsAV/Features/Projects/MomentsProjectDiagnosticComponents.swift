import SwiftUI

struct MomentsProjectDiagnosticCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct MomentsProjectDiagnosticStatusBadge: View {
    let status: String

    var body: some View {
        Text(MomentsProjectStatusRules.displayTitle(for: status))
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.14), in: Capsule())
            .foregroundStyle(statusColor)
    }

    private var statusColor: Color {
        switch status {
        case "available", "completed":
            .green
        case "failed", "error", "blocked":
            .red
        case "processing", "queued", "rendering":
            .orange
        default:
            .secondary
        }
    }
}

struct MomentsProjectDiagnosticMetadataItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct MomentsProjectDiagnosticIdentifierRow: View {
    let title: String
    let value: String?
    var lineLimit = 2

    var body: some View {
        if let value, !value.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .lineLimit(lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}
