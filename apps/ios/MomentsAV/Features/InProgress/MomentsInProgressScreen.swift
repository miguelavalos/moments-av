import AVAppShellFoundation
import SwiftUI

struct MomentsInProgressScreen: View {
    @EnvironmentObject private var viewModel: MomentsInProgressViewModel
    @EnvironmentObject private var createViewModel: MomentsCreateViewModel
    @State private var momentPendingDeletion: MomentDraftProject?
    let balance: MomentsCreditBalance
    let continueMoment: (MomentsProjectContinuationRequest) -> Void
    let startMoment: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void

    private var presentation: MomentsInProgressPresentation {
        MomentsInProgressPresentation.make(
            isSignedIn: viewModel.isSignedIn,
            projectSummary: viewModel.projectSummary,
            momentPendingDeletion: momentPendingDeletion
        )
    }

    init(
        balance: MomentsCreditBalance = .empty,
        continueMoment: @escaping (MomentsProjectContinuationRequest) -> Void = { _ in },
        startMoment: @escaping () -> Void = {},
        startSignInFlow: @escaping () -> Void = {},
        openCredits: @escaping () -> Void = {}
    ) {
        self.balance = balance
        self.continueMoment = continueMoment
        self.startMoment = startMoment
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
                    continueCreation: startMoment
                )
            }

            MomentsInProgressCard(
                presentation: presentation,
                balance: balance,
                projectSummary: viewModel.projectSummary,
                selectedMomentId: viewModel.selectedMomentId,
                isLoadingProjectWorkspace: viewModel.isLoadingProjectWorkspace,
                activeWorkspace: viewModel.activeWorkspace,
                isDeletingMoment: viewModel.isDeletingMoment,
                statusMessage: viewModel.statusMessage,
                selectProject: viewModel.selectProject,
                continueMoment: continueMoment,
                startMoment: startMoment,
                startSignInFlow: startSignInFlow,
                openCredits: openCredits,
                requestDeleteMoment: { project in
                    momentPendingDeletion = project
                }
            )
        }
        .confirmationDialog(
            L10n.string("inProgress.deleteMoment.title"),
            isPresented: deletionConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(L10n.string("inProgress.deleteMoment.button"), role: .destructive) {
                confirmMomentDeletion()
            }
            Button(L10n.string("common.cancel"), role: .cancel) {
                cancelMomentDeletion()
            }
        } message: {
            Text(presentation.deletionMessage)
        }
    }

    private var deletionConfirmationPresented: Binding<Bool> {
        Binding(
            get: { momentPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    momentPendingDeletion = nil
                }
            }
        )
    }

    private func confirmMomentDeletion() {
        if let momentPendingDeletion {
            if createViewModel.activeMomentId == momentPendingDeletion.id {
                createViewModel.clearSessionState()
            }
            viewModel.deleteMoment(momentPendingDeletion)
        }
        momentPendingDeletion = nil
    }

    private func cancelMomentDeletion() {
        momentPendingDeletion = nil
    }
}
