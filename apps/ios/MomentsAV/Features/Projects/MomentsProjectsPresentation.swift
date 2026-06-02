import Foundation

struct MomentsProjectsPresentation: Equatable {
    let availability: MomentsProjectsAvailability
    let deletionMessage: String

    static func make(
        isSignedIn: Bool,
        projectSummary: MomentsProjectListSummary,
        projectPendingDeletion: MomentDraftProject?
    ) -> MomentsProjectsPresentation {
        MomentsProjectsPresentation(
            availability: MomentsProjectsAvailability.make(
                isSignedIn: isSignedIn,
                projectSummary: projectSummary
            ),
            deletionMessage: L10n.string("projects.deleteProject.message", projectPendingDeletion?.title ?? L10n.string("moment.this"))
        )
    }
}

enum MomentsProjectsAvailability: Equatable {
    case signedOut(MomentsProjectsUnavailablePresentation)
    case empty(MomentsProjectsUnavailablePresentation)
    case available

    static func make(
        isSignedIn: Bool,
        projectSummary: MomentsProjectListSummary
    ) -> MomentsProjectsAvailability {
        if !isSignedIn {
            return .signedOut(
                MomentsProjectsUnavailablePresentation(
                    systemImage: "person.crop.circle.fill",
                    title: L10n.string("projects.signIn.title"),
                    message: L10n.string("projects.signIn.message")
                )
            )
        }

        if !projectSummary.hasProjects {
            return .empty(
                MomentsProjectsUnavailablePresentation(
                    systemImage: "rectangle.stack.badge.plus",
                    title: L10n.string("projects.empty.title"),
                    message: L10n.string("projects.empty.message")
                )
            )
        }

        return .available
    }
}

struct MomentsProjectsUnavailablePresentation: Equatable {
    let systemImage: String
    let title: String
    let message: String
}
