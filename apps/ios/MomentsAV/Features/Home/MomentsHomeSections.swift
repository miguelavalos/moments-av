import AVAppShellFoundation
import SwiftUI

struct MomentsHomeAccountCard: View {
    let creditBalance: MomentsCreditBalance
    let openCredits: () -> Void

    var body: some View {
        AVAppShellDashboardSection(
            title: L10n.string("credits.title"),
            detail: creditDetail
        ) {
            AVAppShellMetricStrip(metrics: creditMetrics)
            AVAppShellActionRow(
                title: creditBalance.spendable > 0 ? L10n.string("credits.manage.title") : L10n.string("credits.get.title"),
                detail: creditBalance.spendable > 0 ? L10n.string("credits.manage.detail") : L10n.string("credits.get.detail"),
                systemImage: creditBalance.spendable > 0 ? "creditcard.fill" : "plus.circle.fill",
                isProminent: creditBalance.spendable == 0,
                accessibilityIdentifier: "moments.home.credits.open",
                action: openCredits
            )
        }
    }

    private var creditMetrics: [AVAppShellMetric] {
        [
            AVAppShellMetric(
                id: "spendable",
                title: L10n.string("credits.available.title"),
                value: "\(creditBalance.spendable)",
                systemImage: "creditcard"
            )
        ]
    }

    private var creditDetail: String {
        if creditBalance.spendable == 0 {
            return L10n.string("credits.home.none")
        }

        return L10n.string("credits.home.ready")
    }
}

struct MomentsHomeSignInCard: View {
    let startSignInFlow: () -> Void

    var body: some View {
        AVAppShellDashboardSection(
            title: L10n.string("home.signIn.title"),
            detail: L10n.string("home.signIn.detail")
        ) {
            AVAppShellActionRow(
                title: L10n.string("common.signIn"),
                detail: L10n.string("home.signIn.action.detail"),
                systemImage: "person.crop.circle.fill",
                isProminent: true,
                accessibilityIdentifier: "moments.home.signin",
                action: startSignInFlow
            )
        }
    }
}

struct MomentsHomeProjectStatusCard: View {
    let isSignedIn: Bool
    let projectSummary: MomentsProjectListSummary
    let presentation: MomentsHomePresentation
    let openProjects: () -> Void

    var body: some View {
        AVAppShellDashboardSection(
            title: L10n.string("projects.inProgressAndGallery.title"),
            detail: presentation.projectStatusDetail
        ) {
            if let latestProject = projectSummary.latestProject {
                MomentsHomeLatestProjectRow(
                    title: latestProject.title,
                    detail: MomentsProjectFormatting.compactDetail(for: latestProject),
                    openProject: openProjects
                )
            } else if isSignedIn {
                MomentsHomeEmptyProjectRow()
            }

            AVAppShellMetricStrip(metrics: projectMetrics)
        }
    }

    private var projectMetrics: [AVAppShellMetric] {
        [
            AVAppShellMetric(
                id: "in-progress",
                title: L10n.string("projects.inProgress.title"),
                value: "\(projectSummary.inProgressCount)",
                systemImage: "clock"
            ),
            AVAppShellMetric(
                id: "finished",
                title: L10n.string("projects.finished.title"),
                value: "\(projectSummary.finishedCount)",
                systemImage: "checkmark.circle"
            )
        ]
    }
}

struct MomentsHomeNextActionsCard: View {
    let presentation: MomentsHomePresentation
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let startMoment: () -> Void
    let selectTab: (MomentsRootTab) -> Void

    var body: some View {
        AVAppShellDashboardSection(
            title: L10n.string("home.nextActions.title"),
            detail: L10n.string("home.nextActions.detail")
        ) {
            VStack(spacing: 10) {
                if let latestInProgressAction = presentation.latestInProgressAction {
                    homeActionRow(
                        action: latestInProgressAction,
                        perform: continueLatestProject
                    )
                }

                homeActionRow(action: presentation.createAction, perform: startMoment)

                homeActionRow(action: presentation.reviewProjectsAction) {
                    selectTab(.inProgress)
                }

                homeActionRow(action: presentation.aviGuidanceAction) {
                    selectTab(.avi)
                }
            }
        }
    }

    private func homeActionRow(action: MomentsHomeAction, perform: @escaping () -> Void) -> some View {
        AVAppShellActionRow(
            title: action.title,
            detail: action.detail,
            systemImage: action.systemImage,
            isProminent: action.isProminent,
            isDisabled: action.isDisabled,
            accessibilityIdentifier: "moments.home.action.\(action.title.lowercased().replacingOccurrences(of: " ", with: "."))",
            action: perform
        )
    }

    private func continueLatestProject() {
        if let request = presentation.latestInProgressContinuationRequest {
            continueProject(request)
        }
    }
}
