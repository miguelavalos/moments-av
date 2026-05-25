import Combine
import XCTest
@testable import MomentsAV

@MainActor
final class MomentsAviViewModelTests: XCTestCase {
    func testSignedOutGuidanceAsksForAuthentication() {
        let viewModel = MomentsAviViewModel()

        XCTAssertEqual(viewModel.workflowFocusTitle, "Sign in first")
        XCTAssertTrue(viewModel.workflowFocusMessage.contains("after sign in"))
        XCTAssertEqual(viewModel.creditGuidanceMessage, "Credits appear here after sign in.")
    }

    func testActiveProjectsDriveWorkflowFocus() {
        let summaryProvider = AviProjectSummaryProvider()
        let accountProvider = AviAccountStateProvider()
        let viewModel = MomentsAviViewModel()
        viewModel.bind(to: summaryProvider)
        viewModel.bind(accountStateProvider: accountProvider)

        accountProvider.isSignedIn.send(true)
        summaryProvider.summary.send(
            MomentsProjectListSummary.make(from: [
                makeProject(id: "active-1", status: "story_ready", updatedAt: 20),
                makeProject(id: "done-1", status: "completed", updatedAt: 10)
            ])
        )

        XCTAssertEqual(viewModel.workflowFocusTitle, "Review active work")
        XCTAssertTrue(viewModel.workflowFocusMessage.contains("1 project in progress"))
        XCTAssertEqual(viewModel.workflowFocusSystemImage, "clock.badge.checkmark")
    }

    func testCreditGuidanceUsesSpendableBalance() {
        let accountProvider = AviAccountStateProvider()
        let viewModel = MomentsAviViewModel()
        viewModel.bind(accountStateProvider: accountProvider)

        accountProvider.isSignedIn.send(true)
        accountProvider.creditBalance.send(
            MomentsCreditBalance(proMonthly: 2, promotional: 1, purchased: 3)
        )

        XCTAssertTrue(viewModel.creditGuidanceMessage.contains("6 credits are spendable"))
    }

    func testZeroCreditsExplainFinalExportRequirement() {
        let accountProvider = AviAccountStateProvider()
        let viewModel = MomentsAviViewModel()
        viewModel.bind(accountStateProvider: accountProvider)

        accountProvider.isSignedIn.send(true)
        accountProvider.creditBalance.send(.empty)

        XCTAssertEqual(
            viewModel.creditGuidanceMessage,
            "No spendable credits are available. Final exports require credits after preview review."
        )
    }

    private func makeProject(id: String, status: String, updatedAt: Double) -> MomentDraftProject {
        MomentDraftProject(
            id: id,
            template: .birthdayMessage,
            status: status,
            title: id,
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: updatedAt
        )
    }
}

private final class AviProjectSummaryProvider: MomentsProjectSummaryProviding {
    let summary = CurrentValueSubject<MomentsProjectListSummary, Never>(MomentsProjectListSummary())

    var projectSummaryPublisher: AnyPublisher<MomentsProjectListSummary, Never> {
        summary.eraseToAnyPublisher()
    }
}

private final class AviAccountStateProvider: MomentsAccountStateProviding {
    let isSignedIn = CurrentValueSubject<Bool, Never>(false)
    let currentUserId = CurrentValueSubject<String?, Never>(nil)
    let displayName = CurrentValueSubject<String?, Never>(nil)
    let creditBalance = CurrentValueSubject<MomentsCreditBalance, Never>(.empty)

    var isSignedInPublisher: AnyPublisher<Bool, Never> {
        isSignedIn.eraseToAnyPublisher()
    }

    var currentUserIdPublisher: AnyPublisher<String?, Never> {
        currentUserId.eraseToAnyPublisher()
    }

    var displayNamePublisher: AnyPublisher<String?, Never> {
        displayName.eraseToAnyPublisher()
    }

    var creditBalancePublisher: AnyPublisher<MomentsCreditBalance, Never> {
        creditBalance.eraseToAnyPublisher()
    }
}
