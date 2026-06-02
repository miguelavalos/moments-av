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
                title: L10n.string("home.action.continueLatest.title"),
                detail: MomentsProjectFormatting.compactDetail(for: $0, includeTitle: true),
                systemImage: "arrow.right.circle",
                isProminent: true
            )
        }

        return MomentsHomePresentation(
            accountTitle: isSignedIn ? L10n.string("home.account.connected.title") : L10n.string("home.account.required.title"),
            accountDetail: accountDetail(isSignedIn: isSignedIn, displayName: displayName),
            aviBriefDetail: aviBriefDetail(isSignedIn: isSignedIn, projectSummary: projectSummary),
            projectStatusDetail: projectStatusDetail(projectSummary: projectSummary),
            createAction: MomentsHomeAction(
                title: L10n.string("home.action.create.title"),
                detail: L10n.string("home.action.create.detail"),
                systemImage: "plus.app",
                isProminent: latestInProgressProject == nil,
                isDisabled: !isSignedIn
            ),
            reviewProjectsAction: MomentsHomeAction(
                title: L10n.string("home.action.openInProgress.title"),
                detail: projectSummary.hasProjects
                    ? L10n.string("home.action.openInProgress.detail.hasProjects")
                    : L10n.string("home.action.openInProgress.detail.empty"),
                systemImage: "clock",
                isDisabled: !isSignedIn
            ),
            aviGuidanceAction: MomentsHomeAction(
                title: L10n.string("home.action.guidance.title"),
                detail: L10n.string("home.action.guidance.detail"),
                systemImage: "sparkles"
            ),
            latestInProgressAction: latestInProgressAction,
            latestInProgressContinuationRequest: projectSummary.latestInProgressContinuationRequest
        )
    }

    private static func accountDetail(isSignedIn: Bool, displayName: String?) -> String {
        if isSignedIn {
            return L10n.string("home.account.signedInAs", displayName ?? L10n.string("home.account.defaultUser"))
        }

        return L10n.string("home.account.signInRequired")
    }

    private static func projectStatusDetail(projectSummary: MomentsProjectListSummary) -> String {
        if projectSummary.hasProjects {
            return L10n.string("home.projectStatus.synced", projectSummary.projectCount, momentLabel(projectSummary.projectCount))
        }

        return L10n.string("home.projectStatus.empty")
    }

    private static func aviBriefDetail(isSignedIn: Bool, projectSummary: MomentsProjectListSummary) -> String {
        guard isSignedIn else {
            return L10n.string("home.aviBrief.signIn")
        }

        if let latestProject = projectSummary.latestInProgressProject {
            return L10n.string("home.aviBrief.continueProject", latestProject.title)
        }

        if projectSummary.hasProjects {
            return L10n.string("home.aviBrief.reviewInProgress")
        }

        return L10n.string("home.aviBrief.firstMemory")
    }

    private static func momentLabel(_ count: Int) -> String {
        count == 1 ? L10n.string("moment.noun.one") : L10n.string("moment.noun.other")
    }
}
