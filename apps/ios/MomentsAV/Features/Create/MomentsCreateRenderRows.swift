import AVAppShellFoundation
import SwiftUI

struct MomentsCreateRenderJobStatusRow: View {
    let renderJob: MomentRenderJob

    var body: some View {
        AVAppShellInfoRow(
            title: MomentsProjectStatusRules.displayTitle(for: renderJob.status),
            detail: detail,
            systemImage: systemImage,
            eyebrow: "Render job"
        )
    }

    private var detail: String {
        if let errorMessage = renderJob.errorMessage, renderJob.status == "failed" {
            return errorMessage
        }

        return renderJob.model ?? "Waiting for renderer status."
    }

    private var systemImage: String {
        switch renderJob.status {
        case "completed":
            return "checkmark.circle.fill"
        case "failed":
            return "exclamationmark.triangle.fill"
        case "running", "processing":
            return "gearshape.2.fill"
        default:
            return "clock.fill"
        }
    }
}

struct MomentsCreateArtifactStatusCard: View {
    let title: String
    let systemImage: String
    let artifact: MomentArtifact
    let detail: String?

    var body: some View {
        AVAppShellMetadataCard {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))

            if let detail, !detail.isEmpty {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                alignment: .leading,
                spacing: 8
            ) {
                AVAppShellMetadataItem(
                    title: "Watermark",
                    value: artifact.hasWatermark == true ? "Included" : "None"
                )
                AVAppShellMetadataItem(
                    title: "Expires",
                    value: MomentsDateFormatting.formattedDate(milliseconds: artifact.expiresAt)
                )
            }

            AVAppShellIdentifierRow(
                title: "Storage key",
                value: artifact.r2Key,
                lineLimit: 3
            )
        }
    }
}
