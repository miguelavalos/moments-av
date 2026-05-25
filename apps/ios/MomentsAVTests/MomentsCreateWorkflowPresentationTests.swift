import XCTest
@testable import MomentsAV

final class MomentsCreateWorkflowPresentationTests: XCTestCase {
    func testDraftSetupPresentationFormatsIdleDraftState() {
        let presentation = MomentsCreateDraftSetupPresentation(
            templateSummary: MomentsCreateTemplateSummaryPresentation(
                template: .birthdayMessage,
                canAfford: true,
                spendPlanDescription: "Uses 2 monthly credits."
            ),
            canCreateDraft: true,
            workspaceSummary: MomentsCreateWorkspaceSummary()
        )

        XCTAssertEqual(presentation.createDraftTitle, "Create draft")
        XCTAssertFalse(presentation.showsActiveProject)
        XCTAssertEqual(presentation.templateSummary.creditTitle, "2 cr")
        XCTAssertEqual(presentation.templateSummary.metadataTitle, "\(MomentTemplate.birthdayMessage.duration) · \(MomentTemplate.birthdayMessage.mediaRange)")
    }

    func testDraftSetupPresentationFormatsActiveContinuingProjectState() {
        let presentation = MomentsCreateDraftSetupPresentation(
            templateSummary: MomentsCreateTemplateSummaryPresentation(
                template: .partyRecap,
                canAfford: false,
                spendPlanDescription: "Buy credits to continue."
            ),
            isDraftLocked: true,
            isCreatingDraft: true,
            canCreateDraft: false,
            availabilityMessage: "Draft is locked.",
            activeProjectId: "project-1",
            isContinuingProject: true,
            canStartAnotherProject: true,
            draftErrorMessage: "Draft failed.",
            workspaceSummary: MomentsCreateWorkspaceSummary(mediaCount: 2, sceneCount: 1)
        )

        XCTAssertEqual(presentation.createDraftTitle, "Creating draft...")
        XCTAssertEqual(presentation.activeProjectLabel, "Continuing project")
        XCTAssertEqual(presentation.activeProjectDetail, "Create is attached to this existing project.")
        XCTAssertTrue(presentation.showsActiveProject)
        XCTAssertTrue(presentation.isDraftLocked)
        XCTAssertTrue(presentation.isCreatingDraft)
        XCTAssertFalse(presentation.canCreateDraft)
        XCTAssertEqual(presentation.availabilityMessage, "Draft is locked.")
        XCTAssertEqual(presentation.activeProjectId, "project-1")
        XCTAssertTrue(presentation.canStartAnotherProject)
        XCTAssertEqual(presentation.draftErrorMessage, "Draft failed.")
        XCTAssertEqual(presentation.workspaceSummary.mediaCount, 2)
        XCTAssertEqual(presentation.workspaceSummary.sceneCount, 1)
        XCTAssertFalse(presentation.templateSummary.canAfford)
        XCTAssertEqual(presentation.templateSummary.creditTitle, "3 cr")
    }

    func testDraftSetupPresentationBuilderCreatesTemplateSummary() {
        let presentation = MomentsCreateDraftSetupPresentation.make(
            template: .partyRecap,
            canAfford: false,
            spendPlanDescription: "Need credits.",
            isDraftLocked: true,
            isCreatingDraft: false,
            canCreateDraft: false,
            availabilityMessage: "Locked.",
            activeProjectId: "project-1",
            isContinuingProject: true,
            canStartAnotherProject: true,
            draftErrorMessage: nil,
            workspaceSummary: MomentsCreateWorkspaceSummary(mediaCount: 1)
        )

        XCTAssertEqual(presentation.templateSummary.template, .partyRecap)
        XCTAssertFalse(presentation.templateSummary.canAfford)
        XCTAssertEqual(presentation.templateSummary.spendPlanDescription, "Need credits.")
        XCTAssertEqual(presentation.activeProjectId, "project-1")
        XCTAssertEqual(presentation.workspaceSummary.mediaCount, 1)
    }

    func testWorkflowPresentationHidesWorkflowCardsWithoutProject() {
        let presentation = MomentsCreateWorkflowPresentation(
            activeProjectId: nil,
            template: .birthdayMessage,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            previewSummary: MomentsCreatePreviewSummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary()
        )

        XCTAssertFalse(presentation.showsWorkflowCards)
    }

