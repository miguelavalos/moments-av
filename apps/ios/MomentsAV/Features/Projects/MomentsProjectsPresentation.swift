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
            deletionMessage: "This removes \(projectPendingDeletion?.title ?? "this project"), including source media records and generated artifacts."
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
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    title: "Sign in required",
                    message: "Project history loads after your account is connected."
                )
            )
        }

        if !projectSummary.hasProjects {
            return .empty(
                MomentsProjectsUnavailablePresentation(
                    systemImage: "rectangle.stack.badge.plus",
                    title: "No projects yet",
                    message: "Create a moment first, then drafts, previews, and final exports will appear here."
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
