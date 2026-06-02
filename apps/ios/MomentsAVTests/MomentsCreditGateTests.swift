import XCTest
@testable import MomentsAV

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

    func testPartyRecapRequiresTwoSpendableCredits() {
        XCTAssertTrue(
            MomentsCreditGate.canAfford(
                MomentTemplate.partyRecap,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 2)
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
        XCTAssertEqual(MomentTemplate.birthdayMessage.minimumAssets, 1)
        XCTAssertEqual(MomentTemplate.birthdayMessage.maximumAssets, 80)

        XCTAssertEqual(MomentTemplate.partyRecap.durationSeconds, 30)
        XCTAssertEqual(MomentTemplate.partyRecap.creditCost, 2)
        XCTAssertEqual(MomentTemplate.partyRecap.minimumAssets, 1)
        XCTAssertEqual(MomentTemplate.partyRecap.maximumAssets, 80)

        XCTAssertEqual(MomentTemplate.softRoast.durationSeconds, 30)
        XCTAssertEqual(MomentTemplate.softRoast.creditCost, 2)
        XCTAssertEqual(MomentTemplate.softRoast.minimumAssets, 1)
        XCTAssertEqual(MomentTemplate.softRoast.maximumAssets, 80)
    }

    func testSetupFormRequiresOccasionBeforeCreate() {
        var form = MomentSetupForm(template: .birthdayMessage)

        XCTAssertTrue(form.canCreateMoment)

        form.occasion = "  "

        XCTAssertFalse(form.canCreateMoment)
    }

    func testSetupAvailabilityAllowsSetupWithoutCredits() {
        var form = MomentSetupForm(template: .birthdayMessage)
        form.occasion = "Birthday"

        let availability = MomentSetupRules.availability(
            form: form,
            balance: .empty
        )

        XCTAssertTrue(availability.canCreateMoment)
        XCTAssertNil(MomentSetupRules.availabilityMessage(availability))
    }

    func testContinuingSetupFormUsesMomentFieldsAndFallbacks() {
        let moment = InProgressMoment(
            id: "moment-1",
            template: .birthdayMessage,
            status: "in_progress",
            title: "Birthday",
            tone: "cinematic",
            tempo: "not-a-tempo",
            occasion: "Anniversary",
            details: "Use the beach clips.",
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: 0
        )

        let form = MomentSetupForm.continuing(
            moment: moment,
            templates: MomentTemplate.launchTemplates
        )

        XCTAssertEqual(form?.template.id, .birthdayMessage)
        XCTAssertEqual(form?.occasion, "Anniversary")
        XCTAssertEqual(form?.recipient, "")
        XCTAssertEqual(form?.tone, .cinematic)
        XCTAssertEqual(form?.tempo, .balanced)
        XCTAssertEqual(form?.details, "Use the beach clips.")
    }

    func testMediaRulesEnforceTemplateMinimumsAndMaximums() {
        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 0))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 1))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 80))
        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 81))

        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 0))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 1))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 80))
        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 81))
    }

    func testStoryPlanRulesUseSelectedConvexMediaCount() {
        let assets = (0..<3).map {
            MomentMediaAsset(
                id: "media-\($0)",
                platformMediaAssetId: "platform-media-\($0)",
                uploadId: "upload-\($0)",
                kind: "photo",
                sortOrder: Double($0),
                selected: true,
                moderationStatus: "pending",
                uploadedAt: 1_779_000_000_000,
                sourceExpiresAt: 1_781_592_000_000
            )
        }

        XCTAssertTrue(MomentsStoryPlanRules.canPlan(mediaAssets: assets, template: .birthdayMessage))
        XCTAssertTrue(MomentsStoryPlanRules.canPlan(mediaAssets: assets, template: .partyRecap))
    }

    func testStoryPlanInputSignatureTracksMediaOrderAndDirection() {
        func storyMedia(id: String, sortOrder: Int) -> MomentsStoryPlanMedia {
            MomentsStoryPlanMedia(
                mediaAssetId: id,
                mediaKind: "image",
                sortOrder: sortOrder,
                selected: true,
                moderationStatus: "approved"
            )
        }

        var form = MomentSetupForm(template: .birthdayMessage)
        form.occasion = "Trip"
        form.details = "Use the desert photos."
        let media = [
            storyMedia(id: "media-a", sortOrder: 0),
            storyMedia(id: "media-b", sortOrder: 1)
        ]

        let baseSignature = MomentsStoryPlanInputSignature.make(
            momentId: "moment-1",
            form: form,
            selectedMedia: media
        )
        let sameInputSignature = MomentsStoryPlanInputSignature.make(
            momentId: "moment-1",
            form: form,
            selectedMedia: media.reversed()
        )

        XCTAssertEqual(baseSignature, sameInputSignature)

        let reorderedSignature = MomentsStoryPlanInputSignature.make(
            momentId: "moment-1",
            form: form,
            selectedMedia: [
                storyMedia(id: "media-a", sortOrder: 1),
                storyMedia(id: "media-b", sortOrder: 0)
            ]
        )
        XCTAssertNotEqual(baseSignature, reorderedSignature)

        form.details = "Use the desert photos and end on the group shot."
        let changedDirectionSignature = MomentsStoryPlanInputSignature.make(
            momentId: "moment-1",
            form: form,
            selectedMedia: media
        )
        XCTAssertNotEqual(baseSignature, changedDirectionSignature)
    }

    func testPreviewRulesRequireStoryReadyAndLimit() {
        let moment = InProgressMoment(
            id: "moment-1",
            template: .birthdayMessage,
            status: "story_ready",
            title: "Birthday",
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 2,
            previewLimit: 3,
            updatedAt: 0
        )

        XCTAssertTrue(MomentsPreviewRules.canGenerate(moment: moment, template: .birthdayMessage))

        let previewReadyMoment = InProgressMoment(
            id: moment.id,
            template: moment.template,
            status: "preview_ready",
            title: moment.title,
            tone: moment.tone,
            tempo: moment.tempo,
            occasion: moment.occasion,
            details: moment.details,
            durationSeconds: moment.durationSeconds,
            creditCost: moment.creditCost,
            previewCount: moment.previewCount,
            previewLimit: moment.previewLimit,
            updatedAt: moment.updatedAt
        )
        XCTAssertTrue(MomentsPreviewRules.canGenerate(moment: previewReadyMoment, template: .birthdayMessage))

        let limitedMoment = InProgressMoment(
            id: moment.id,
            template: moment.template,
            status: moment.status,
            title: moment.title,
            tone: moment.tone,
            tempo: moment.tempo,
            occasion: moment.occasion,
            details: moment.details,
            durationSeconds: moment.durationSeconds,
            creditCost: moment.creditCost,
            previewCount: 3,
            previewLimit: 3,
            updatedAt: moment.updatedAt
        )
        XCTAssertFalse(MomentsPreviewRules.canGenerate(moment: limitedMoment, template: .birthdayMessage))
    }

    func testFinalRenderRulesRequireReadyStatusAndCredits() {
        let balance = MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 2)
        let moment = InProgressMoment(
            id: "moment-1",
            template: .birthdayMessage,
            status: "preview_ready",
            title: "Birthday",
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 1,
            previewLimit: 3,
            updatedAt: 0
        )
        let preview = MomentArtifact(
            id: "preview-1",
            kind: "preview",
            r2Key: "momentsav/user/moment/previews/preview-1.mp4",
            status: "available",
            hasWatermark: true,
            expiresAt: 0
        )

        XCTAssertTrue(
            MomentsFinalRenderRules.canGenerate(
                moment: moment,
                template: .birthdayMessage,
                balance: balance,
                latestPreview: preview
            )
        )
        XCTAssertFalse(
            MomentsFinalRenderRules.canGenerate(
                moment: moment,
                template: .birthdayMessage,
                balance: .empty,
                latestPreview: preview
            )
        )
        XCTAssertTrue(
            MomentsFinalRenderRules.canGenerate(
                moment: moment,
                template: .birthdayMessage,
                balance: balance,
                latestPreview: nil
            )
        )
    }
}
