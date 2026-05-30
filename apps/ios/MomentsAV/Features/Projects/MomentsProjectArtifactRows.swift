import AVAppShellFoundation
import SwiftUI

struct MomentsProjectArtifactDetail: View {
    let presentation: MomentsProjectArtifactPresentation

    var body: some View {
        AVAppShellMetadataCard {
            HStack(alignment: .center, spacing: 8) {
                MomentsProjectDiagnosticStatusBadge(status: presentation.status)

                Text(presentation.kindTitle)
                    .font(.caption.weight(.semibold))

                Spacer(minLength: 0)
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                alignment: .leading,
                spacing: 8
            ) {
                AVAppShellMetadataItem(
                    title: "Watermark",
                    value: presentation.watermarkTitle
                )
                AVAppShellMetadataItem(
                    title: "Expires",
                    value: presentation.expiresAtTitle
                )
            }

            AVAppShellIdentifierRow(
                title: "Storage key",
                value: presentation.storageKey,
                lineLimit: 3
            )

            Text(presentation.actionDetail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct MomentsProjectRenderJobRow: View {
    let presentation: MomentsProjectRenderJobPresentation

    var body: some View {
        AVAppShellMetadataCard {
            HStack(alignment: .center, spacing: 8) {
                MomentsProjectDiagnosticStatusBadge(status: presentation.status)

                Text(presentation.kindTitle)
                    .font(.caption.weight(.semibold))

                Spacer(minLength: 0)
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                alignment: .leading,
                spacing: 8
            ) {
                AVAppShellMetadataItem(
                    title: "Render service",
                    value: presentation.providerTitle
                )
                AVAppShellMetadataItem(
                    title: "Render profile",
                    value: presentation.modelTitle
                )
                AVAppShellMetadataItem(
                    title: "Created",
                    value: presentation.createdAtTitle
                )
                AVAppShellMetadataItem(
                    title: "Updated",
                    value: presentation.updatedAtTitle
                )
            }

            MomentsProjectRenderJobErrorBlock(
                errorCode: presentation.errorCode,
                errorMessage: presentation.errorMessage
            )

            VStack(alignment: .leading, spacing: 6) {
                AVAppShellIdentifierRow(title: "Job ID", value: presentation.id)
                AVAppShellIdentifierRow(title: "Workflow", value: presentation.workflowRunId)
                AVAppShellIdentifierRow(title: "Support reference", value: presentation.providerRequestId)
            }
        }
    }
}

private struct MomentsProjectRenderJobErrorBlock: View {
    let errorCode: String?
    let errorMessage: String?

    var body: some View {
        if let errorMessage, !errorMessage.isEmpty {
            VStack(alignment: .leading, spacing: 3) {
                Text(errorCode ?? "Render error")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.red)
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(8)
            .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}
