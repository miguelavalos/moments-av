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
                    title: L10n.string("project.artifact.watermark"),
                    value: presentation.watermarkTitle
                )
                AVAppShellMetadataItem(
                    title: L10n.string("project.artifact.expires"),
                    value: presentation.expiresAtTitle
                )
            }

            AVAppShellIdentifierRow(
                title: L10n.string("project.artifact.storageKey"),
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
                    title: L10n.string("project.job.videoService"),
                    value: presentation.providerTitle
                )
                AVAppShellMetadataItem(
                    title: L10n.string("project.job.videoProfile"),
                    value: presentation.modelTitle
                )
                AVAppShellMetadataItem(
                    title: L10n.string("project.job.created"),
                    value: presentation.createdAtTitle
                )
                AVAppShellMetadataItem(
                    title: L10n.string("project.job.updated"),
                    value: presentation.updatedAtTitle
                )
            }

            MomentsProjectRenderJobErrorBlock(
                errorCode: presentation.errorCode,
                errorMessage: presentation.errorMessage
            )

            VStack(alignment: .leading, spacing: 6) {
                AVAppShellIdentifierRow(title: L10n.string("project.job.id"), value: presentation.id)
                AVAppShellIdentifierRow(title: L10n.string("project.job.workflow"), value: presentation.workflowRunId)
                AVAppShellIdentifierRow(title: L10n.string("project.job.supportReference"), value: presentation.providerRequestId)
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
                Text(errorCode ?? L10n.string("project.job.videoError"))
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
