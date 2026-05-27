import XCTest
@testable import MomentsAV

@MainActor
final class MomentsCreateAvailabilityPresentationTests: XCTestCase {
    func testWorkflowAvailabilityBuilderCarriesCapabilitiesAndMessages() {
        let availability = MomentsCreateWorkflowAvailability.make(
            canAddMedia: true,
            canDraftStory: false,
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
        XCTAssertFalse(availability.canDraftStory)
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
            activeProjectId: "project-1",
            hasMomentWorkspace: true,
            isImportingMedia: false,
            isMediaUploadConfigured: true,
            mediaRemainingSlots: 2,
            storyDraftWorkflow: nil,
            previewGenerationWorkflow: nil,
            finalRenderWorkflow: nil,
            template: .birthdayMessage,
            previewRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: true),
            finalRenderRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            latestPreview: nil,
            selectedMediaCount: 0
        )

        XCTAssertTrue(capability.canAddMedia)
        XCTAssertFalse(capability.canDraftStory)
        XCTAssertFalse(capability.canGeneratePreview)
        XCTAssertTrue(capability.canRefreshPreviewStatus)
        XCTAssertFalse(capability.canGenerateFinalRender)
        XCTAssertFalse(capability.canRefreshFinalRenderStatus)
    }

    func testWorkflowCapabilityFactoryBlocksMediaWithoutSlotsOrProject() {
        let withoutSlots = MomentsCreateWorkflowCapabilityFactory.make(
            activeProjectId: "project-1",
            hasMomentWorkspace: true,
            isImportingMedia: false,
            isMediaUploadConfigured: true,
            mediaRemainingSlots: 0,
            storyDraftWorkflow: nil,
            previewGenerationWorkflow: nil,
            finalRenderWorkflow: nil,
            template: .birthdayMessage,
            previewRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            finalRenderRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            latestPreview: nil,
            selectedMediaCount: 0
        )
        let withoutProject = MomentsCreateWorkflowCapabilityFactory.make(
            activeProjectId: nil,
            hasMomentWorkspace: false,
            isImportingMedia: false,
            isMediaUploadConfigured: true,
            mediaRemainingSlots: 2,
            storyDraftWorkflow: nil,
            previewGenerationWorkflow: nil,
            finalRenderWorkflow: nil,
            template: .birthdayMessage,
            previewRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            finalRenderRefreshAvailability: MomentsCreateTestFixtures.makeRefreshAvailability(canRefresh: false),
            latestPreview: nil,
            selectedMediaCount: 0
        )

        XCTAssertFalse(withoutSlots.canAddMedia)
        XCTAssertFalse(withoutProject.canAddMedia)
    }

    func testAvailabilityCopyUsesSingularAndPluralCreditMessages() {
        XCTAssertEqual(MomentsCreateAvailabilityCopy.draftSignInRequired, "Sign in before starting a project.")
        XCTAssertEqual(MomentsCreateAvailabilityCopy.mediaTemplateFull, "Avi has enough media for this video.")
        XCTAssertEqual(MomentsCreateAvailabilityCopy.storyMissingMedia, "Add photos or clips before preparing the story.")
        XCTAssertEqual(
            MomentsCreateAvailabilityCopy.finalRenderMissingWorkspace,
            "Wait for the project workspace to sync before rendering the final export."
        )
        XCTAssertEqual(
            MomentsCreateAvailabilityCopy.previewInsufficientCredits(missingCredits: 1),
            "Add 1 more credit before generating a preview."
        )
        XCTAssertEqual(
            MomentsCreateAvailabilityCopy.finalRenderInsufficientCredits(missingCredits: 2),
            "Add 2 more credits before final render."
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
            MomentsCreateAvailabilityCopy.mediaMissingProject
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
                hasMomentWorkspace: true,
                isStoryDrafting: false,
                isStoryDraftAvailable: true,
                isStoryDraftConfigured: true,
                mediaAssets: [],
                selectedMediaCount: 0,
                template: .birthdayMessage
            ),
            "Add 1 more photo or clip before generating a story."
        )
        XCTAssertNil(
            MomentsCreateAvailabilityMessageFactory.story(
                hasMomentWorkspace: true,
                isStoryDrafting: true,
                isStoryDraftAvailable: true,
                isStoryDraftConfigured: false,
                mediaAssets: [],
                selectedMediaCount: 0,
                template: .birthdayMessage
            )
        )
    }

    func testAvailabilityMessageFactoryFormatsPreviewCreditStates() {
        XCTAssertEqual(
            MomentsCreateAvailabilityMessageFactory.preview(
                activeProjectId: "project-1",
                isPreviewGenerationAvailable: true,
                isPreviewGenerating: false,
                isPreviewGenerationConfigured: true,
                project: MomentsCreateTestFixtures.makeProject(id: "project-1"),
                template: .birthdayMessage,
                balance: .empty
            ),
            "Add 1 more credit before generating a preview."
        )
    }

    func testAvailabilityMessageFactoryFormatsFinalRenderPreviewRequirement() {
        XCTAssertEqual(
            MomentsCreateAvailabilityMessageFactory.finalRender(
                activeProjectId: "project-1",
                isFinalRenderAvailable: true,
                isFinalRenderGenerating: false,
                isFinalRenderConfigured: true,
                project: MomentsCreateTestFixtures.makeProject(id: "project-1"),
                template: .birthdayMessage,
                balance: MomentsCreditBalance(proMonthly: 4, promotional: 0, purchased: 0),
                latestPreview: nil
            ),
            "Prepare the story before creating the final video."
        )
    }

    func testRefreshAvailabilityFactoryFormatsPreviewAndFinalMessages() {
        let preview = MomentsCreateRefreshAvailabilityFactory.preview(
            projectId: nil,
            job: nil,
            isAvailable: false,
            isConfigured: false,
            isRefreshing: false
        )
        let finalRender = MomentsCreateRefreshAvailabilityFactory.finalRender(
            projectId: "project-1",
            job: nil,
            isAvailable: true,
            isConfigured: true,
            isRefreshing: false
        )

        XCTAssertEqual(preview.message, "Open a project before refreshing preview status.")
        XCTAssertEqual(finalRender.message, "No final render job is available yet.")
    }
}