    func testWorkflowPresentationCarriesWorkflowStateForActiveProject() {
        let preview = makeArtifact(id: "preview-1", kind: "preview")
        let finalExport = makeArtifact(id: "final-1", kind: "final_export")
        let latestPreviewJob = makeRenderJob(id: "preview-job", kind: "preview", status: "running")
        let latestFinalJob = makeRenderJob(id: "final-job", kind: "final_render", status: "queued")
        let mediaSummary = MomentsCreateMediaSummary(
            selectedMedia: [],
            syncedMediaAssets: [makeMediaAsset(id: "media-1")],
            isImporting: true,
            statusMessage: "Importing media."
        )
        let storySummary = MomentsCreateStorySummary(
            savedScenes: [makeScene(id: "scene-1")],
            generatedScenes: [],
            isDrafting: true,
            statusMessage: "Drafting story."
        )
        let previewSummary = MomentsCreatePreviewSummary(
            activeProject: makeProject(id: "project-1"),
            latestPreview: preview,
            latestPreviewJob: latestPreviewJob,
            isGenerating: true,
            isRefreshingStatus: false,
            statusMessage: "Generating preview."
        )
        let finalRenderSummary = MomentsCreateFinalRenderSummary(
            creditCost: 2,
            finalExport: finalExport,
            latestFinalJob: latestFinalJob,
            isGenerating: false,
            isRefreshingStatus: true,
            statusMessage: "Refreshing final render."
        )

        let presentation = MomentsCreateWorkflowPresentation(
            activeProjectId: "project-1",
            template: .birthdayMessage,
            mediaSummary: mediaSummary,
            storySummary: storySummary,
            previewSummary: previewSummary,
            finalRenderSummary: finalRenderSummary,
            canAddMedia: true,
            canDraftStory: true,
            canGeneratePreview: true,
            canRefreshPreviewStatus: true,
            canGenerateFinalRender: true,
            canRefreshFinalRenderStatus: true,
            mediaAvailabilityMessage: "Add media.",
            storyAvailabilityMessage: "Draft story.",
            previewAvailabilityMessage: "Generate preview.",
            previewRefreshAvailabilityMessage: "Refresh preview.",
            finalRenderAvailabilityMessage: "Generate final.",
            finalRenderRefreshAvailabilityMessage: "Refresh final."
        )

        XCTAssertTrue(presentation.showsWorkflowCards)
        XCTAssertEqual(presentation.activeProjectId, "project-1")
        XCTAssertEqual(presentation.template, .birthdayMessage)
        XCTAssertEqual(presentation.mediaSummary, mediaSummary)
        XCTAssertEqual(presentation.storySummary, storySummary)
        XCTAssertEqual(presentation.previewSummary, previewSummary)
        XCTAssertEqual(presentation.finalRenderSummary, finalRenderSummary)
        XCTAssertTrue(presentation.canAddMedia)
        XCTAssertTrue(presentation.canDraftStory)
        XCTAssertTrue(presentation.canGeneratePreview)
        XCTAssertTrue(presentation.canRefreshPreviewStatus)
        XCTAssertTrue(presentation.canGenerateFinalRender)
        XCTAssertTrue(presentation.canRefreshFinalRenderStatus)
        XCTAssertEqual(presentation.mediaAvailabilityMessage, "Add media.")
        XCTAssertEqual(presentation.storyAvailabilityMessage, "Draft story.")
        XCTAssertEqual(presentation.previewAvailabilityMessage, "Generate preview.")
        XCTAssertEqual(presentation.previewRefreshAvailabilityMessage, "Refresh preview.")
        XCTAssertEqual(presentation.finalRenderAvailabilityMessage, "Generate final.")
        XCTAssertEqual(presentation.finalRenderRefreshAvailabilityMessage, "Refresh final.")
    }

