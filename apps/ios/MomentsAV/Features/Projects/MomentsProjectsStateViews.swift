import AVAppShellFoundation
import SwiftUI

struct MomentsProjectsUnavailableState: View {
    let presentation: MomentsProjectsUnavailablePresentation

    var body: some View {
        AVAppShellInlineMessage(
            title: presentation.title,
            message: presentation.message,
            systemImage: presentation.systemImage,
            imageSize: 28,
            verticalPadding: 6,
            usesAccentIcon: true
        )
    }
}

struct MomentsProjectsEmptyState: View {
    let presentation: MomentsProjectsUnavailablePresentation
    let startProject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MomentsProjectsUnavailableState(presentation: presentation)

            AVAppShellActionRow(
                title: "Create the first moment",
                detail: "Start with a draft, add media, then return here to review story reviews and final exports.",
                systemImage: "plus.app.fill",
                isProminent: true,
                accessibilityIdentifier: "moments.projects.empty.create",
                action: startProject
            )

            AVAppShellInlineMessage(
                title: "What appears here",
                message: "In Progress shows drafts, media, story review, render status, and videos waiting for download.",
                systemImage: "checkmark.circle",
                usesAccentIcon: true
            )
        }
    }
}

struct MomentsProjectsStatusMessage: View {
    let message: String?

    var body: some View {
        if let message {
            AVAppShellInlineMessage(message: message)
                .padding(.top, 2)
        }
    }
}
