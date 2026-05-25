import Combine
import Foundation

@MainActor
final class MomentsAviViewModel: ObservableObject {
    @Published private(set) var projectSummary = MomentsProjectListSummary()
    @Published private(set) var isSignedIn = false
    @Published private(set) var creditBalance = MomentsCreditBalance.empty

    private var projectCancellables = Set<AnyCancellable>()
    private var accountCancellables = Set<AnyCancellable>()

    var workflowFocusTitle: String {
        guard isSignedIn else { return "Sign in first" }
        if projectSummary.inProgressCount > 0 { return "Review active work" }
        if projectSummary.finishedCount > 0 { return "Start the next memory" }
        return "Create the first memory"
    }

    var workflowFocusMessage: String {
        guard isSignedIn else {
            return "Avi guidance unlocks after sign in because projects and credits are tied to the account."
        }
        if projectSummary.inProgressCount > 0 {
            return "There \(projectSummary.inProgressCount == 1 ? "is" : "are") \(projectSummary.inProgressCount) \(inProgressProjectLabel) in progress. Check Projects for the next render or story step."
        }
        if projectSummary.finishedCount > 0 {
            return "Finished exports stay in Projects. Start a new draft in Create when the next occasion is ready."
        }
        return "Start in Create with one occasion and a tight media set. Avi can help turn that into story scenes."
    }

    var workflowFocusSystemImage: String {
        projectSummary.inProgressCount > 0 ? "clock.badge.checkmark" : "sparkles"
    }

    var creditGuidanceMessage: String {
        guard isSignedIn else {
            return "Credits appear here after sign in."
        }
        guard creditBalance.spendable > 0 else {
            return "No spendable credits are available. Final exports require credits after preview review."
        }
        return "\(MomentsCreditCopy.countTitle(creditBalance.spendable)) \(creditBalance.spendable == 1 ? "is" : "are") spendable for final exports. Monthly credits are used before promotional and purchased credits."
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

    private var inProgressProjectLabel: String {
        projectSummary.inProgressCount == 1 ? "project" : "projects"
    }

}
