import XCTest
@testable import MomentsAV

@MainActor
final class MomentsAccountDeletionPolicyTests: XCTestCase {
    func testDeletionRequiresExactConfirmation() {
        let eligibility = AccountDeletionEligibility(status: .eligible, blockers: [], currentJob: nil)

        XCTAssertFalse(MomentsAccountDeletionPolicy.canRequestDeletion(eligibility: eligibility, confirmationText: "delete"))
        XCTAssertFalse(MomentsAccountDeletionPolicy.canRequestDeletion(eligibility: eligibility, confirmationText: "DELETE "))
        XCTAssertTrue(MomentsAccountDeletionPolicy.canRequestDeletion(eligibility: eligibility, confirmationText: "DELETE"))
    }

    func testConservativeEligibilityWarnsAboutOtherAppsProAndBilling() {
        let summary = AccountSummary(
            linkedApps: [
                LinkedAccountApp(appId: "momentsav", label: nil),
                LinkedAccountApp(appId: "tuneav", label: nil)
            ],
            access: [
                MomentsAppAccess(appId: "momentsav", accessMode: "signedInPro", planTier: "pro")
            ],
            billing: AccountBillingSummary(subscriptions: [
                AccountBillingSubscription(id: "sub_1", appId: "momentsav", provider: "RevenueCat", status: "active")
            ])
        )

        let eligibility = MomentsAccountDeletionPolicy.conservativeEligibility(from: summary, copy: copy)

        XCTAssertEqual(eligibility.status, .eligible)
        XCTAssertEqual(Set(eligibility.warnings.map(\.type)), [.linkedApp, .activeProAccess, .activeBillingSubscription])
    }

    func testCanUnlinkCurrentAppOnlyWhenAnotherAppRemainsAndMomentsIsNotPro() {
        let unlinkable = AccountSummary(
            linkedApps: [
                LinkedAccountApp(appId: "momentsav", label: nil),
                LinkedAccountApp(appId: "seriesav", label: nil)
            ],
            access: [
                MomentsAppAccess(appId: "momentsav", accessMode: "signedInFree", planTier: "free")
            ]
        )
        let proMoments = AccountSummary(
            linkedApps: unlinkable.linkedApps,
            access: [
                MomentsAppAccess(appId: "momentsav", accessMode: "signedInPro", planTier: "pro")
            ]
        )
        let onlyMoments = AccountSummary(
            linkedApps: [
                LinkedAccountApp(appId: "momentsav", label: nil)
            ],
            access: unlinkable.access
        )

        XCTAssertTrue(MomentsAccountDeletionPolicy.canUnlinkCurrentApp(from: unlinkable))
        XCTAssertFalse(MomentsAccountDeletionPolicy.canUnlinkCurrentApp(from: proMoments))
        XCTAssertFalse(MomentsAccountDeletionPolicy.canUnlinkCurrentApp(from: onlyMoments))
    }

    private var copy: MomentsAccountDeletionPolicy.Copy {
        MomentsAccountDeletionPolicy.Copy(
            linkedAppTitle: "Linked app",
            linkedAppDetail: "Linked app detail",
            proTitle: "Pro",
            proDetail: "Pro detail",
            subscriptionTitle: "Subscription",
            subscriptionDetail: "Subscription detail",
            jobTitle: "Job",
            unavailableTitle: "Unavailable",
            unavailableDetail: "Unavailable detail"
        )
    }
}
