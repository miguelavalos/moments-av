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
                title: MomentsL10n.string("projects.empty.create.title"),
                detail: MomentsL10n.string("projects.empty.create.detail"),
                systemImage: "plus.app.fill",
                isProminent: true,
                accessibilityIdentifier: "moments.projects.empty.create",
                action: startProject
            )

            AVAppShellInlineMessage(
                title: MomentsL10n.string("projects.empty.whatAppears.title"),
                message: MomentsL10n.string("projects.empty.whatAppears.message"),
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
