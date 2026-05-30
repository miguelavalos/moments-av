import XCTest
@testable import MomentsAV

@MainActor
final class MomentsCreateWorkflowPresentationTests: XCTestCase {
    func testDraftSetupPresentationFormatsIdleDraftState() {
        let presentation = MomentsCreateDraftSetupPresentation(
            templateSummary: MomentsCreateTemplateSummaryPresentation(
                template: .birthdayMessage,
                canAfford: true,
                spendPlanDescription: "Uses 1 monthly credit."
            ),
            canCreateDraft: true,
            workspaceSummary: MomentsCreateWorkspaceSummary()
        )

        XCTAssertEqual(presentation.createDraftTitle, "Use this theme")
        XCTAssertFalse(presentation.showsActiveProject)
        XCTAssertEqual(presentation.templateSummary.creditTitle, "1 cr")
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

        XCTAssertEqual(presentation.createDraftTitle, "Starting project...")
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
        XCTAssertEqual(presentation.templateSummary.creditTitle, "1 cr")
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
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            previewSummary: MomentsCreatePreviewSummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary()
        )

        XCTAssertFalse(presentation.showsWorkflowCards)
    }

    func testWorkflowPresentationCarriesWorkflowStateForActiveProject() {
        let preview = MomentsCreateTestFixtures.makeArtifact(id: "preview-1", kind: "preview")
        let finalExport = MomentsCreateTestFixtures.makeArtifact(id: "final-1", kind: "final_export")
        let latestPreviewJob = MomentsCreateTestFixtures.makeRenderJob(id: "preview-job", kind: "preview", status: "running")
        let latestFinalJob = MomentsCreateTestFixtures.makeRenderJob(id: "final-job", kind: "final_render", status: "queued")
        let mediaSummary = MomentsCreateMediaSummary(
            selectedMedia: [],
            syncedMediaAssets: [MomentsCreateTestFixtures.makeMediaAsset(id: "media-1")],
            isImporting: true,
            statusMessage: "Importing media."
        )
        let storySummary = MomentsCreateStorySummary(
            savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
            generatedScenes: [],
            isDrafting: true,
            statusMessage: "Drafting story."
        )
        let previewSummary = MomentsCreatePreviewSummary(
            activeProject: MomentsCreateTestFixtures.makeProject(id: "project-1"),
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
            hasMomentWorkspace: true,
            template: .birthdayMessage,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 2, purchased: 0),
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
            isSignedIn: true,
            hasMomentWorkspace: true,
            hasUnsavedLocalMoment: false,
            template: .birthdayMessage,
            creationStyleTitle: "Birthday Story",
            toneTitle: "Warm",
            tempoTitle: "Balanced",
            occasionTitle: "Birthday for Ava",
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 1, purchased: 0),
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            previewSummary: MomentsCreatePreviewSummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary(),
            isBuyingReviewBundle: true,
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
        XCTAssertTrue(presentation.isBuyingReviewBundle)
        XCTAssertFalse(presentation.canDraftStory)
        XCTAssertTrue(presentation.canGeneratePreview)
        XCTAssertEqual(presentation.creationStyleTitle, "Birthday Story")
        XCTAssertEqual(presentation.toneTitle, "Warm")
        XCTAssertEqual(presentation.tempoTitle, "Balanced")
        XCTAssertEqual(presentation.occasionTitle, "Birthday for Ava")
        XCTAssertEqual(presentation.storyAvailabilityMessage, "Draft story.")
        XCTAssertEqual(presentation.previewRefreshAvailabilityMessage, "Refresh preview.")
        XCTAssertEqual(presentation.finalRenderRefreshAvailabilityMessage, "Refresh final.")
    }

    func testWorkflowPresentationCarriesUnsavedLocalMomentContainmentState() {
        let presentation = MomentsCreateWorkflowPresentation.make(
            activeProjectId: nil,
            isSignedIn: true,
            hasMomentWorkspace: true,
            hasUnsavedLocalMoment: true,
            template: .birthdayMessage,
            creationStyleTitle: "Birthday Story",
            toneTitle: "Warm",
            tempoTitle: "Balanced",
            occasionTitle: "Birthday",
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(
                selectedMedia: [MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001")]
            ),
            storySummary: MomentsCreateStorySummary(),
            previewSummary: MomentsCreatePreviewSummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary(),
            isBuyingReviewBundle: false,
            availability: MomentsCreateWorkflowAvailability(
                canAddMedia: true,
                canDraftStory: false,
                canGeneratePreview: false,
                canRefreshPreviewStatus: false,
                canGenerateFinalRender: false,
                canRefreshFinalRenderStatus: false
            )
        )

        XCTAssertTrue(presentation.hasUnsavedLocalMoment)
        XCTAssertTrue(presentation.showsWorkflowCards)
        XCTAssertTrue(presentation.showsMediaFirstWorkspace)
    }

    func testWorkflowPresentationShowsBlockingPreparationForCriticalWork() {
        var presentation = MomentsCreateWorkflowPresentation(
            activeProjectId: "project-1",
            template: .birthdayMessage,
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(isImporting: true),
            storySummary: MomentsCreateStorySummary(),
            previewSummary: MomentsCreatePreviewSummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary()
        )

        XCTAssertTrue(presentation.showsBlockingPreparation)

        presentation.mediaSummary = MomentsCreateMediaSummary()
        presentation.storySummary = MomentsCreateStorySummary(isDrafting: true)
        XCTAssertTrue(presentation.showsBlockingPreparation)

        presentation.storySummary = MomentsCreateStorySummary()
        presentation.previewSummary = MomentsCreatePreviewSummary(isGenerating: true)
        XCTAssertTrue(presentation.showsBlockingPreparation)

        presentation.previewSummary = MomentsCreatePreviewSummary()
        presentation.finalRenderSummary = MomentsCreateFinalRenderSummary(isGenerating: true)
        XCTAssertTrue(presentation.showsBlockingPreparation)

        presentation.finalRenderSummary = MomentsCreateFinalRenderSummary()
        XCTAssertFalse(presentation.showsBlockingPreparation)
    }

    func testStorySummaryBuildsReviewScenesFromSavedScenes() {
        let summary = MomentsCreateStorySummary(
            savedScenes: [
                MomentsCreateTestFixtures.makeScene(id: "scene-2", sceneIndex: 1, caption: "Show the trip highlights."),
                MomentsCreateTestFixtures.makeScene(id: "scene-1", sceneIndex: 0, caption: "Open with the arrival.")
            ]
        )

        XCTAssertTrue(summary.hasScenes)
        XCTAssertEqual(summary.reviewScenes.map(\.title), ["Opening", "Main moments"])
        XCTAssertEqual(summary.reviewScenes.map(\.caption), ["Open with the arrival.", "Show the trip highlights."])
    }

    func testMediaPresentationFormatsSelectionAndSortsSyncedMedia() {
        let presentation = MomentsCreateMediaPresentation(
            activeProjectId: "project-1",
            template: .birthdayMessage,
            summary: MomentsCreateMediaSummary(
                selectedMedia: [MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001")],
                syncedMediaAssets: [
                    MomentsCreateTestFixtures.makeMediaAsset(id: "second", sortOrder: 1),
                    MomentsCreateTestFixtures.makeMediaAsset(id: "first", sortOrder: 0)
                ],
                isImporting: true,
                statusMessage: "Importing."
            ),
            canAddMedia: true,
            availabilityMessage: "Add media."
        )

        XCTAssertEqual(presentation.activeProjectId, "project-1")
        XCTAssertEqual(presentation.pickerTitle, "Adding media...")
        XCTAssertEqual(presentation.remainingSlots, 19)
        XCTAssertEqual(presentation.selectedCountTitle, "1 selected")
        XCTAssertEqual(presentation.selectionMessage, "")
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
                    MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001"),
                    MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000002")
                ]
            )
        )

        XCTAssertEqual(presentation.selectionMessage, "")
    }

    func testStoryPresentationFormatsDraftStateAndSortsSavedScenes() {
        let presentation = MomentsCreateStoryPresentation(
            summary: MomentsCreateStorySummary(
                savedScenes: [
                    MomentsCreateTestFixtures.makeScene(id: "scene-2", sceneIndex: 1),
                    MomentsCreateTestFixtures.makeScene(id: "scene-1", sceneIndex: 0)
                ],
                generatedScenes: [],
                isDrafting: true,
                statusMessage: "Drafting."
            ),
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 1, purchased: 0),
            canDraftStory: true,
            availabilityMessage: "Ready."
        )

        XCTAssertEqual(presentation.draftButtonTitle, "Preparing story...")
        XCTAssertEqual(presentation.emptyMessage, "Avi can prepare a story plan from your photos and clips.")
        XCTAssertEqual(presentation.savedScenes.map(\.id), ["scene-1", "scene-2"])
        XCTAssertTrue(presentation.canDraftStory)
        XCTAssertEqual(presentation.availabilityMessage, "Ready.")
    }

    func testPreviewPresentationFormatsUsageActionsAndArtifactState() {
        let presentation = MomentsCreatePreviewPresentation(
            summary: MomentsCreatePreviewSummary(
                activeProject: MomentsCreateTestFixtures.makeProject(id: "project-1"),
                latestPreview: MomentsCreateTestFixtures.makeArtifact(id: "preview-1", kind: "preview"),
                latestPreviewJob: MomentsCreateTestFixtures.makeRenderJob(id: "preview-job", kind: "preview", status: "running"),
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
        XCTAssertEqual(presentation.emptyMessage, "Generate a story before creating a preview.")
        XCTAssertTrue(presentation.showsEmptyState)
    }

    func testFinalRenderPresentationFormatsCreditActionsAndExportState() {
        let presentation = MomentsCreateFinalRenderPresentation(
            summary: MomentsCreateFinalRenderSummary(
                creditCost: 2,
                finalExport: MomentsCreateTestFixtures.makeArtifact(id: "final-1", kind: "final_export"),
                latestFinalJob: MomentsCreateTestFixtures.makeRenderJob(id: "final-job", kind: "final_render", status: "running"),
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
        XCTAssertEqual(presentation.refreshButtonTitle, "Refreshing final video...")
        XCTAssertEqual(presentation.generateButtonTitle, "Creating final video...")
        XCTAssertEqual(presentation.emptyMessage, "The story plan is ready. Create the final video when you are ready.")
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
        XCTAssertEqual(presentation.refreshButtonTitle, "Refresh final video")
        XCTAssertEqual(presentation.generateButtonTitle, "Create final video")
        XCTAssertEqual(presentation.emptyMessage, "Prepare the story before creating the final video.")
        XCTAssertTrue(presentation.showsEmptyState)
    }

    func testFinalRenderPresentationUsesSingularCreditCopy() {
        let presentation = MomentsCreateFinalRenderPresentation(
            summary: MomentsCreateFinalRenderSummary(creditCost: 1)
        )

        XCTAssertEqual(presentation.creditTitle, "1 credit")
    }

    func testRealtimeRenderPresentationFormatsActivePhaseAndProgress() {
        let job = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final_render",
            status: "running",
            phase: "rendering",
            progressPercent: 42,
            userMessage: "Rendering your video.",
            canEditDraft: false
        )

        let presentation = MomentsRenderRealtimePresentation(renderJob: job)

        XCTAssertEqual(presentation.title, "Rendering")
        XCTAssertEqual(presentation.detail, "Rendering your video.")
        XCTAssertEqual(presentation.progressFraction ?? -1, 0.42, accuracy: 0.001)
        XCTAssertEqual(presentation.systemImage, "gearshape.2.fill")
        XCTAssertTrue(presentation.isActive)
        XCTAssertFalse(presentation.canEditDraft)
    }

    func testRealtimeRenderPresentationFormatsFailedStatus() {
        let job = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final_render",
            status: "failed",
            canEditDraft: true,
            errorMessage: "fal provider request failed with upstream trace id abc123"
        )

        let presentation = MomentsRenderRealtimePresentation(renderJob: job)

        XCTAssertEqual(presentation.title, "Needs attention")
        XCTAssertEqual(
            presentation.detail,
            "Video creation hit a problem. Any reserved credits will be released if the video was not completed. Please try again or contact support."
        )
        XCTAssertEqual(presentation.systemImage, "exclamationmark.triangle.fill")
        XCTAssertFalse(presentation.isActive)
        XCTAssertTrue(presentation.canEditDraft)
    }

    func testRealtimeRenderPresentationUsesSafeFailedUserMessage() {
        let job = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final_render",
            status: "failed",
            userMessage: "We couldn’t finish this video. No credits were charged.",
            canEditDraft: true,
            errorMessage: "provider stack trace"
        )

        let presentation = MomentsRenderRealtimePresentation(renderJob: job)

        XCTAssertEqual(presentation.detail, "We couldn’t finish this video. No credits were charged.")
    }

    func testRecoveryCopyCoversMediaAndStoryFailurePaths() {
        XCTAssertEqual(
            MomentsRecoveryCopy.mediaImportFailure(),
            "Couldn’t add that media. Your photos are still on this device; try again or choose different items."
        )
        XCTAssertEqual(
            MomentsRecoveryCopy.mediaUploadUnavailable(),
            "Media upload is not ready yet. Your photos and videos are still on this device; please try again in a moment."
        )
        XCTAssertEqual(
            MomentsRecoveryCopy.mediaStorySaveFailure(),
            "Couldn’t save media for the story. Your photos and videos are still on this device; try again or choose different items."
        )
        XCTAssertEqual(
            MomentsRecoveryCopy.storyStartFailure(),
            "Couldn’t start a Moment for this story. No final video credits were used. Please try again."
        )
        XCTAssertEqual(
            MomentsRecoveryCopy.storyFailure(),
            "Avi couldn’t prepare the story right now. No final video credits were used. Please try again."
        )
        XCTAssertEqual(
            MomentsRecoveryCopy.previewStatusMissing(),
            "Preview status cannot be refreshed yet. Generate a preview again if this does not update."
        )
        XCTAssertEqual(
            MomentsRecoveryCopy.finalRenderStatusMissing(),
            "Final video status cannot be refreshed yet. Credits are only finalized when the video is ready. Please try again."
        )
    }

    func testWorkspaceSummaryFormatsProgressDetails() {
        let summary = MomentsCreateWorkspaceSummary(
            mediaCount: 2,
            sceneCount: 1,
            renderJobCount: 1,
            hasPreviewArtifact: false,
            hasFinalExport: false
        )

        XCTAssertEqual(summary.mediaDetail, "2 added")
        XCTAssertEqual(summary.storyDetail, "1 scene")
        XCTAssertEqual(summary.previewDetail, "Not made yet")
    }

}
