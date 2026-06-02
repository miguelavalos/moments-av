import XCTest
@testable import MomentsAV

@MainActor
final class MomentsCreateAvailabilityPresentationTests: XCTestCase {
    func testWorkflowAvailabilityBuilderCarriesCapabilitiesAndMessages() {
        let availability = MomentsCreateWorkflowAvailability.make(
            canAddMedia: true,
            canPlanStory: false,
            canGeneratePreview: true,
            canRefreshPreviewStatus: false,
            canGenerateFinalRender: true,
            canRefreshFinalRenderStatus: false,
            mediaMessage: "Media",
            storyMessage: "Story",
            previewMessage: "Preview",
            previewRefreshMessage: "Preview refresh",
            finalRenderMessage: "Final",
            finalRenderRefreshMessage: "Final refresh"
        )

        XCTAssertTrue(availability.canAddMedia)
        XCTAssertFalse(availability.canPlanStory)
        XCTAssertTrue(availability.canGeneratePreview)
        XCTAssertFalse(availability.canRefreshPreviewStatus)
        XCTAssertTrue(availability.canGenerateFinalRender)
        XCTAssertFalse(availability.canRefreshFinalRenderStatus)
        XCTAssertEqual(availability.mediaMessage, "Media")
        XCTAssertEqual(availability.storyMessage, "Story")
        XCTAssertEqual(availability.previewMessage, "Preview")
        XCTAssertEqual(availability.previewRefreshMessage, "Preview refresh")
        XCTAssertEqual(availability.finalRenderMessage, "Final")
        XCTAssertEqual(availability.finalRenderRefreshMessage, "Final refresh")
    }

    func testWorkflowCapabilityFactoryFormatsMediaAndRefreshCapabilities() {
        let capability = MomentsCreateWorkflowCapabilityFactory.make(
            activeMomentId: "moment-1",
            isSignedIn: true,
            hasMomentWorkspace: true,
            isImportingMedia: false,
            isMediaUploadConfigured: true,
            mediaRemainingSlots: 2,
            storyPlanWorkflow: nil,
            previewGenerationWorkflow: nil,
            finalRenderWorkflow: nil,
            template: .birthdayMessage,
            previewRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: true),
            finalRenderRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            latestPreview: nil,
            selectedMediaCount: 0
        )

