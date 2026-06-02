import Combine
import XCTest
@testable import MomentsAV

@MainActor
final class MomentsAviViewModelTests: XCTestCase {
    func testSignedOutGuidanceAsksForAuthentication() {
        let presentation = MomentsAviPresentation.make(
            isSignedIn: false,
            projectSummary: MomentsProjectListSummary(),
            creditBalance: .empty
        )

        XCTAssertEqual(presentation.workflowFocusTitle, "Sign in first")
        XCTAssertTrue(presentation.workflowFocusMessage.contains("after sign in"))
        XCTAssertEqual(presentation.creditGuidanceMessage, "Credits appear here after sign in.")
    }

    func testActiveProjectsDriveWorkflowFocus() {
        let presentation = MomentsAviPresentation.make(
            isSignedIn: true,
            projectSummary: MomentsProjectListSummary.make(from: [
                makeProject(id: "active-1", status: "story_ready", updatedAt: 20),
                makeProject(id: "done-1", status: "completed", updatedAt: 10)
            ]),
            creditBalance: .empty
        )

        XCTAssertEqual(presentation.workflowFocusTitle, "Review active work")
        XCTAssertTrue(presentation.workflowFocusMessage.contains("1 Moment in In Progress"))
        XCTAssertEqual(presentation.workflowFocusSystemImage, "clock.badge.checkmark")
    }

    func testCreditGuidanceUsesSpendableBalance() {
        let presentation = MomentsAviPresentation.make(
            isSignedIn: true,
            projectSummary: MomentsProjectListSummary(),
            creditBalance: MomentsCreditBalance(proMonthly: 2, promotional: 1, purchased: 3)
        )

        XCTAssertTrue(presentation.creditGuidanceMessage.contains("6 credits are available"))
    }

    func testCreditGuidanceUsesSingularSpendableCredit() {
        let presentation = MomentsAviPresentation.make(
            isSignedIn: true,
            projectSummary: MomentsProjectListSummary(),
            creditBalance: MomentsCreditBalance(proMonthly: 1, promotional: 0, purchased: 0)
        )

        XCTAssertTrue(presentation.creditGuidanceMessage.contains("1 credit is available"))
    }

    func testZeroCreditsExplainFinalExportRequirement() {
        let presentation = MomentsAviPresentation.make(
            isSignedIn: true,
            projectSummary: MomentsProjectListSummary(),
            creditBalance: .empty
        )

        XCTAssertEqual(
            presentation.creditGuidanceMessage,
            "No credits are available. Final exports require credits after story review."
        )
    }

    func testViewModelExposesPresentationFromBoundState() {
        let summaryProvider = AviProjectSummaryProvider()
        let accountProvider = AviAccountStateProvider()
        let viewModel = MomentsAviViewModel()
        viewModel.bind(to: summaryProvider)
        viewModel.bind(accountStateProvider: accountProvider)

        accountProvider.isSignedIn.send(true)
        accountProvider.creditBalance.send(
            MomentsCreditBalance(proMonthly: 1, promotional: 0, purchased: 0)
        )
        summaryProvider.summary.send(
            MomentsProjectListSummary.make(from: [
                makeProject(id: "active-1", status: "story_ready", updatedAt: 20)
            ])
        )

        XCTAssertEqual(viewModel.presentation.workflowFocusTitle, "Review active work")
        XCTAssertTrue(viewModel.presentation.creditGuidanceMessage.contains("1 credit is available"))
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

    var inProgressSummaryPublisher: AnyPublisher<MomentsProjectListSummary, Never> {
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
