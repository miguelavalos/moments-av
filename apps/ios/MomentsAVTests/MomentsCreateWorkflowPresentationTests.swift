import XCTest
@testable import MomentsAV

@MainActor
final class MomentsCreateWorkflowPresentationTests: XCTestCase {
    func testWorkflowPresentationHidesWorkflowCardsWithoutMoment() {
        let presentation = MomentsCreateWorkflowPresentation(
            activeMomentId: nil,
            template: .birthdayMessage,
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary()
        )

        XCTAssertFalse(presentation.showsWorkflowCards)
    }

    func testWorkflowPresentationLocksEditingDuringActiveFinalRender() {
        let activeFinalJob = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final",
            status: "running",
            canEditSetup: false
        )
        let presentation = MomentsCreateWorkflowPresentation(
            activeMomentId: "moment-1",
            hasMomentWorkspace: true,
            template: .birthdayMessage,
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary(latestFinalJob: activeFinalJob)
        )

        XCTAssertTrue(presentation.isFinalRenderEditingLocked)
    }

    func testLockedFinalRenderMediaCountUsesJobCountAfterLocalSelectionReloadsEmpty() {
        let activeFinalJob = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final",
            status: "running",
            canEditSetup: false,
            totalCreditCost: 1,
            plannedAssetCount: 6,
            usedAssetCount: 6
        )
        let presentation = MomentsCreateWorkflowPresentation(
            activeMomentId: "moment-1",
            hasMomentWorkspace: true,
            template: .birthdayMessage,
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary(latestFinalJob: activeFinalJob)
        )

        XCTAssertTrue(presentation.isFinalRenderEditingLocked)
        XCTAssertEqual(presentation.lockedFinalRenderMediaCountTitle, "6 items")
    }

    func testLockedFinalRenderCostUsesConfirmedPlanCost() {
        let activeFinalJob = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final",
            status: "running",
            canEditSetup: false,
            plannedAssetCount: 6,
            usedAssetCount: 6
        )
        let oneCreditPlan = MomentsCreateTestFixtures.makeRenderPlan(
            totalCreditCost: 1,
            minimumDurationMs: 8_000,
            targetDurationMs: 15_000,
            plannedAssetCount: 6,
            usedAssetCount: 6
        )
        let presentation = MomentsCreateWorkflowPresentation(
            activeMomentId: "moment-1",
            hasMomentWorkspace: true,
            template: .birthdayMessage,
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary(
                creditCost: 2,
                renderPlan: oneCreditPlan,
                latestFinalJob: activeFinalJob
            )
        )

        XCTAssertTrue(presentation.isFinalRenderEditingLocked)
        XCTAssertEqual(presentation.finalRenderSummary.effectiveCreditCost, 1)
        XCTAssertEqual(presentation.lockedFinalRenderCreditCost, 1)
    }

    func testWorkflowPresentationAllowsEditingWhenFinalRenderAllowsSetupChanges() {
        let editableFinalJob = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final",
            status: "running",
            canEditSetup: true
        )
        let presentation = MomentsCreateWorkflowPresentation(
            activeMomentId: "moment-1",
            hasMomentWorkspace: true,
            template: .birthdayMessage,
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary(latestFinalJob: editableFinalJob)
        )

        XCTAssertFalse(presentation.isFinalRenderEditingLocked)
    }

    func testWorkflowPresentationCarriesWorkflowStateForActiveMoment() {
        let finalExport = MomentsCreateTestFixtures.makeArtifact(id: "final-1", kind: "final_export")
        let latestFinalJob = MomentsCreateTestFixtures.makeRenderJob(id: "final-job", kind: "final", status: "queued")
        let mediaSummary = MomentsCreateMediaSummary(
            selectedMedia: [],
            syncedMediaAssets: [MomentsCreateTestFixtures.makeMediaAsset(id: "media-1")],
            isImporting: true,
            statusMessage: "Importing media."
        )
        let storySummary = MomentsCreateStorySummary(
            savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")],
            generatedScenes: [],
            isPlanning: true,
            statusMessage: "Planning story."
        )
        let finalRenderSummary = MomentsCreateFinalRenderSummary(
            creditCost: 2,
            finalExport: finalExport,
            latestFinalJob: latestFinalJob,
            isGenerating: false,
            statusMessage: "Final render is queued."
        )

        let presentation = MomentsCreateWorkflowPresentation(
            activeMomentId: "moment-1",
            hasMomentWorkspace: true,
            template: .birthdayMessage,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 2, purchased: 0),
            mediaSummary: mediaSummary,
            storySummary: storySummary,
            finalRenderSummary: finalRenderSummary,
            canAddMedia: true,
            canPlanStory: true,
            canPrepareFinalRenderPlan: true,
            canGenerateFinalRender: true,
            canRefreshFinalRenderStatus: true,
            mediaAvailabilityMessage: "Add media.",
            storyAvailabilityMessage: "Plan story.",
            finalRenderAvailabilityMessage: "Generate final."
        )

        XCTAssertTrue(presentation.showsWorkflowCards)
        XCTAssertEqual(presentation.activeMomentId, "moment-1")
        XCTAssertEqual(presentation.template, .birthdayMessage)
        XCTAssertEqual(presentation.mediaSummary, mediaSummary)
        XCTAssertEqual(presentation.storySummary, storySummary)
        XCTAssertEqual(presentation.finalRenderSummary, finalRenderSummary)
        XCTAssertTrue(presentation.canAddMedia)
        XCTAssertTrue(presentation.canPlanStory)
        XCTAssertTrue(presentation.canPrepareFinalRenderPlan)
        XCTAssertTrue(presentation.canGenerateFinalRender)
        XCTAssertTrue(presentation.canRefreshFinalRenderStatus)
        XCTAssertEqual(presentation.mediaAvailabilityMessage, "Add media.")
        XCTAssertEqual(presentation.storyAvailabilityMessage, "Plan story.")
        XCTAssertEqual(presentation.finalRenderAvailabilityMessage, "Generate final.")
    }

    func testWorkflowPresentationBuilderAppliesAvailabilityState() {
        let presentation = MomentsCreateWorkflowPresentation.make(
            activeMomentId: "moment-1",
            isSignedIn: true,
            isCreatingMoment: false,
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
            finalRenderSummary: MomentsCreateFinalRenderSummary(),
            availability: MomentsCreateWorkflowAvailability(
                canAddMedia: true,
                canPlanStory: false,
                canPrepareFinalRenderPlan: true,
                canGenerateFinalRender: true,
                canRefreshFinalRenderStatus: false,
                mediaMessage: nil,
                storyMessage: "Plan story.",
                finalRenderMessage: nil
            )
        )

        XCTAssertTrue(presentation.canAddMedia)
        XCTAssertFalse(presentation.canPlanStory)
        XCTAssertTrue(presentation.canPrepareFinalRenderPlan)
        XCTAssertEqual(presentation.creationStyleTitle, "Birthday Story")
        XCTAssertEqual(presentation.toneTitle, "Warm")
        XCTAssertEqual(presentation.tempoTitle, "Balanced")
        XCTAssertEqual(presentation.occasionTitle, "Birthday for Ava")
        XCTAssertEqual(presentation.storyAvailabilityMessage, "Plan story.")
    }

    func testWorkflowPresentationCarriesUnsavedLocalMomentContainmentState() {
        let presentation = MomentsCreateWorkflowPresentation.make(
            activeMomentId: nil,
            isSignedIn: true,
            isCreatingMoment: false,
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
            finalRenderSummary: MomentsCreateFinalRenderSummary(),
            availability: MomentsCreateWorkflowAvailability(
                canAddMedia: true,
                canPlanStory: false,
                canPrepareFinalRenderPlan: false,
                canGenerateFinalRender: false,
                canRefreshFinalRenderStatus: false
            )
        )

        XCTAssertTrue(presentation.hasUnsavedLocalMoment)
        XCTAssertTrue(presentation.showsWorkflowCards)
        XCTAssertTrue(presentation.showsMediaFirstWorkspace)
    }

    func testWorkflowPresentationShowsMediaChoiceForEmptyLocalMoment() {
        let presentation = MomentsCreateWorkflowPresentation.make(
            activeMomentId: nil,
            isSignedIn: true,
            isCreatingMoment: false,
            hasMomentWorkspace: false,
            hasUnsavedLocalMoment: true,
            template: .birthdayMessage,
            creationStyleTitle: "Birthday Story",
            toneTitle: "Warm",
            tempoTitle: "Balanced",
            occasionTitle: "Birthday",
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(),
            storySummary: MomentsCreateStorySummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary(),
            availability: MomentsCreateWorkflowAvailability(
                canAddMedia: true,
                canPlanStory: false,
                canPrepareFinalRenderPlan: false,
                canGenerateFinalRender: false,
                canRefreshFinalRenderStatus: false
            )
        )

        XCTAssertFalse(presentation.showsWorkflowCards)
        XCTAssertTrue(presentation.showsMediaFirstWorkspace)
    }

    func testWorkflowPresentationShowsBlockingPreparationForCriticalWork() {
        var presentation = MomentsCreateWorkflowPresentation(
            activeMomentId: "moment-1",
            template: .birthdayMessage,
            balance: .empty,
            mediaSummary: MomentsCreateMediaSummary(isImporting: true),
            storySummary: MomentsCreateStorySummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary()
        )

        XCTAssertTrue(presentation.showsBlockingPreparation)

        presentation.mediaSummary = MomentsCreateMediaSummary()
        presentation.storySummary = MomentsCreateStorySummary(isPlanning: true)
        XCTAssertTrue(presentation.showsBlockingPreparation)

        presentation.finalRenderSummary = MomentsCreateFinalRenderSummary(isGenerating: true)
        XCTAssertTrue(presentation.showsBlockingPreparation)

        presentation.storySummary = MomentsCreateStorySummary()
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

    func testAviCutPresentationFormatsReadyCutState() {
        let presentation = MomentsCreateAviCutPresentation(
            mediaSummary: MomentsCreateMediaSummary(
                selectedMedia: [
                    MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001"),
                    MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000002")
                ]
            ),
            storySummary: MomentsCreateStorySummary(
                savedScenes: [
                    MomentsCreateTestFixtures.makeScene(id: "scene-1", sceneIndex: 0),
                    MomentsCreateTestFixtures.makeScene(id: "scene-2", sceneIndex: 1),
                    MomentsCreateTestFixtures.makeScene(id: "scene-3", sceneIndex: 2),
                    MomentsCreateTestFixtures.makeScene(id: "scene-4", sceneIndex: 3)
                ]
            ),
            selectedDuration: .standard,
            canImproveWithAvi: true
        )

        XCTAssertEqual(
            presentation.statusMessage,
            "Avi's Cut is ready. Create the final video or adjust the cut first."
        )
        XCTAssertEqual(presentation.modeTitle, "Avi's choice")
        XCTAssertEqual(presentation.mediaCountTitle, "2 items")
        XCTAssertEqual(presentation.primaryActionTitle, "Improve with Avi")
        XCTAssertEqual(presentation.editActionTitle, "Edit Cut")
        XCTAssertTrue(presentation.canRunPrimaryAction)
        XCTAssertTrue(presentation.canShowImproveAction)
        XCTAssertEqual(presentation.visibleScenes.count, 2)
        XCTAssertEqual(presentation.remainingSceneTitle, "2 more scenes in this cut")
    }

    func testAviCutPresentationKeepsFinalPathNonBlockingWhenImproveIsUnavailable() {
        let presentation = MomentsCreateAviCutPresentation(
            mediaSummary: MomentsCreateMediaSummary(
                selectedMedia: [MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001")]
            ),
            storySummary: MomentsCreateStorySummary(
                savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")]
            ),
            selectedDuration: .standard,
            canImproveWithAvi: false,
            availabilityMessage: "Improve with Avi is cooling down."
        )

        XCTAssertEqual(
            presentation.statusMessage,
            "Avi's Cut is ready. Create the final video or adjust the cut first."
        )
        XCTAssertEqual(presentation.primaryActionTitle, "Improve with Avi")
        XCTAssertFalse(presentation.canRunPrimaryAction)
        XCTAssertFalse(presentation.canShowImproveAction)
    }

    func testAviCutPresentationFormatsPendingAndUnavailableStates() {
        var presentation = MomentsCreateAviCutPresentation(
            mediaSummary: MomentsCreateMediaSummary(
                selectedMedia: [MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001")]
            ),
            storySummary: MomentsCreateStorySummary(),
            selectedDuration: .standard,
            canImproveWithAvi: true
        )

        XCTAssertEqual(presentation.statusMessage, "Ready for Avi to prepare a first cut.")
        XCTAssertEqual(presentation.modeTitle, "Ready")
        XCTAssertEqual(presentation.mediaCountTitle, "1 item")
        XCTAssertEqual(presentation.primaryActionTitle, "Create preview")
        XCTAssertTrue(presentation.canRunPrimaryAction)
        XCTAssertFalse(presentation.canShowImproveAction)

        presentation.canImproveWithAvi = false
        presentation.availabilityMessage = "Sign in before preparing Avi's Cut."
        XCTAssertEqual(presentation.statusMessage, "Sign in before preparing Avi's Cut.")
        XCTAssertFalse(presentation.canRunPrimaryAction)
    }

    func testMediaPresentationFormatsSelectionAndSortsSyncedMedia() {
        let presentation = MomentsCreateMediaPresentation(
            activeMomentId: "moment-1",
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

        XCTAssertEqual(presentation.activeMomentId, "moment-1")
        XCTAssertEqual(presentation.pickerTitle, "Adding media...")
        XCTAssertEqual(presentation.remainingSlots, 79)
        XCTAssertEqual(presentation.selectedCountTitle, "1 selected")
        XCTAssertEqual(presentation.selectionMessage, "")
        XCTAssertEqual(presentation.syncedMediaAssets.map(\.id), ["first", "second"])
        XCTAssertTrue(presentation.canAddMedia)
        XCTAssertEqual(presentation.availabilityMessage, "Add media.")
    }

    func testMediaPresentationUsesSingularMissingMediaCopy() {
        let presentation = MomentsCreateMediaPresentation(
            activeMomentId: "moment-1",
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

    func testStoryPresentationFormatsPlanStateAndSortsSavedScenes() {
        let presentation = MomentsCreateStoryPresentation(
            summary: MomentsCreateStorySummary(
                savedScenes: [
                    MomentsCreateTestFixtures.makeScene(id: "scene-2", sceneIndex: 1),
                    MomentsCreateTestFixtures.makeScene(id: "scene-1", sceneIndex: 0)
                ],
                generatedScenes: [],
                isPlanning: true,
                statusMessage: "Planning."
            ),
            canPlanStory: true,
            availabilityMessage: "Ready."
        )

        XCTAssertEqual(presentation.planButtonTitle, "Preparing story...")
        XCTAssertEqual(presentation.emptyMessage, "Avi can prepare a story plan from your photos and clips.")
        XCTAssertEqual(presentation.savedScenes.map(\.id), ["scene-1", "scene-2"])
        XCTAssertTrue(presentation.canPlanStory)
        XCTAssertEqual(presentation.availabilityMessage, "Ready.")
    }

    func testFinalVideoActionPresentationSeparatesPlanAndCreditConfirmation() {
        let planning = MomentsCreateFinalVideoActionPresentation(
            summary: MomentsCreateFinalRenderSummary(creditCost: 2),
            template: .birthdayMessage,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 3, purchased: 0)
        )

        XCTAssertFalse(planning.hasRenderPlan)
        XCTAssertEqual(planning.primaryTitle, "Review credits")
        XCTAssertEqual(planning.primaryIconName, "creditcard.fill")
        XCTAssertEqual(planning.creditPolicyMessage, "Avi checks media and credits before creating the final video.")
        XCTAssertTrue(planning.canAffordSelectedCost)

        let ready = MomentsCreateFinalVideoActionPresentation(
            summary: MomentsCreateFinalRenderSummary(
                creditCost: 2,
                renderPlan: MomentsCreateTestFixtures.makeRenderPlan()
            ),
            template: .birthdayMessage,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 3, purchased: 0),
            removesWatermark: true
        )

        XCTAssertTrue(ready.hasRenderPlan)
        XCTAssertEqual(ready.totalCreditCostTitle, "2 credits")
        XCTAssertEqual(ready.primaryTitle, "Confirm credits · 2 credits")
        XCTAssertEqual(ready.primaryIconName, "video.fill")
        XCTAssertEqual(
            ready.creditPolicyMessage,
            "Credits are only charged for completed final videos. This video costs 2 credits."
        )
        XCTAssertEqual(
            ready.confirmationMessage,
            "Credits are only charged for completed final videos. This video costs 2 credits."
        )
    }

    func testPrimaryActionPresentationBlocksUnavailableFinalProviderPlan() {
        let unavailablePlan = MomentsRenderPlanResponse(
            appId: "momentsav",
            momentId: "moment-1",
            planId: "plan-1",
            plan: MomentsCreateTestFixtures.makeRenderPlan().plan,
            canCreateVideo: false,
            createVideoBlockers: ["provider_adapter_unavailable"],
            generatedAt: "2026-06-02T00:00:00Z"
        )
        let workflow = MomentsCreateWorkflowPresentation(
            activeMomentId: "moment-1",
            isSignedIn: true,
            hasMomentWorkspace: true,
            template: .birthdayMessage,
            balance: MomentsCreditBalance(proMonthly: 0, promotional: 3, purchased: 0),
            mediaSummary: MomentsCreateMediaSummary(
                selectedMedia: [MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001")]
            ),
            storySummary: MomentsCreateStorySummary(),
            finalRenderSummary: MomentsCreateFinalRenderSummary(
                creditCost: 2,
                renderPlan: unavailablePlan
            ),
            canPrepareFinalRenderPlan: true,
            canGenerateFinalRender: true
        )
        let presentation = MomentsCreatePrimaryActionPresentation(workflow: workflow)

        XCTAssertFalse(presentation.canRunPrimaryAction)
        XCTAssertEqual(presentation.buttonIconName, "exclamationmark.triangle.fill")
        XCTAssertEqual(presentation.statusMessage, "This video option is not available yet.")
    }

    func testPrimaryActionPresentationKeepsCreateVideoIntentWhileUploadingMedia() {
        let presentation = MomentsCreatePrimaryActionPresentation(
            workflow: MomentsCreateWorkflowPresentation(
                activeMomentId: "moment-1",
                isSignedIn: true,
                hasMomentWorkspace: true,
                template: .birthdayMessage,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 2, purchased: 0),
                mediaSummary: MomentsCreateMediaSummary(
                    selectedMedia: [MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001")],
                    isImporting: true,
                    statusMessage: "Uploading media for video creation."
                ),
                storySummary: MomentsCreateStorySummary(),
                finalRenderSummary: MomentsCreateFinalRenderSummary(creditCost: 2),
                canPlanStory: false,
                canPrepareFinalRenderPlan: false,
                canGenerateFinalRender: false
            )
        )

        XCTAssertTrue(presentation.hasFinalVideoIntent)
        XCTAssertFalse(presentation.canRunPrimaryAction)
        XCTAssertEqual(presentation.title, "Continue")
        XCTAssertEqual(presentation.buttonTitle, "Continue")
        XCTAssertEqual(presentation.buttonIconName, "creditcard.fill")
        XCTAssertEqual(presentation.statusMessage, "Uploading media for video creation.")
    }

    func testPrimaryActionPresentationUsesCreateVideoForInternalStoryPreflight() {
        let presentation = MomentsCreatePrimaryActionPresentation(
            workflow: MomentsCreateWorkflowPresentation(
                activeMomentId: "moment-1",
                isSignedIn: true,
                hasMomentWorkspace: true,
                template: .birthdayMessage,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 2, purchased: 0),
                mediaSummary: MomentsCreateMediaSummary(
                    selectedMedia: [MomentsCreateTestFixtures.makeSelectedMedia(id: "00000000-0000-0000-0000-000000000001")]
                ),
                storySummary: MomentsCreateStorySummary(),
                finalRenderSummary: MomentsCreateFinalRenderSummary(creditCost: 2),
                canPlanStory: true,
                canPrepareFinalRenderPlan: false,
                canGenerateFinalRender: false
            )
        )

        XCTAssertTrue(presentation.canRunPrimaryAction)
        XCTAssertEqual(presentation.title, "Continue")
        XCTAssertEqual(presentation.buttonTitle, "Continue")
        XCTAssertEqual(presentation.statusMessage, "You will see the cost before creating the video.")
    }

    func testPrimaryActionPresentationShowsBackendPlanCostBeforeConfirmation() {
        let presentation = MomentsCreatePrimaryActionPresentation(
            workflow: MomentsCreateWorkflowPresentation(
                activeMomentId: "moment-1",
                isSignedIn: true,
                hasMomentWorkspace: true,
                template: .birthdayMessage,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 3, purchased: 0),
                mediaSummary: MomentsCreateMediaSummary(
                    syncedMediaAssets: [MomentsCreateTestFixtures.makeMediaAsset(id: "media-1")]
                ),
                storySummary: MomentsCreateStorySummary(
                    savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")]
                ),
                finalRenderSummary: MomentsCreateFinalRenderSummary(
                    creditCost: 2,
                    renderPlan: MomentsCreateTestFixtures.makeRenderPlan()
                ),
                canPlanStory: false,
                canPrepareFinalRenderPlan: false,
                canGenerateFinalRender: true
            )
        )

        XCTAssertTrue(presentation.canRunPrimaryAction)
        XCTAssertEqual(presentation.title, "Ready to create")
        XCTAssertEqual(presentation.buttonTitle, "Confirm credits · 2 credits")
        XCTAssertEqual(
            presentation.statusMessage,
            "Credits are only charged for completed final videos. This video costs 2 credits."
        )
    }

    func testPrimaryActionPresentationOpensCreditsForBackendInsufficientCreditPlan() {
        let presentation = MomentsCreatePrimaryActionPresentation(
            workflow: MomentsCreateWorkflowPresentation(
                activeMomentId: "moment-1",
                isSignedIn: true,
                hasMomentWorkspace: true,
                template: .birthdayMessage,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 0, purchased: 0),
                mediaSummary: MomentsCreateMediaSummary(
                    syncedMediaAssets: [MomentsCreateTestFixtures.makeMediaAsset(id: "media-1")]
                ),
                storySummary: MomentsCreateStorySummary(
                    savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")]
                ),
                finalRenderSummary: MomentsCreateFinalRenderSummary(
                    creditCost: 2,
                    renderPlan: MomentsCreateTestFixtures.makeRenderPlan(
                        canCreateVideo: false,
                        createVideoBlockers: ["insufficient_credits"]
                    )
                ),
                canPlanStory: false,
                canPrepareFinalRenderPlan: false,
                canGenerateFinalRender: false
            )
        )

        XCTAssertTrue(presentation.canRunPrimaryAction)
        XCTAssertTrue(presentation.needsCreditsForPreparedPlan)
        XCTAssertEqual(presentation.buttonTitle, "Get credits")
        XCTAssertEqual(presentation.buttonIconName, "plus.circle.fill")
        XCTAssertEqual(presentation.statusMessage, "Add 2 more credits before creating the final video.")
    }

    func testPrimaryActionPresentationShowsFinalRenderErrorOverPreparedPlanCopy() {
        let presentation = MomentsCreatePrimaryActionPresentation(
            workflow: MomentsCreateWorkflowPresentation(
                activeMomentId: "moment-1",
                isSignedIn: true,
                hasMomentWorkspace: true,
                template: .birthdayMessage,
                balance: MomentsCreditBalance(proMonthly: 0, promotional: 3, purchased: 0),
                mediaSummary: MomentsCreateMediaSummary(
                    syncedMediaAssets: [MomentsCreateTestFixtures.makeMediaAsset(id: "media-1")]
                ),
                storySummary: MomentsCreateStorySummary(
                    savedScenes: [MomentsCreateTestFixtures.makeScene(id: "scene-1")]
                ),
                finalRenderSummary: MomentsCreateFinalRenderSummary(
                    creditCost: 2,
                    renderPlan: MomentsCreateTestFixtures.makeRenderPlan(),
                    statusMessage: "The video plan changed. Review the latest plan before creating the video."
                ),
                canPlanStory: false,
                canPrepareFinalRenderPlan: false,
                canGenerateFinalRender: true
            )
        )

        XCTAssertTrue(presentation.canRunPrimaryAction)
        XCTAssertEqual(presentation.title, "Ready to create")
        XCTAssertEqual(presentation.buttonTitle, "Confirm credits · 2 credits")
        XCTAssertEqual(
            presentation.statusMessage,
            "The video plan changed. Review the latest plan before creating the video."
        )
    }

    func testRealtimeRenderPresentationFormatsActivePhaseAndProgress() {
        let job = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final",
            status: "running",
            phase: "rendering",
            progressPercent: 42,
            userMessage: "Rendering your video.",
            canEditSetup: false
        )

        let presentation = MomentsRenderRealtimePresentation(renderJob: job)

        XCTAssertEqual(presentation.title, "Rendering")
        XCTAssertEqual(presentation.detail, "Rendering your video.")
        XCTAssertEqual(presentation.progressFraction ?? -1, 0.42, accuracy: 0.001)
        XCTAssertEqual(presentation.systemImage, "gearshape.2.fill")
        XCTAssertTrue(presentation.isActive)
        XCTAssertFalse(presentation.canEditSetup)
    }

    func testRealtimeRenderPresentationFormatsFailedStatus() {
        let job = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final",
            status: "failed",
            canEditSetup: true,
            errorMessage: "fal provider request failed with upstream trace id abc123"
        )

        let presentation = MomentsRenderRealtimePresentation(renderJob: job)

        XCTAssertEqual(presentation.title, "Needs attention")
        XCTAssertEqual(
            presentation.detail,
            "Video creation hit a problem. If the final video was not completed, credits will not be charged. Please try again or contact support."
        )
        XCTAssertEqual(presentation.systemImage, "exclamationmark.triangle.fill")
        XCTAssertFalse(presentation.isActive)
        XCTAssertTrue(presentation.canEditSetup)
    }

    func testRealtimeRenderPresentationUsesSafeFailedUserMessage() {
        let job = MomentsCreateTestFixtures.makeRenderJob(
            id: "final-job",
            kind: "final",
            status: "failed",
            userMessage: "We couldn’t finish this video. No credits were charged.",
            canEditSetup: true,
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
    }

    func testWorkspaceSummaryFormatsProgressDetails() {
        let summary = MomentsCreateWorkspaceSummary(
            mediaCount: 2,
            sceneCount: 1,
            renderJobCount: 1,
            hasFinalExport: false
        )

        XCTAssertEqual(summary.mediaDetail, "2 added")
        XCTAssertEqual(summary.storyDetail, "1 scene")
    }

    func testCreateUITestFixturesExposePreRenderStates() {
        let aviCutWorkspace = MomentsCreateUITestFixtures.workspace(for: .aviCutReady)
        let videoPlanWorkspace = MomentsCreateUITestFixtures.workspace(for: .videoPlanReady)
        let lowCreditsPlan = MomentsCreateUITestFixtures.renderPlan(for: .videoPlanInsufficientCredits)
        let queuedWorkspace = MomentsCreateUITestFixtures.workspace(for: .finalQueued)
        let runningWorkspace = MomentsCreateUITestFixtures.workspace(for: .finalRunning)
        let fullWorkspace = MomentsCreateUITestFixtures.workspace(for: .full)

        XCTAssertEqual(aviCutWorkspace.moment.status, "story_ready")
        XCTAssertEqual(videoPlanWorkspace.moment.status, "story_ready")
        XCTAssertEqual(queuedWorkspace.moment.status, "rendering")
        XCTAssertEqual(runningWorkspace.moment.status, "rendering")
        XCTAssertEqual(fullWorkspace.moment.status, "gallery_ready")
        XCTAssertFalse(aviCutWorkspace.storyScenes.isEmpty)
        XCTAssertFalse(videoPlanWorkspace.storyScenes.isEmpty)
        XCTAssertTrue(aviCutWorkspace.renderJobs.isEmpty)
        XCTAssertTrue(videoPlanWorkspace.renderJobs.isEmpty)
        XCTAssertEqual(queuedWorkspace.latestRenderJob(kind: "final")?.status, "queued")
        XCTAssertEqual(runningWorkspace.latestRenderJob(kind: "final")?.status, "running")
        XCTAssertEqual(MomentsCreateUITestFixtures.balance(for: .videoPlanInsufficientCredits).spendable, 0)
        XCTAssertFalse(lowCreditsPlan.canCreateVideo)
        XCTAssertEqual(lowCreditsPlan.createVideoBlockers, ["insufficient_credits"])
        XCTAssertNil(aviCutWorkspace.latestArtifact(kind: "final_export"))
        XCTAssertNil(videoPlanWorkspace.latestArtifact(kind: "final_export"))
        XCTAssertNil(queuedWorkspace.latestArtifact(kind: "final_export"))
        XCTAssertNil(runningWorkspace.latestArtifact(kind: "final_export"))
        XCTAssertEqual(fullWorkspace.latestArtifact(kind: "final_export")?.id, "final-artifact-1")
        XCTAssertEqual(MomentsCreateUITestFixtures.renderPlan.momentId, MomentsCreateUITestFixtures.momentId)
    }

}
