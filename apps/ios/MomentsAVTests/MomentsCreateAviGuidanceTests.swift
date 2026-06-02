import XCTest
@testable import MomentsAV

final class MomentsCreateAviGuidanceTests: XCTestCase {
    func testSignedOutGuidanceInvitesSignInWithoutTechnicalCopy() {
        let guidance = MomentsCreateAviGuidanceResolver.make(
            isSignedIn: false,
            balance: .empty,
            selectedStyle: MomentCreationStyle.launchStyles[0],
            step: .status,
            isSetupLocked: false,
            setupErrorMessage: nil
        )

        XCTAssertEqual(guidance.emotion, .curious)
        XCTAssertEqual(guidance.message, "Connect your account to start your first memory video.")
        XCTAssertEqual(guidance.actionTitle, "Sign in")
    }

    func testSignedInWithoutCreditsAllowsLocalSetup() {
        let guidance = MomentsCreateAviGuidanceResolver.make(
            isSignedIn: true,
            balance: .empty,
            selectedStyle: MomentCreationStyle.launchStyles[0],
            step: .status,
            isSetupLocked: false,
            setupErrorMessage: nil
        )

        XCTAssertEqual(guidance.emotion, .happy)
        XCTAssertEqual(guidance.message, "Add photos or clips now. Credits are needed before creating the final video.")
        XCTAssertEqual(guidance.actionTitle, "Start Moment")
    }

    func testReadyStateStartsWithStyleGuidance() {
        let guidance = MomentsCreateAviGuidanceResolver.make(
            isSignedIn: true,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 1, purchased: 0),
            selectedStyle: MomentCreationStyle.launchStyles[0],
            step: .status,
            isSetupLocked: false,
            setupErrorMessage: nil
        )

        XCTAssertEqual(guidance.emotion, .happy)
        XCTAssertEqual(guidance.message, "Add photos or clips. Avi will prepare the first story.")
        XCTAssertEqual(guidance.actionTitle, "Start Moment")
    }

    func testSummaryMentionsSelectedStyleAndOptionalDetail() {
        let style = MomentCreationStyle.launchStyles[2]
        let guidance = MomentsCreateAviGuidanceResolver.make(
            isSignedIn: true,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 1, purchased: 0),
            selectedStyle: style,
            step: .summary,
            isSetupLocked: false,
            setupErrorMessage: nil
        )

        XCTAssertEqual(guidance.emotion, .focused)
        XCTAssertEqual(guidance.message, "\(style.title) is set. Add photos or clips next.")
        XCTAssertNil(guidance.actionTitle)
    }
}
