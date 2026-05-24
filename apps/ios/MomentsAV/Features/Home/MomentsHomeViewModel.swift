import Combine
import Foundation

@MainActor
final class MomentsHomeViewModel: ObservableObject {
    @Published private(set) var projectSummary = MomentsProjectListSummary()
    @Published private(set) var isSignedIn = false
    @Published private(set) var displayName: String?
    @Published private(set) var creditBalance = MomentsCreditBalance.empty

    private var projectCancellables = Set<AnyCancellable>()
    private var accountCancellables = Set<AnyCancellable>()

    func bind(to summaryProvider: any MomentsProjectSummaryProviding) {
        projectCancellables.removeAll()

        summaryProvider.projectSummaryPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] projectSummary in
                self?.projectSummary = projectSummary
            }
            .store(in: &projectCancellables)
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
