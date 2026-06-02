import AVAppShellFoundation
import SwiftUI

struct MomentsInProgressScreen: View {
    @EnvironmentObject private var viewModel: MomentsInProgressViewModel
    @EnvironmentObject private var createViewModel: MomentsCreateViewModel
    @State private var projectPendingDeletion: MomentDraftProject?
    let balance: MomentsCreditBalance
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let startProject: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void

    private var presentation: MomentsInProgressPresentation {
        MomentsInProgressPresentation.make(
            isSignedIn: viewModel.isSignedIn,
            projectSummary: viewModel.projectSummary,
            projectPendingDeletion: projectPendingDeletion
        )
    }

    init(
        balance: MomentsCreditBalance = .empty,
        continueProject: @escaping (MomentsProjectContinuationRequest) -> Void = { _ in },
        startProject: @escaping () -> Void = {},
        startSignInFlow: @escaping () -> Void = {},
        openCredits: @escaping () -> Void = {}
    ) {
        self.balance = balance
        self.continueProject = continueProject
        self.startProject = startProject
        self.startSignInFlow = startSignInFlow
        self.openCredits = openCredits
    }

    var body: some View {
        AVAppShellScrollableScreenScaffold {
            MomentsTheme.shellBackground
        } content: {
            if createViewModel.hasLocalMomentWorkspace {
                MomentsCurrentCreationCard(
                    selectedCount: createViewModel.mediaSelectedCount,
                    continueCreation: startProject
                )
            }

            MomentsInProgressCard(
                presentation: presentation,
                balance: balance,
                projectSummary: viewModel.projectSummary,
                selectedProjectId: viewModel.selectedProjectId,
                isLoadingProjectWorkspace: viewModel.isLoadingProjectWorkspace,
                activeWorkspace: viewModel.activeWorkspace,
                isDeletingProject: viewModel.isDeletingProject,
                statusMessage: viewModel.statusMessage,
                selectProject: viewModel.selectProject,
                continueProject: continueProject,
                startProject: startProject,
                startSignInFlow: startSignInFlow,
                openCredits: openCredits,
                requestDeleteProject: { project in
                    projectPendingDeletion = project
                }
            )
        }
        .confirmationDialog(
            L10n.string("projects.deleteProject.title"),
            isPresented: deletionConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(L10n.string("projects.deleteProject.button"), role: .destructive) {
                confirmProjectDeletion()
            }
            Button(L10n.string("common.cancel"), role: .cancel) {
                cancelProjectDeletion()
            }
        } message: {
            Text(presentation.deletionMessage)
        }
    }

    private var deletionConfirmationPresented: Binding<Bool> {
        Binding(
            get: { projectPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    projectPendingDeletion = nil
                }
            }
        )
    }

    private func confirmProjectDeletion() {
        if let projectPendingDeletion {
            if createViewModel.activeProjectId == projectPendingDeletion.id {
                createViewModel.clearSessionState()
            }
            viewModel.deleteProject(projectPendingDeletion)
        }
        projectPendingDeletion = nil
    }

    private func cancelProjectDeletion() {
        projectPendingDeletion = nil
    }
}