    func testWorkflowPresentationBuilderAppliesAvailabilityState() {
        let presentation = MomentsCreateWorkflowPresentation.make(
            activeProjectId: "project-1",
            template: .birthdayMessage,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            previewSummary: MomentsCreatePreviewSummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary(),
            availability: MomentsCreateWorkflowAvailability(
                canAddMedia: true,
                canDraftStory: false,
                canGeneratePreview: true,
                canRefreshPreviewStatus: false,
                canGenerateFinalRender: true,
                canRefreshFinalRenderStatus: false,
                mediaMessage: nil,
                storyMessage: "Draft story.",
                previewMessage: nil,
                previewRefreshMessage: "Refresh preview.",
                finalRenderMessage: nil,
                finalRenderRefreshMessage: "Refresh final."
            )
        )

        XCTAssertTrue(presentation.canAddMedia)
        XCTAssertFalse(presentation.canDraftStory)
        XCTAssertTrue(presentation.canGeneratePreview)
        XCTAssertEqual(presentation.storyAvailabilityMessage, "Draft story.")
        XCTAssertEqual(presentation.previewRefreshAvailabilityMessage, "Refresh preview.")
        XCTAssertEqual(presentation.finalRenderRefreshAvailabilityMessage, "Refresh final.")
    }

