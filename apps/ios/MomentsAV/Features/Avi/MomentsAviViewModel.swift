import Combine
import Foundation

@MainActor
final class MomentsAviViewModel: ObservableObject {
    @Published private(set) var projectSummary = MomentsProjectListSummary()
    @Published private(set) var isSignedIn = false
    @Published private(set) var creditBalance = MomentsCreditBalance.empty

    private var projectCancellables = Set<AnyCancellable>()
    private var accountCancellables = Set<AnyCancellable>()

    var presentation: MomentsAviPresentation {
        MomentsAviPresentation.make(
            isSignedIn: isSignedIn,
            projectSummary: projectSummary,
            creditBalance: creditBalance
        )
    }

    func bind(to summaryProvider: any MomentsProjectSummaryProviding) {
        projectCancellables.removeAll()

        summaryProvider.projectSummaryPublisher
            .removeDuplicates()
            .sink { [weak self] projectSummary in
                self?.projectSummary = projectSummary
            }
            .store(in: &projectCancellables)
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
