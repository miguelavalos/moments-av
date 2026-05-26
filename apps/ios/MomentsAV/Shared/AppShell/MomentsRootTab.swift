import AVAppShellFoundation
import Foundation

enum MomentsRootTab: String, CaseIterable, Identifiable {
    case home
    case create
    case projects
    case avi
    case profile

    var id: String { rawValue }

    static let footerTabs: [MomentsRootTab] = [.home, .projects]

    var shellTab: AVAppShellTab<MomentsRootTab> {
        switch self {
        case .home:
            AVAppShellTab(
                id: self,
                title: "Home",
                systemImage: "house.fill",
                accessibilityIdentifier: "moments.tab.home"
            )
        case .create:
            AVAppShellTab(
                id: self,
                title: "Create",
                systemImage: "plus.app.fill",
                accessibilityIdentifier: "moments.tab.create"
            )
        case .projects:
            AVAppShellTab(
                id: self,
                title: "Moments",
                systemImage: "rectangle.stack.fill",
                accessibilityIdentifier: "moments.tab.projects"
            )
        case .avi, .profile:
            AVAppShellTab(
                id: self,
                title: "Avi",
                systemImage: "sparkles",
                accessibilityIdentifier: "moments.tab.avi"
            )
        }
    }
}
