import Combine
import Foundation

@MainActor
final class MomentsAviViewModel: ObservableObject {
    @Published private(set) var momentsSummary = InProgressMomentsSummary()
    @Published private(set) var isSignedIn = false
    @Published private(set) var creditBalance = MomentsCreditBalance.empty

    private var momentsCancellables = Set<AnyCancellable>()
    private var accountCancellables = Set<AnyCancellable>()

    var presentation: MomentsAviPresentation {
        MomentsAviPresentation.make(
            isSignedIn: isSignedIn,
            momentsSummary: momentsSummary,
            creditBalance: creditBalance
        )
    }

    func bind(to summaryProvider: any InProgressMomentsSummaryProviding) {
        momentsCancellables.removeAll()

        summaryProvider.inProgressSummaryPublisher
            .removeDuplicates()
            .sink { [weak self] momentsSummary in
                self?.momentsSummary = momentsSummary
            }
            .store(in: &momentsCancellables)
    }

    func bind(accountStateProvider: any MomentsAccountStateProviding) {
        accountCancellables.removeAll()

        Publishers.CombineLatest(
            accountStateProvider.isSignedInPublisher,
            accountStateProvider.creditBalancePublisher
        )
        .sink { [weak self] isSignedIn, creditBalance in
            self?.isSignedIn = isSignedIn
            self?.creditBalance = creditBalance
        }
        .store(in: &accountCancellables)
    }
}
