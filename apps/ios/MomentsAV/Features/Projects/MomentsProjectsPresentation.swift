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
                    systemImage: "person.crop.circle.fill",
                    title: "Sign in to make Moments",
                    message: "Your drafts, previews, and final videos will appear here once your account is connected."
                )
            )
        }

        if !projectSummary.hasProjects {
            return .empty(
                MomentsProjectsUnavailablePresentation(
                    systemImage: "rectangle.stack.badge.plus",
                    title: "No projects yet",
                    message: "Local creations appear in Create. Projects will appear here after the first preview starts."
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
