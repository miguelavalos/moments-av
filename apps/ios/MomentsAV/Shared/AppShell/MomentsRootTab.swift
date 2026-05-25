import AVAppShellFoundation
import Foundation

enum MomentsRootTab: String, CaseIterable, Identifiable {
    case home
    case create
    case projects
    case avi

    var id: String { rawValue }

    var shellTab: AVAppShellTab<String> {
        switch self {
        case .home:
            AVAppShellTab(
                id: rawValue,
                title: "Home",
                systemImage: "house",
                accessibilityIdentifier: "moments.tab.home"
            )
        case .create:
            AVAppShellTab(
                id: rawValue,
                title: "Create",
                systemImage: "plus.app",
                accessibilityIdentifier: "moments.tab.create"
            )
        case .projects:
            AVAppShellTab(
                id: rawValue,
                title: "Projects",
                systemImage: "rectangle.stack",
                accessibilityIdentifier: "moments.tab.projects"
            )
        case .avi:
            AVAppShellTab(
                id: rawValue,
                title: "Avi",
                systemImage: "sparkles",
                accessibilityIdentifier: "moments.tab.avi"
            )
        }
    }
}
