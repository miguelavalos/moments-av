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

                MomentsHomeAccountCard(
                    isSignedIn: viewModel.isSignedIn,
                    creditBalance: viewModel.creditBalance,
                    projectSummary: projectSummary,
                    presentation: presentation,
                    signInActions: signInActions
                )

                MomentsHomeProjectStatusCard(
                    isSignedIn: viewModel.isSignedIn,
                    projectSummary: projectSummary,
                    presentation: presentation,
                    openProjects: { selectTab(.projects) }
                )

                MomentsHomeNextActionsCard(
                    presentation: presentation,
                    continueProject: continueProject,
                    selectTab: selectTab
                )
            }
            .padding(20)
        }
        .background(MomentsTheme.canvas.ignoresSafeArea())
        .navigationTitle("Home")
    }
}
