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
                title: "Continue latest project",
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
                detail: "Pick the occasion, add media, draft the story, then render.",
                systemImage: "plus.app",
                isProminent: latestInProgressProject == nil,
                isDisabled: !isSignedIn
            ),
            reviewProjectsAction: MomentsHomeAction(
                title: "Review projects",
                detail: projectSummary.hasProjects
                    ? "Open \(projectSummary.projectCount) synced \(projectLabel(projectSummary.projectCount)) with preview and final status."
                    : "Project workspace details will appear after the first synced draft.",
                systemImage: "rectangle.stack",
                isDisabled: !isSignedIn
            ),
            aviGuidanceAction: MomentsHomeAction(
                title: "Ask Avi for guidance",
                detail: "Use Avi for media, story, preview, render, and credit guidance.",
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

        return "Sign in is required before creating, rendering, and managing projects."
    }

    private static func projectStatusDetail(projectSummary: MomentsProjectListSummary) -> String {
        if projectSummary.hasProjects {
            return "\(projectSummary.projectCount) synced \(projectLabel(projectSummary.projectCount)) tracked across the current account."
        }

        return "No synced projects yet."
    }

    private static func aviBriefDetail(isSignedIn: Bool, projectSummary: MomentsProjectListSummary) -> String {
        guard isSignedIn else {
            return "Sign in to let Avi guide drafts, previews, renders, and credits from one account."
        }

        if let latestProject = projectSummary.latestInProgressProject {
            return "Avi can help continue \(latestProject.title) from the next unfinished step."
        }

        if projectSummary.hasProjects {
            return "Avi can review your synced projects and help decide the next preview or final render."
        }

        return "Avi can help plan the first memory video before you add media."
    }

    private static func projectLabel(_ count: Int) -> String {
        count == 1 ? "project" : "projects"
    }
}