        XCTAssertTrue(capability.canAddMedia)
        XCTAssertFalse(capability.canPlanStory)
        XCTAssertFalse(capability.canGeneratePreview)
        XCTAssertTrue(capability.canRefreshPreviewStatus)
        XCTAssertFalse(capability.canGenerateFinalRender)
        XCTAssertFalse(capability.canRefreshFinalRenderStatus)
    }

    func testWorkflowCapabilityFactoryBlocksMediaWithoutSlotsOrMoment() {
        let withoutSlots = MomentsCreateWorkflowCapabilityFactory.make(
            activeMomentId: "moment-1",
            isSignedIn: true,
            hasMomentWorkspace: true,
            isImportingMedia: false,
            isMediaUploadConfigured: true,
            mediaRemainingSlots: 0,
            storyPlanWorkflow: nil,
            previewGenerationWorkflow: nil,
            finalRenderWorkflow: nil,
            template: .birthdayMessage,
            previewRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            finalRenderRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            latestPreview: nil,
            selectedMediaCount: 0
        )
        let withoutMoment = MomentsCreateWorkflowCapabilityFactory.make(
            activeMomentId: nil,
            isSignedIn: true,
            hasMomentWorkspace: false,
            isImportingMedia: false,
            isMediaUploadConfigured: true,
            mediaRemainingSlots: 2,
            storyPlanWorkflow: nil,
            previewGenerationWorkflow: nil,
            finalRenderWorkflow: nil,
            template: .birthdayMessage,
            previewRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            finalRenderRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            latestPreview: nil,
            selectedMediaCount: 0
        )

        XCTAssertFalse(withoutSlots.canAddMedia)
        XCTAssertFalse(withoutMoment.canAddMedia)
    }

    func testAvailabilityCopyUsesSingularAndPluralCreditMessages() {
        XCTAssertEqual(MomentsCreateAvailabilityCopy.momentSignInRequired, "Sign in before starting a Moment.")
        XCTAssertEqual(MomentsCreateAvailabilityCopy.mediaTemplateFull, "Avi has enough media for this video.")
        XCTAssertEqual(MomentsCreateAvailabilityCopy.storyMissingMedia, "Add photos or clips before preparing the story.")
        XCTAssertEqual(
            MomentsCreateAvailabilityCopy.finalRenderMissingWorkspace,
            "Wait for this Moment to sync before creating the final video."
        )
        XCTAssertEqual(
            MomentsCreateAvailabilityCopy.previewInsufficientCredits(missingCredits: 1),
            "Add 1 more credit before reviewing the story."
        )
        XCTAssertEqual(
            MomentsCreateAvailabilityCopy.finalRenderInsufficientCredits(missingCredits: 2),
            "Add 2 more credits before creating the final video."
        )
    }

    func testAvailabilityMessageFactoryFormatsMediaStates() {
        XCTAssertEqual(
            MomentsCreateAvailabilityMessageFactory.media(
                hasMomentWorkspace: false,
                isImportingMedia: false,
                isMediaUploadConfigured: true,
                mediaRemainingSlots: 2
            ),
            MomentsCreateAvailabilityCopy.mediaMissingMoment
        )
        XCTAssertNil(
            MomentsCreateAvailabilityMessageFactory.media(
                hasMomentWorkspace: true,
                isImportingMedia: true,
                isMediaUploadConfigured: false,
                mediaRemainingSlots: 0
            )
        )
        XCTAssertEqual(
            MomentsCreateAvailabilityMessageFactory.media(
                hasMomentWorkspace: true,
                isImportingMedia: false,
                isMediaUploadConfigured: true,
                mediaRemainingSlots: 0
            ),
            MomentsCreateAvailabilityCopy.mediaTemplateFull
        )
    }

    func testAvailabilityMessageFactoryFormatsStoryStates() {
        XCTAssertEqual(
            MomentsCreateAvailabilityMessageFactory.story(
                isSignedIn: true,
                hasMomentWorkspace: true,
                isStoryPlanning: false,
                isStoryPlanAvailable: true,
                isStoryPlanConfigured: true,
                mediaAssets: [],
                selectedMediaCount: 0,
                template: .birthdayMessage
            ),
            "Add 1 more photo or clip before generating a story."
        )
        XCTAssertNil(
            MomentsCreateAvailabilityMessageFactory.story(
                isSignedIn: true,
                hasMomentWorkspace: true,
                isStoryPlanning: true,
                isStoryPlanAvailable: true,
                isStoryPlanConfigured: false,
                mediaAssets: [],
                selectedMediaCount: 0,
                template: .birthdayMessage
            )
        )
    }

    func testAvailabilityMessageFactoryFormatsPreviewCreditStates() {
        XCTAssertEqual(
            MomentsCreateAvailabilityMessageFactory.preview(
                activeMomentId: "moment-1",
                isPreviewGenerationAvailable: true,
                isPreviewGenerating: false,
                isPreviewGenerationConfigured: true,
                moment: MomentsCreateTestFixtures.makeMoment(id: "moment-1"),
                template: .birthdayMessage,
                balance: .empty
            ),
            "Generate a story before reviewing it."
        )
    }

    func testAvailabilityMessageFactoryFormatsFinalRenderPreviewRequirement() {
        XCTAssertEqual(
            MomentsCreateAvailabilityMessageFactory.finalRender(
                activeMomentId: "moment-1",
                isFinalRenderAvailable: true,
                isFinalRenderGenerating: false,
                isFinalRenderConfigured: true,
                moment: MomentsCreateTestFixtures.makeMoment(id: "moment-1"),
                template: .birthdayMessage,
                balance: MomentsCreditBalance(proMonthly: 4, promotional: 0, purchased: 0),
                latestPreview: nil
            ),
            "Prepare the story before creating the final video."
        )
    }

    func testRefreshAvailabilityFactoryFormatsPreviewAndFinalMessages() {
        let preview = MomentsCreateRefreshAvailabilityFactory.preview(
            momentId: nil,
            job: nil,
            isAvailable: false,
            isConfigured: false,
            isRefreshing: false
        )
        let finalRender = MomentsCreateRefreshAvailabilityFactory.finalRender(
            momentId: "moment-1",
            job: nil,
            isAvailable: true,
            isConfigured: true,
            isRefreshing: false
        )

        XCTAssertEqual(preview.message, "Open a moment before refreshing story review status.")
        XCTAssertEqual(finalRender.message, "No final video is available yet.")
    }
}
