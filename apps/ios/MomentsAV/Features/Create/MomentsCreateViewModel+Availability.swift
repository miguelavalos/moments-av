extension MomentsCreateViewModel {
    func canAfford(_ template: MomentTemplate) -> Bool {
        projectCreationWorkflow?.canAfford(template) ?? false
    }

    var canCreateDraft: Bool {
        !isDraftLocked
            && isSignedIn
            && (projectCreationWorkflow?.isConfigured ?? false)
            && draftFormAvailability.canCreateDraft
    }

    var isDraftLocked: Bool {
        activeProjectId != nil
    }

    var isBusy: Bool {
        isCreatingDraft
            || isImportingMedia
            || isDraftingStory
            || isGeneratingPreview
            || isRefreshingPreviewStatus
            || isGeneratingFinalRender
            || isRefreshingFinalRenderStatus
    }

    var canStartAnotherProject: Bool {
        activeProjectId != nil && !isBusy
    }

    var canAddMedia: Bool {
        activeProjectId != nil
            && !isImportingMedia
            && (mediaUploadWorkflow?.isConfigured ?? false)
            && mediaRemainingSlots > 0
    }

    var canDraftStory: Bool {
        guard let storyDraftWorkflow, activeProjectId != nil else { return false }
        return storyDraftWorkflow.canDraft(template: form.template)
    }

    var canGeneratePreview: Bool {
        guard let previewGenerationWorkflow, activeProjectId != nil else { return false }
        return previewGenerationWorkflow.canGenerate(template: form.template)
    }

    var canRefreshPreviewStatus: Bool {
        previewRefreshAvailability.canRefresh
    }

    var canGenerateFinalRender: Bool {
        guard let finalRenderWorkflow, activeProjectId != nil else { return false }
        return finalRenderWorkflow.canGenerate(
            template: form.template,
            latestPreview: latestPreview
        )
    }

    var canRefreshFinalRenderStatus: Bool {
        finalRenderRefreshAvailability.canRefresh
    }

    var workspaceSummary: MomentsCreateWorkspaceSummary {
        MomentsCreateWorkspaceSummary.make(
            workspace: activeWorkspace,
            latestPreview: latestPreview,
            finalExport: finalExport
        )
    }

    var mediaSummary: MomentsCreateMediaSummary {
        MomentsCreateMediaSummary(
            selectedMedia: selectedMedia,
            syncedMediaAssets: activeWorkspace?.mediaAssets ?? [],
            isImporting: isImportingMedia,
            statusMessage: mediaStatusMessage
        )
    }

    var storySummary: MomentsCreateStorySummary {
        MomentsCreateStorySummary(
            savedScenes: savedScenes,
            generatedScenes: generatedScenes,
            isDrafting: isDraftingStory,
            statusMessage: storyStatusMessage
        )
    }

    var previewSummary: MomentsCreatePreviewSummary {
        MomentsCreatePreviewSummary(
            activeProject: activeProject,
            latestPreview: latestPreview,
            latestPreviewJob: latestPreviewJob,
            isGenerating: isGeneratingPreview,
            isRefreshingStatus: isRefreshingPreviewStatus,
            statusMessage: previewStatusMessage
        )
    }

    var finalRenderSummary: MomentsCreateFinalRenderSummary {
        MomentsCreateFinalRenderSummary(
            creditCost: form.template.creditCost,
            finalExport: finalExport,
            latestFinalJob: latestFinalJob,
            isGenerating: isGeneratingFinalRender,
            isRefreshingStatus: isRefreshingFinalRenderStatus,
            statusMessage: finalRenderStatusMessage
        )
    }

    var workflowPresentation: MomentsCreateWorkflowPresentation {
        MomentsCreateWorkflowPresentation.make(
            activeProjectId: activeProjectId,
            template: form.template,
            mediaSummary: mediaSummary,
            storySummary: storySummary,
            previewSummary: previewSummary,
            finalRenderSummary: finalRenderSummary,
            availability: workflowAvailability
        )
    }

    var workflowAvailability: MomentsCreateWorkflowAvailability {
        MomentsCreateWorkflowAvailability.make(
            canAddMedia: canAddMedia,
            canDraftStory: canDraftStory,
            canGeneratePreview: canGeneratePreview,
            canRefreshPreviewStatus: canRefreshPreviewStatus,
            canGenerateFinalRender: canGenerateFinalRender,
            canRefreshFinalRenderStatus: canRefreshFinalRenderStatus,
            mediaMessage: mediaAvailabilityMessage,
            storyMessage: storyAvailabilityMessage,
            previewMessage: previewAvailabilityMessage,
            previewRefreshMessage: previewRefreshAvailabilityMessage,
            finalRenderMessage: finalRenderAvailabilityMessage,
            finalRenderRefreshMessage: finalRenderRefreshAvailabilityMessage
        )
    }

    var draftSetupPresentation: MomentsCreateDraftSetupPresentation {
        MomentsCreateDraftSetupPresentation.make(
            template: form.template,
            canAfford: canAfford(form.template),
            spendPlanDescription: spendPlanDescription(for: form.template),
            isDraftLocked: isDraftLocked,
            isCreatingDraft: isCreatingDraft,
            canCreateDraft: canCreateDraft,
            availabilityMessage: draftAvailabilityMessage,
            activeProjectId: activeProjectId,
            isContinuingProject: isContinuingProject,
            canStartAnotherProject: canStartAnotherProject,
            draftErrorMessage: draftErrorMessage,
            workspaceSummary: workspaceSummary
        )
    }

    func spendPlanDescription(for template: MomentTemplate) -> String {
        MomentsCreateFormatting.spendPlanDescription(
            projectCreationWorkflow?.spendPlan(for: template)
        )
    }

    var mediaSelectedCount: Int {
        mediaSummary.selectedCount
    }

    var mediaRemainingSlots: Int {
        mediaSummary.remainingSlots(template: form.template)
    }
}
