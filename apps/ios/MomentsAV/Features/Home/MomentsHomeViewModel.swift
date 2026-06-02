import Combine
import Foundation

@MainActor
final class MomentsHomeViewModel: ObservableObject {
    @Published private(set) var momentsSummary = InProgressMomentsSummary()
    @Published private(set) var isSignedIn = false
    @Published private(set) var displayName: String?
    @Published private(set) var creditBalance = MomentsCreditBalance.empty

    private var momentsCancellables = Set<AnyCancellable>()
    private var accountCancellables = Set<AnyCancellable>()

    func bind(to summaryProvider: any InProgressMomentsSummaryProviding) {
        momentsCancellables.removeAll()

        summaryProvider.inProgressSummaryPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] momentsSummary in
                self?.momentsSummary = momentsSummary
            }
            .store(in: &momentsCancellables)
    }

    func bind(accountStateProvider: any MomentsAccountStateProviding) {
        accountCancellables.removeAll()

        Publishers.CombineLatest3(
            accountStateProvider.isSignedInPublisher,
            accountStateProvider.displayNamePublisher,
            accountStateProvider.creditBalancePublisher
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isSignedIn, displayName, creditBalance in
            self?.isSignedIn = isSignedIn
            self?.displayName = displayName
            self?.creditBalance = creditBalance
        }
        .store(in: &accountCancellables)
    }
}
