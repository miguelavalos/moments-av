import Foundation

struct MomentsHomePresentation {
    let accountTitle: String
    let accountDetail: String
    let aviBriefDetail: String
    let projectStatusDetail: String
    let createAction: MomentsHomeAction
    let reviewProjectsAction: MomentsHomeAction
    let aviGuidanceAction: MomentsHomeAction
    let latestInProgressAction: MomentsHomeAction?
    let latestInProgressContinuationRequest: MomentsProjectContinuationRequest?

    static func make(
        isSignedIn: Bool,
        displayName: String?,
        projectSummary: MomentsProjectListSummary
    ) -> MomentsHomePresentation {
        let latestInProgressProject = projectSummary.latestInProgressProject
        let latestInProgressAction = latestInProgressProject.map {
            MomentsHomeAction(
                title: "Continue latest Moment",
                detail: MomentsProjectFormatting.compactDetail(for: $0, includeTitle: true),
                systemImage: "arrow.right.circle",
                isProminent: true
            )
        }

        return MomentsHomePresentation(
            accountTitle: isSignedIn ? "Account connected" : "Account required",
            accountDetail: accountDetail(isSignedIn: isSignedIn, displayName: displayName),
            aviBriefDetail: aviBriefDetail(isSignedIn: isSignedIn, projectSummary: projectSummary),
            projectStatusDetail: projectStatusDetail(projectSummary: projectSummary),
            createAction: MomentsHomeAction(
                title: "Create a moment",
                detail: "Choose media and let Avi prepare the story.",
                systemImage: "plus.app",
                isProminent: latestInProgressProject == nil,
                isDisabled: !isSignedIn
            ),
            reviewProjectsAction: MomentsHomeAction(
                title: "Open In Progress",
                detail: projectSummary.hasProjects
                    ? "Open drafts, active renders, and videos waiting for local download."
                    : "Drafts appear after you start a Moment.",
                systemImage: "clock",
                isDisabled: !isSignedIn
            ),
            aviGuidanceAction: MomentsHomeAction(
                title: "Get project guidance",
                detail: "Review media, story, video, and credit decisions.",
                systemImage: "sparkles"
            ),
            latestInProgressAction: latestInProgressAction,
            latestInProgressContinuationRequest: projectSummary.latestInProgressContinuationRequest
        )
    }

    private static func accountDetail(isSignedIn: Bool, displayName: String?) -> String {
        if isSignedIn {
            return "Signed in as \(displayName ?? "Moments AV user")."
        }

        return "Sign in is required before creating, rendering, and managing Moments."
    }

    private static func projectStatusDetail(projectSummary: MomentsProjectListSummary) -> String {
        if projectSummary.hasProjects {
            return "\(projectSummary.projectCount) synced \(momentLabel(projectSummary.projectCount)) tracked across the current account."
        }

        return "No synced Moments yet."
    }

    private static func aviBriefDetail(isSignedIn: Bool, projectSummary: MomentsProjectListSummary) -> String {
        guard isSignedIn else {
            return "Sign in to create Moments, track videos, manage renders, and keep credits with your account."
        }

        if let latestProject = projectSummary.latestInProgressProject {
            return "Continue \(latestProject.title) from the next unfinished step."
        }

        if projectSummary.hasProjects {
            return "Review In Progress and decide the next story, render, or download step."
        }

        return "Plan the first memory film before adding media."
    }

    private static func momentLabel(_ count: Int) -> String {
        count == 1 ? "Moment" : "Moments"
    }
}
