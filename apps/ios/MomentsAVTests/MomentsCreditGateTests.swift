import XCTest
@testable import Moments_AV

final class MomentsCreditGateTests: XCTestCase {
    func testEmptyBalanceCannotAffordAnyLaunchTemplate() {
        XCTAssertFalse(
            MomentsCreditGate.canAffordAny(MomentTemplate.launchTemplates, balance: .empty)
        )
    }

    func testPurchasedCreditsAllowCreationWithoutProMonthlyCredits() {
        let balance = MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 2)

        XCTAssertTrue(
            MomentsCreditGate.canAfford(MomentTemplate.birthdayMessage, balance: balance)
        )
    }

    func testPartyRecapRequiresThreeSpendableCredits() {
        XCTAssertFalse(
            MomentsCreditGate.canAfford(
                MomentTemplate.partyRecap,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 2)
            )
        )

        XCTAssertTrue(
            MomentsCreditGate.canAfford(
                MomentTemplate.partyRecap,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 3)
            )
        )
    }

    func testSpendPlanUsesProThenPromotionalThenPurchasedCredits() {
        let plan = MomentsCreditGate.spendPlan(
            for: 5,
            balance: MomentsCreditBalance(proMonthly: 2, promotional: 2, purchased: 4)
        )

        XCTAssertEqual(
            plan,
            MomentsCreditSpendPlan(proMonthly: 2, promotional: 2, purchased: 1)
        )
    }

    func testSpendPlanIsNilWhenBalanceCannotCoverCost() {
        XCTAssertNil(
            MomentsCreditGate.spendPlan(
                for: 3,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 1, purchased: 1)
            )
        )
    }

    func testLaunchTemplateDurationsCreditsAndAssetRanges() {
        XCTAssertEqual(MomentTemplate.birthdayMessage.durationSeconds, 30)
        XCTAssertEqual(MomentTemplate.birthdayMessage.creditCost, 2)
        XCTAssertEqual(MomentTemplate.birthdayMessage.minimumAssets, 3)
        XCTAssertEqual(MomentTemplate.birthdayMessage.maximumAssets, 20)

        XCTAssertEqual(MomentTemplate.partyRecap.durationSeconds, 45)
        XCTAssertEqual(MomentTemplate.partyRecap.creditCost, 3)
        XCTAssertEqual(MomentTemplate.partyRecap.minimumAssets, 6)
        XCTAssertEqual(MomentTemplate.partyRecap.maximumAssets, 40)

        XCTAssertEqual(MomentTemplate.softRoast.durationSeconds, 30)
        XCTAssertEqual(MomentTemplate.softRoast.creditCost, 2)
        XCTAssertEqual(MomentTemplate.softRoast.minimumAssets, 3)
        XCTAssertEqual(MomentTemplate.softRoast.maximumAssets, 20)
    }

    func testDraftFormRequiresOccasionBeforeCreate() {
        var form = MomentDraftForm(template: .birthdayMessage)

        XCTAssertTrue(form.canCreateDraft)

        form.occasion = "  "

        XCTAssertFalse(form.canCreateDraft)
    }

    func testMediaRulesEnforceTemplateMinimumsAndMaximums() {
        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 2))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 3))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 20))
        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 21))

        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 5))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 6))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 40))
        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 41))
    }
}
