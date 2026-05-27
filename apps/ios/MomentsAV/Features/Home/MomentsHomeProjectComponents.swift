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
            eyebrow: "Latest project",
            accessibilityIdentifier: "moments.home.latestProject",
            action: openProject
        )
    }
}

struct MomentsHomeEmptyProjectRow: View {
    var body: some View {
        AVAppShellInfoRow(
            title: "No projects yet",
            detail: "Start in Create to sync the first story and final video.",
            systemImage: "rectangle.stack.badge.plus",
            accessibilityIdentifier: "moments.home.projects.empty"
        )
    }
}
