import AVAppShellFoundation
import SwiftUI

struct MomentsHomeAccountCard: View {
    let creditBalance: MomentsCreditBalance
    let projectSummary: MomentsProjectListSummary
    let presentation: MomentsHomePresentation

    var body: some View {
        AVAppShellDashboardSection(
            title: presentation.accountTitle,
            detail: presentation.accountDetail
        ) {
            AVAppShellMetricStrip(metrics: accountMetrics)
            MomentsHomeCreditBreakdown(balance: creditBalance)
        }
    }

    private var accountMetrics: [AVAppShellMetric] {
        [
            AVAppShellMetric(
                id: "spendable",
                title: "Spendable",
                value: "\(creditBalance.spendable)",
                systemImage: "creditcard"
            ),
            AVAppShellMetric(
                id: "projects",
                title: "Projects",
                value: "\(projectSummary.projectCount)",
                systemImage: "rectangle.stack"
            )
        ]
    }
}

struct MomentsHomeProjectStatusCard: View {
    let isSignedIn: Bool
    let projectSummary: MomentsProjectListSummary
    let presentation: MomentsHomePresentation
    let openProjects: () -> Void

    var body: some View {
        AVAppShellDashboardSection(
            title: "Project status",
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
    let selectTab: (MomentsRootTab) -> Void

    var body: some View {
        AVAppShellDashboardSection(
            title: "Next actions",
            detail: "Start a memory film, review project progress, or open guidance when a project needs a decision."
        ) {
            VStack(spacing: 10) {
                if let latestInProgressAction = presentation.latestInProgressAction {
                    homeActionRow(
                        action: latestInProgressAction,
                        perform: continueLatestProject
                    )
                }

                homeActionRow(action: presentation.createAction) {
                    selectTab(.create)
                }

                homeActionRow(action: presentation.reviewProjectsAction) {
                    selectTab(.projects)
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
