import AVSettingsFoundation
import SwiftUI

struct MomentsHomeAccountCard: View {
    let isSignedIn: Bool
    let creditBalance: MomentsCreditBalance
    let projectSummary: MomentsProjectListSummary
    let presentation: MomentsHomePresentation
    let signInActions: AnyView

    var body: some View {
        AVSettingsCard {
            MomentsHomeSectionHeader(
                title: presentation.accountTitle,
                detail: presentation.accountDetail
            )

            if isSignedIn {
                HStack(spacing: 10) {
                    MomentsHomeMetricTile(
                        title: "Spendable",
                        value: "\(creditBalance.spendable)",
                        systemImage: "creditcard"
                    )
                    MomentsHomeMetricTile(
                        title: "Projects",
                        value: "\(projectSummary.projectCount)",
                        systemImage: "rectangle.stack"
                    )
                }
                MomentsHomeCreditBreakdown(balance: creditBalance)
            } else {
                signInActions
            }
        }
    }
}

struct MomentsHomeProjectStatusCard: View {
    let isSignedIn: Bool
    let projectSummary: MomentsProjectListSummary
    let presentation: MomentsHomePresentation
    let openProjects: () -> Void

    var body: some View {
        AVSettingsCard {
            MomentsHomeSectionHeader(
                title: "Project status",
                detail: presentation.projectStatusDetail
            )

            if let latestProject = projectSummary.latestProject {
                MomentsHomeLatestProjectRow(
                    title: latestProject.title,
                    detail: MomentsProjectFormatting.compactDetail(for: latestProject),
                    openProject: openProjects
                )
            } else if isSignedIn {
                MomentsHomeEmptyProjectRow()
            }

            HStack(spacing: 10) {
                MomentsHomeMetricTile(
                    title: "In progress",
                    value: "\(projectSummary.inProgressCount)",
                    systemImage: "clock"
                )
                MomentsHomeMetricTile(
                    title: "Finished",
                    value: "\(projectSummary.finishedCount)",
                    systemImage: "checkmark.circle"
                )
            }
        }
    }
}

struct MomentsHomeNextActionsCard: View {
    let presentation: MomentsHomePresentation
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let selectTab: (MomentsRootTab) -> Void

    var body: some View {
        AVSettingsCard {
            MomentsHomeSectionHeader(
                title: "Next actions",
                detail: "Move between creation, project review, and Avi guidance without leaving the new shell."
            )

            VStack(spacing: 10) {
                if let latestInProgressAction = presentation.latestInProgressAction {
                    MomentsHomeActionRow(
                        action: latestInProgressAction,
                        perform: continueLatestProject
                    )
                }

                MomentsHomeActionRow(action: presentation.createAction) {
                    selectTab(.create)
                }

                MomentsHomeActionRow(action: presentation.reviewProjectsAction) {
                    selectTab(.projects)
                }

                MomentsHomeActionRow(action: presentation.aviGuidanceAction) {
                    selectTab(.avi)
                }
            }
        }
    }

    private func continueLatestProject() {
        if let request = presentation.latestInProgressContinuationRequest {
            continueProject(request)
        }
    }
}
