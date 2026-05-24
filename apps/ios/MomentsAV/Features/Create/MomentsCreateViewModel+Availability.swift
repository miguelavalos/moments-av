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
        createdProjectId != nil
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
        createdProjectId != nil && !isBusy
    }

    var canAddMedia: Bool {
        createdProjectId != nil
            && !isImportingMedia
            && (mediaUploadWorkflow?.isConfigured ?? false)
            && mediaRemainingSlots > 0
    }

    var canDraftStory: Bool {
        guard let storyDraftWorkflow, createdProjectId != nil else { return false }
        return storyDraftWorkflow.canDraft(template: form.template)
    }

    var canGeneratePreview: Bool {
        guard let previewGenerationWorkflow, createdProjectId != nil else { return false }
        return previewGenerationWorkflow.canGenerate(template: form.template)
    }

    var canRefreshPreviewStatus: Bool {
        previewRefreshAvailability.canRefresh
    }

    var canGenerateFinalRender: Bool {
        guard let finalRenderWorkflow, createdProjectId != nil else { return false }
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
