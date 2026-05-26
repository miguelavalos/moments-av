import XCTest
@testable import MomentsAV

final class MomentsCreateAviGuidanceTests: XCTestCase {
    func testSignedOutGuidanceInvitesSignInWithoutTechnicalCopy() {
        let guidance = MomentsCreateAviGuidanceResolver.make(
            isSignedIn: false,
            balance: .empty,
            selectedStyle: MomentCreationStyle.launchStyles[0],
            step: .status,
            isDraftLocked: false,
            draftErrorMessage: nil
        )

        XCTAssertEqual(guidance.emotion, .curious)
        XCTAssertEqual(guidance.message, "Connect your account to start your first memory video.")
        XCTAssertEqual(guidance.actionTitle, "Sign in")
    }

    func testSignedInWithoutCreditsShowsOnlyWhatBlocksProgress() {
        let guidance = MomentsCreateAviGuidanceResolver.make(
            isSignedIn: true,
            balance: .empty,
            selectedStyle: MomentCreationStyle.launchStyles[0],
            step: .status,
            isDraftLocked: false,
            draftErrorMessage: nil
        )

        XCTAssertEqual(guidance.emotion, .warning)
        XCTAssertEqual(guidance.message, "You need 1 credit to start.")
        XCTAssertEqual(guidance.actionTitle, "Get credits")
    }

    func testReadyStateStartsWithStyleGuidance() {
        let guidance = MomentsCreateAviGuidanceResolver.make(
            isSignedIn: true,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 1, purchased: 0),
            selectedStyle: MomentCreationStyle.launchStyles[0],
            step: .status,
            isDraftLocked: false,
            draftErrorMessage: nil
        )

        XCTAssertEqual(guidance.emotion, .happy)
        XCTAssertEqual(guidance.message, "You are ready. Start with a style and I will shape the video from there.")
        XCTAssertEqual(guidance.actionTitle, "Start project")
    }

    func testSummaryMentionsSelectedStyleAndOptionalDetail() {
        let style = MomentCreationStyle.launchStyles[2]
        let guidance = MomentsCreateAviGuidanceResolver.make(
            isSignedIn: true,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 1, purchased: 0),
            selectedStyle: style,
            step: .summary,
            isDraftLocked: false,
            draftErrorMessage: nil
        )

        XCTAssertEqual(guidance.emotion, .focused)
        XCTAssertEqual(guidance.message, "\(style.title) is ready. You can create now or add one small detail.")
        XCTAssertNil(guidance.actionTitle)
    }
}
