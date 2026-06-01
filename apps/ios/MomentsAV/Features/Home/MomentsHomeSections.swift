import AVAppShellFoundation
import SwiftUI

struct MomentsHomeAccountCard: View {
    let creditBalance: MomentsCreditBalance
    let openCredits: () -> Void

    var body: some View {
        AVAppShellDashboardSection(
            title: "Credits",
            detail: creditDetail
        ) {
            AVAppShellMetricStrip(metrics: creditMetrics)
            AVAppShellActionRow(
                title: creditBalance.spendable > 0 ? "Manage credits" : "Get credits",
                detail: creditBalance.spendable > 0 ? "View wallet details, purchases, and restore options." : "Add credits before creating your next memory film.",
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
                title: "Available",
                value: "\(creditBalance.spendable)",
                systemImage: "creditcard"
            )
        ]
    }

    private var creditDetail: String {
        if creditBalance.spendable == 0 {
            return "No credits available yet."
        }

        return "Ready to spend on private memory films."
    }
}

struct MomentsHomeSignInCard: View {
    let startSignInFlow: () -> Void

    var body: some View {
        AVAppShellDashboardSection(
            title: "Sign in to use Moments",
            detail: "Moments, credits, media, story reviews, and final exports need an account."
        ) {
            AVAppShellActionRow(
                title: "Sign in",
                detail: "Connect your account before creating or managing Moments.",
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
            title: "In Progress and Gallery",
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
                title: "In progress",
                value: "\(projectSummary.inProgressCount)",
                systemImage: "clock"
            ),
            AVAppShellMetric(
                id: "finished",
                title: "Finished",
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
            title: "Next actions",
            detail: "Start a memory film, continue active work, or open guidance when a Moment needs a decision."
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
