import AVSettingsFoundation
import SwiftUI

struct MomentsHomeScreen: View {
    @EnvironmentObject private var viewModel: MomentsHomeViewModel

    let selectTab: (MomentsRootTab) -> Void
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let signInActions: AnyView
    private var projectSummary: MomentsProjectListSummary { viewModel.projectSummary }
    private var presentation: MomentsHomePresentation {
        MomentsHomePresentation.make(
            isSignedIn: viewModel.isSignedIn,
            displayName: viewModel.displayName,
            projectSummary: projectSummary
        )
    }

    init(
        selectTab: @escaping (MomentsRootTab) -> Void,
        continueProject: @escaping (MomentsProjectContinuationRequest) -> Void,
        signInActions: AnyView
    ) {
        self.selectTab = selectTab
        self.continueProject = continueProject
        self.signInActions = signInActions
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                AVSettingsScreenHeader(
                    title: "Moments AV",
                    subtitle: "Private memory videos guided by Avi, with simple project tracking from draft to final export."
                )

                AVSettingsCard {
                    MomentsHomeSectionHeader(
                        title: presentation.accountTitle,
                        detail: presentation.accountDetail
                    )

                    if viewModel.isSignedIn {
                        HStack(spacing: 10) {
                            MomentsHomeMetricTile(
                                title: "Spendable",
                                value: "\(viewModel.creditBalance.spendable)",
                                systemImage: "creditcard"
                            )
                            MomentsHomeMetricTile(
                                title: "Projects",
                                value: "\(projectSummary.projectCount)",
                                systemImage: "rectangle.stack"
                            )
                        }
                        MomentsHomeCreditBreakdown(balance: viewModel.creditBalance)
                    } else {
                        signInActions
                    }
                }

                AVSettingsCard {
                    MomentsHomeSectionHeader(
                        title: "Project status",
                        detail: presentation.projectStatusDetail
                    )

                    if let latestProject = projectSummary.latestProject {
                        MomentsHomeLatestProjectRow(
                            title: latestProject.title,
                            detail: MomentsProjectFormatting.compactDetail(for: latestProject),
                            openProject: { selectTab(.projects) }
                        )
                    } else if viewModel.isSignedIn {
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

                AVSettingsCard {
                    MomentsHomeSectionHeader(
                        title: "Next actions",
                        detail: "Move between creation, project review, and Avi guidance without leaving the new shell."
                    )

                    VStack(spacing: 10) {
                        if let latestInProgressAction = presentation.latestInProgressAction {
                            MomentsHomeActionRow(
                                action: latestInProgressAction
                            ) {
                                if let latestInProgressContinuationRequest = presentation.latestInProgressContinuationRequest {
                                    continueProject(latestInProgressContinuationRequest)
                                }
                            }
                        }

                        MomentsHomeActionRow(
                            action: presentation.createAction
                        ) {
                            selectTab(.create)
                        }

                        MomentsHomeActionRow(
                            action: presentation.reviewProjectsAction
                        ) {
                            selectTab(.projects)
                        }

                        MomentsHomeActionRow(
                            action: presentation.aviGuidanceAction
                        ) {
                            selectTab(.avi)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(MomentsTheme.canvas.ignoresSafeArea())
        .navigationTitle("Home")
    }
}