    func testMediaPresentationFormatsSelectionAndSortsSyncedMedia() {
        let presentation = MomentsCreateMediaPresentation(
            activeProjectId: "project-1",
            template: .birthdayMessage,
            summary: MomentsCreateMediaSummary(
                selectedMedia: [makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001")],
                syncedMediaAssets: [
                    makeMediaAsset(id: "second", sortOrder: 1),
                    makeMediaAsset(id: "first", sortOrder: 0)
                ],
                isImporting: true,
                statusMessage: "Importing."
            ),
            canAddMedia: true,
            availabilityMessage: "Add media."
        )

        XCTAssertEqual(presentation.activeProjectId, "project-1")
        XCTAssertEqual(presentation.pickerTitle, "Importing media...")
        XCTAssertEqual(presentation.remainingSlots, 19)
        XCTAssertEqual(presentation.selectedCountTitle, "Selected 1/3-20 photos or clips")
        XCTAssertEqual(presentation.selectionMessage, "Add 2 more synced media assets.")
        XCTAssertEqual(presentation.syncedMediaAssets.map(\.id), ["first", "second"])
        XCTAssertTrue(presentation.canAddMedia)
        XCTAssertEqual(presentation.availabilityMessage, "Add media.")
    }

    func testMediaPresentationUsesSingularMissingMediaCopy() {
        let presentation = MomentsCreateMediaPresentation(
            activeProjectId: "project-1",
            template: .birthdayMessage,
            summary: MomentsCreateMediaSummary(
                selectedMedia: [
                    makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001"),
                    makeSelectedMedia(id: "00000000-0000-0000-0000-000000000002")
                ]
            )
        )

        XCTAssertEqual(presentation.selectionMessage, "Add 1 more synced media asset.")
    }

    func testStoryPresentationFormatsDraftStateAndSortsSavedScenes() {
        let presentation = MomentsCreateStoryPresentation(
            summary: MomentsCreateStorySummary(
                savedScenes: [
                    makeScene(id: "scene-2", sceneIndex: 1),
                    makeScene(id: "scene-1", sceneIndex: 0)
                ],
                generatedScenes: [],
                isDrafting: true,
                statusMessage: "Drafting."
            ),
            canDraftStory: true,
            availabilityMessage: "Ready."
        )

        XCTAssertEqual(presentation.draftButtonTitle, "Drafting story...")
        XCTAssertEqual(presentation.emptyMessage, "Avi can draft the first story from the synced media.")
        XCTAssertEqual(presentation.savedScenes.map(\.id), ["scene-1", "scene-2"])
        XCTAssertTrue(presentation.canDraftStory)
        XCTAssertEqual(presentation.availabilityMessage, "Ready.")
    }

    func testPreviewPresentationFormatsUsageActionsAndArtifactState() {
        let presentation = MomentsCreatePreviewPresentation(
            summary: MomentsCreatePreviewSummary(
                activeProject: makeProject(id: "project-1"),
                latestPreview: makeArtifact(id: "preview-1", kind: "preview"),
                latestPreviewJob: makeRenderJob(id: "preview-job", kind: "preview", status: "running"),
                isGenerating: true,
                isRefreshingStatus: true,
                statusMessage: "Generating."
            ),
            canGeneratePreview: true,
            canRefreshPreviewStatus: true,
            availabilityMessage: "Generate preview.",
            refreshAvailabilityMessage: "Refresh preview."
        )

        XCTAssertEqual(presentation.usageTitle, "0/3 previews")
        XCTAssertEqual(presentation.previewArtifactMessage, "Includes a subtle Moments AV mark.")
        XCTAssertEqual(presentation.refreshButtonTitle, "Refreshing preview status...")
        XCTAssertEqual(presentation.generateButtonTitle, "Generating preview...")
        XCTAssertEqual(presentation.emptyMessage, "Story is ready. Generate a preview to review the result.")
        XCTAssertFalse(presentation.showsEmptyState)
        XCTAssertTrue(presentation.canGeneratePreview)
        XCTAssertTrue(presentation.canRefreshPreviewStatus)
        XCTAssertEqual(presentation.availabilityMessage, "Generate preview.")
        XCTAssertEqual(presentation.refreshAvailabilityMessage, "Refresh preview.")
    }

    func testPreviewPresentationFormatsUnavailableEmptyState() {
        let presentation = MomentsCreatePreviewPresentation(
            summary: MomentsCreatePreviewSummary(),
            canGeneratePreview: false
        )

        XCTAssertNil(presentation.usageTitle)
        XCTAssertNil(presentation.previewArtifactMessage)
        XCTAssertEqual(presentation.refreshButtonTitle, "Refresh preview status")
        XCTAssertEqual(presentation.generateButtonTitle, "Generate preview")
        XCTAssertEqual(presentation.emptyMessage, "Generate a story draft before creating a preview.")
        XCTAssertTrue(presentation.showsEmptyState)
    }

    func testFinalRenderPresentationFormatsCreditActionsAndExportState() {
        let presentation = MomentsCreateFinalRenderPresentation(
            summary: MomentsCreateFinalRenderSummary(
                creditCost: 2,
                finalExport: makeArtifact(id: "final-1", kind: "final_export"),
                latestFinalJob: makeRenderJob(id: "final-job", kind: "final_render", status: "running"),
                isGenerating: true,
                isRefreshingStatus: true,
                statusMessage: "Rendering."
            ),
            canGenerateFinalRender: true,
            canRefreshFinalRenderStatus: true,
            availabilityMessage: "Render final.",
            refreshAvailabilityMessage: "Refresh final."
        )

        XCTAssertEqual(presentation.creditTitle, "2 credits")
        XCTAssertEqual(presentation.refreshButtonTitle, "Refreshing final status...")
        XCTAssertEqual(presentation.generateButtonTitle, "Rendering final...")
        XCTAssertEqual(presentation.emptyMessage, "Preview is ready. Render the final export when approved.")
        XCTAssertFalse(presentation.showsEmptyState)
        XCTAssertTrue(presentation.canGenerateFinalRender)
        XCTAssertTrue(presentation.canRefreshFinalRenderStatus)
        XCTAssertEqual(presentation.availabilityMessage, "Render final.")
        XCTAssertEqual(presentation.refreshAvailabilityMessage, "Refresh final.")
    }

    func testFinalRenderPresentationFormatsUnavailableEmptyState() {
        let presentation = MomentsCreateFinalRenderPresentation(
            summary: MomentsCreateFinalRenderSummary(creditCost: 3),
            canGenerateFinalRender: false
        )

        XCTAssertEqual(presentation.creditTitle, "3 credits")
        XCTAssertEqual(presentation.refreshButtonTitle, "Refresh final status")
        XCTAssertEqual(presentation.generateButtonTitle, "Render final")
        XCTAssertEqual(presentation.emptyMessage, "Generate a preview before rendering the final export.")
        XCTAssertTrue(presentation.showsEmptyState)
    }

    func testFinalRenderPresentationUsesSingularCreditCopy() {
        let presentation = MomentsCreateFinalRenderPresentation(
            summary: MomentsCreateFinalRenderSummary(creditCost: 1)
        )

        XCTAssertEqual(presentation.creditTitle, "1 credit")
    }

    func testAvailabilityCopyUsesSingularAndPluralCreditMessages() {
        XCTAssertEqual(MomentsCreateAvailabilityCopy.draftSignInRequired, "Sign in before creating a draft.")
        XCTAssertEqual(MomentsCreateAvailabilityCopy.mediaTemplateFull, "Remove media before adding more to this template.")
        XCTAssertEqual(MomentsCreateAvailabilityCopy.storyMissingMedia, "Wait for synced media before drafting.")
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
                activeProjectId: nil,
                isImportingMedia: false,
                isMediaUploadConfigured: true,
                mediaRemainingSlots: 2
            ),
            MomentsCreateAvailabilityCopy.mediaMissingProject
        )
        XCTAssertNil(
            MomentsCreateAvailabilityMessageFactory.media(
                activeProjectId: "project-1",
                isImportingMedia: true,
                isMediaUploadConfigured: false,
                mediaRemainingSlots: 0
            )
        )
        XCTAssertEqual(
            MomentsCreateAvailabilityMessageFactory.media(
                activeProjectId: "project-1",
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
                activeProjectId: "project-1",
                isStoryDrafting: false,
                isStoryDraftAvailable: true,
                isStoryDraftConfigured: true,
                mediaAssets: [],
                template: .birthdayMessage
            ),
            "Add 3 more synced media assets before drafting."
        )
        XCTAssertNil(
            MomentsCreateAvailabilityMessageFactory.story(
                activeProjectId: "project-1",
                isStoryDrafting: true,
                isStoryDraftAvailable: true,
                isStoryDraftConfigured: false,
                mediaAssets: [],
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
                project: makeProject(id: "project-1"),
                template: .birthdayMessage,
                balance: .empty
            ),
            "Add 2 more credits before generating a preview."
        )
    }

    func testAvailabilityMessageFactoryFormatsFinalRenderPreviewRequirement() {
        XCTAssertEqual(
            MomentsCreateAvailabilityMessageFactory.finalRender(
                activeProjectId: "project-1",
                isFinalRenderAvailable: true,
                isFinalRenderGenerating: false,
                isFinalRenderConfigured: true,
                project: makeProject(id: "project-1"),
                template: .birthdayMessage,
                balance: MomentsCreditBalance(proMonthly: 4, promotional: 0, purchased: 0),
                latestPreview: nil
            ),
            "Generate a preview before rendering the final export."
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

    func testWorkspaceSummaryFormatsProgressDetails() {
        let summary = MomentsCreateWorkspaceSummary(
            mediaCount: 2,
            sceneCount: 1,
            renderJobCount: 1,
            hasPreviewArtifact: false,
            hasFinalExport: false
        )

        XCTAssertEqual(summary.mediaDetail, "2 synced")
        XCTAssertEqual(summary.storyDetail, "1 scene")
        XCTAssertEqual(summary.previewDetail, "1 render job")
    }

    private func makeProject(id: String) -> MomentDraftProject {
        MomentDraftProject(
            id: id,
            template: .birthdayMessage,
            status: "draft_created",
            title: "Family Weekend",
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: 10
        )
    }

    private func makeMediaAsset(id: String, sortOrder: Double = 0) -> MomentMediaAsset {
        MomentMediaAsset(
            id: id,
            platformMediaAssetId: "platform-\(id)",
            uploadId: "upload-\(id)",
            kind: "image",
            sortOrder: sortOrder,
            selected: true,
            moderationStatus: "approved",
            uploadedAt: nil,
            sourceExpiresAt: nil
        )
    }

    private func makeSelectedMedia(id: String) -> MomentsSelectedMedia {
        MomentsSelectedMedia(
            id: UUID(uuidString: id)!,
            sourceLocalIdentifier: id,
            originalFilename: "\(id).jpg",
            contentType: "image/jpeg",
            kind: "image",
            byteSize: 4,
            sha256: "abcd",
            data: Data([1, 2, 3, 4]),
            sortOrder: 0,
            selected: true
        )
    }

    private func makeScene(id: String, sceneIndex: Double = 0) -> MomentStoryScene {
        MomentStoryScene(
            id: id,
            sceneIndex: sceneIndex,
            mediaAssetIds: [],
            caption: "Opening",
            narrationText: nil,
            tone: nil,
            musicCue: nil,
            durationMs: 3_000,
            createdBy: "avi"
        )
    }

    private func makeArtifact(id: String, kind: String) -> MomentArtifact {
        MomentArtifact(
            id: id,
            kind: kind,
            r2Key: "momentsav/\(id).mp4",
            status: "available",
            hasWatermark: kind == "preview",
            expiresAt: 1_781_592_000_000
        )
    }

    private func makeRenderJob(id: String, kind: String, status: String) -> MomentRenderJob {
        MomentRenderJob(
            id: id,
            kind: kind,
            status: status,
            workflowRunId: "workflow-\(id)",
            provider: "mock-provider",
            model: "mock-model",
            providerRequestId: "request-\(id)",
            errorCode: nil,
            errorMessage: nil,
            createdAt: 9,
            updatedAt: 10
        )
    }
}
