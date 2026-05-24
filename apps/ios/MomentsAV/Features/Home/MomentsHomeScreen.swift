import AVSettingsFoundation
import SwiftUI

struct MomentsHomeScreen: View {
    @EnvironmentObject private var viewModel: MomentsHomeViewModel

    let selectTab: (MomentsRootTab) -> Void
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let signInActions: AnyView
    private var projectSummary: MomentsProjectListSummary { viewModel.projectSummary }
    private var latestInProgressProject: MomentDraftProject? { projectSummary.latestInProgressProject }
    private var latestInProgressContinuationRequest: MomentsProjectContinuationRequest? {
        projectSummary.latestInProgressContinuationRequest
    }
    private var latestInProgressProjectDetail: String {
        guard let latestInProgressProject else { return "" }
        return MomentsProjectFormatting.compactDetail(for: latestInProgressProject, includeTitle: true)
    }
    private var createAction: MomentsHomeAction {
        MomentsHomeAction(
            title: "Create a moment",
            detail: "Pick the occasion, add media, draft the story, then render.",
            systemImage: "plus.app",
            isProminent: latestInProgressProject == nil,
            isDisabled: !viewModel.isSignedIn
        )
    }
    private var reviewProjectsAction: MomentsHomeAction {
        MomentsHomeAction(
            title: "Review projects",
            detail: projectSummary.hasProjects
                ? "Open \(projectSummary.projectCount) synced projects with preview and final status."
                : "Project workspace details will appear after the first synced draft.",
            systemImage: "rectangle.stack",
            isDisabled: !viewModel.isSignedIn
        )
    }
    private var aviGuidanceAction: MomentsHomeAction {
        MomentsHomeAction(
            title: "Ask Avi for guidance",
            detail: "Use Avi for media, story, preview, render, and credit guidance.",
            systemImage: "sparkles"
        )
    }
    private var latestInProgressAction: MomentsHomeAction? {
        guard latestInProgressProject != nil else { return nil }
        return MomentsHomeAction(
            title: "Continue latest project",
            detail: latestInProgressProjectDetail,
            systemImage: "arrow.right.circle",
            isProminent: true
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
                        title: viewModel.isSignedIn ? "Account connected" : "Account required",
                        detail: viewModel.isSignedIn
                            ? "Signed in as \(viewModel.displayName ?? "Moments AV user")."
                            : "Sign in is required before creating, rendering, and managing projects."
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
                        detail: projectSummary.hasProjects
                            ? "\(projectSummary.projectCount) synced projects tracked across the current account."
                            : "No synced projects yet."
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
                        if let latestInProgressAction {
                            MomentsHomeActionRow(
                                action: latestInProgressAction
                            ) {
                                if let latestInProgressContinuationRequest {
                                    continueProject(latestInProgressContinuationRequest)
                                }
                            }
                        }

                        MomentsHomeActionRow(
                            action: createAction
                        ) {
                            selectTab(.create)
                        }

                        MomentsHomeActionRow(
                            action: reviewProjectsAction
                        ) {
                            selectTab(.projects)
                        }

                        MomentsHomeActionRow(
                            action: aviGuidanceAction
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
