import AVAppShellFoundation
import SwiftUI

struct MomentsHomeLatestProjectRow: View {
    let title: String
    let detail: String
    let openProject: () -> Void

    var body: some View {
        AVAppShellActionRow(
            title: title,
            detail: detail,
            systemImage: "clock.badge.checkmark",
            eyebrow: L10n.string("home.latestMoment.eyebrow"),
            accessibilityIdentifier: "moments.home.latestProject",
            action: openProject
        )
    }
}

struct MomentsHomeEmptyProjectRow: View {
    var body: some View {
        AVAppShellInfoRow(
            title: L10n.string("home.projects.emptyRow.title"),
            detail: L10n.string("home.projects.emptyRow.detail"),
            systemImage: "rectangle.stack.badge.plus",
            accessibilityIdentifier: "moments.home.projects.empty"
        )
    }
}
