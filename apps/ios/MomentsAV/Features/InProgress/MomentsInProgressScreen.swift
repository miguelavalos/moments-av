import AVAppShellFoundation
import SwiftUI

struct MomentsInProgressScreen: View {
    @EnvironmentObject private var viewModel: MomentsInProgressViewModel
    @EnvironmentObject private var createViewModel: MomentsCreateViewModel
    @State private var momentPendingDeletion: InProgressMoment?
    let balance: MomentsCreditBalance
    let creditBalanceLoadState: MomentsCreditBalanceLoadState
    let continueMoment: (MomentsContinuationRequest) -> Void
    let startMoment: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void
    let retryCredits: () -> Void

    private var presentation: MomentsInProgressPresentation {
        MomentsInProgressPresentation.make(
            isSignedIn: viewModel.isSignedIn,
            momentsSummary: viewModel.momentsSummary,
            momentPendingDeletion: momentPendingDeletion
        )
    }

    init(
        balance: MomentsCreditBalance = .empty,
        creditBalanceLoadState: MomentsCreditBalanceLoadState = .loaded,
        continueMoment: @escaping (MomentsContinuationRequest) -> Void = { _ in },
        startMoment: @escaping () -> Void = {},
        startSignInFlow: @escaping () -> Void = {},
        openCredits: @escaping () -> Void = {},
        retryCredits: @escaping () -> Void = {}
    ) {
        self.balance = balance
        self.creditBalanceLoadState = creditBalanceLoadState
        self.continueMoment = continueMoment
        self.startMoment = startMoment
        self.startSignInFlow = startSignInFlow
        self.openCredits = openCredits
        self.retryCredits = retryCredits
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
                creditBalanceLoadState: creditBalanceLoadState,
                momentsSummary: viewModel.momentsSummary,
                selectedMomentId: viewModel.selectedMomentId,
                isLoadingMomentWorkspace: viewModel.isLoadingMomentWorkspace,
                activeWorkspace: viewModel.activeWorkspace,
                isDeletingMoment: viewModel.isDeletingMoment,
                statusMessage: viewModel.statusMessage,
                selectMoment: viewModel.selectMoment,
                continueMoment: continueMoment,
                startMoment: startMoment,
                startSignInFlow: startSignInFlow,
                openCredits: openCredits,
                retryCredits: retryCredits
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
