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

    func testPartyRecapRequiresOneSpendableCredit() {
        XCTAssertTrue(
            MomentsCreditGate.canAfford(
                MomentTemplate.partyRecap,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 1)
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
        XCTAssertEqual(MomentTemplate.birthdayMessage.durationSeconds, 15)
        XCTAssertEqual(MomentTemplate.birthdayMessage.creditCost, 1)
        XCTAssertEqual(MomentTemplate.birthdayMessage.minimumAssets, 1)
        XCTAssertEqual(MomentTemplate.birthdayMessage.maximumAssets, 12)

        XCTAssertEqual(MomentTemplate.partyRecap.durationSeconds, 15)
        XCTAssertEqual(MomentTemplate.partyRecap.creditCost, 1)
        XCTAssertEqual(MomentTemplate.partyRecap.minimumAssets, 1)
        XCTAssertEqual(MomentTemplate.partyRecap.maximumAssets, 12)

        XCTAssertEqual(MomentTemplate.softRoast.durationSeconds, 15)
        XCTAssertEqual(MomentTemplate.softRoast.creditCost, 1)
        XCTAssertEqual(MomentTemplate.softRoast.minimumAssets, 1)
        XCTAssertEqual(MomentTemplate.softRoast.maximumAssets, 12)
    }

    func testDraftFormRequiresOccasionBeforeCreate() {
        var form = MomentDraftForm(template: .birthdayMessage)

        XCTAssertTrue(form.canCreateDraft)

        form.occasion = "  "

        XCTAssertFalse(form.canCreateDraft)
    }

    func testDraftAvailabilityMessageUsesSingularMissingCredit() {
        var form = MomentDraftForm(template: .birthdayMessage)
        form.occasion = "Birthday"

        let availability = MomentDraftRules.availability(
            form: form,
            balance: .empty
        )

        XCTAssertEqual(
            MomentDraftRules.availabilityMessage(availability),
            "Add 1 more credit for this template."
        )
    }

    func testContinuingDraftFormUsesProjectFieldsAndFallbacks() {
        let project = MomentDraftProject(
            id: "project-1",
            template: .birthdayMessage,
            status: "draft",
            title: "Birthday",
            tone: "cinematic",
            tempo: "not-a-tempo",
            occasion: "Anniversary",
            details: "Use the beach clips.",
            durationSeconds: 15,
            creditCost: 1,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: 0
        )

        let form = MomentDraftForm.continuing(
            project: project,
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
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 12))
        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .birthdayMessage, selectedCount: 13))

        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 0))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 1))
        XCTAssertTrue(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 12))
        XCTAssertFalse(MomentsMediaRules.canStartPreview(template: .partyRecap, selectedCount: 13))
    }

    func testStoryDraftRulesUseSelectedConvexMediaCount() {
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

        XCTAssertTrue(MomentsStoryDraftRules.canDraft(mediaAssets: assets, template: .birthdayMessage))
        XCTAssertTrue(MomentsStoryDraftRules.canDraft(mediaAssets: assets, template: .partyRecap))
    }

    func testPreviewRulesRequireStoryReadyCreditsAndLimit() {
        let balance = MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 1)
        let project = MomentDraftProject(
            id: "project-1",
            template: .birthdayMessage,
            status: "story_ready",
            title: "Birthday",
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 15,
            creditCost: 1,
            previewCount: 2,
            previewLimit: 3,
            updatedAt: 0
        )

        XCTAssertTrue(MomentsPreviewRules.canGenerate(project: project, template: .birthdayMessage, balance: balance))

        let previewReadyProject = MomentDraftProject(
            id: project.id,
            template: project.template,
            status: "preview_ready",
            title: project.title,
            tone: project.tone,
            tempo: project.tempo,
            occasion: project.occasion,
            details: project.details,
            durationSeconds: project.durationSeconds,
            creditCost: project.creditCost,
            previewCount: project.previewCount,
            previewLimit: project.previewLimit,
            updatedAt: project.updatedAt
        )
        XCTAssertTrue(MomentsPreviewRules.canGenerate(project: previewReadyProject, template: .birthdayMessage, balance: balance))

        let limitedProject = MomentDraftProject(
            id: project.id,
            template: project.template,
            status: project.status,
            title: project.title,
            tone: project.tone,
            tempo: project.tempo,
            occasion: project.occasion,
            details: project.details,
            durationSeconds: project.durationSeconds,
            creditCost: project.creditCost,
            previewCount: 3,
            previewLimit: 3,
            updatedAt: project.updatedAt
        )
        XCTAssertFalse(MomentsPreviewRules.canGenerate(project: limitedProject, template: .birthdayMessage, balance: balance))
    }

    func testFinalRenderRulesRequirePreviewAndCredits() {
        let balance = MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 1)
        let project = MomentDraftProject(
            id: "project-1",
            template: .birthdayMessage,
            status: "preview_ready",
            title: "Birthday",
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 15,
            creditCost: 1,
            previewCount: 1,
            previewLimit: 3,
            updatedAt: 0
        )
        let preview = MomentArtifact(
            id: "preview-1",
            kind: "preview",
            r2Key: "momentsav/user/project/previews/preview-1.mp4",
            status: "available",
            hasWatermark: true,
            expiresAt: 0
        )

        XCTAssertTrue(
            MomentsFinalRenderRules.canGenerate(
                project: project,
                template: .birthdayMessage,
                balance: balance,
                latestPreview: preview
            )
        )
        XCTAssertFalse(
            MomentsFinalRenderRules.canGenerate(
                project: project,
                template: .birthdayMessage,
                balance: .empty,
                latestPreview: preview
            )
        )
        XCTAssertFalse(
            MomentsFinalRenderRules.canGenerate(
                project: project,
                template: .birthdayMessage,
                balance: balance,
                latestPreview: nil
            )
        )
    }
}
