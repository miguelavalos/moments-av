extension MomentsCreateViewModel {
    var draftAvailabilityMessage: String? {
        if isDraftLocked { return nil }
        if !isSignedIn { return MomentsCreateAvailabilityCopy.draftSignInRequired }
        if !(projectCreationWorkflow?.isConfigured ?? false) { return MomentsCreateAvailabilityCopy.projectSyncNotConfigured }
        return MomentDraftRules.availabilityMessage(draftFormAvailability)
    }

    var mediaAvailabilityMessage: String? {
        if activeProjectId == nil { return MomentsCreateAvailabilityCopy.mediaMissingProject }
        if isImportingMedia { return nil }
        if !(mediaUploadWorkflow?.isConfigured ?? false) { return MomentsCreateAvailabilityCopy.mediaUploadNotConfigured }
        if mediaRemainingSlots == 0 { return MomentsCreateAvailabilityCopy.mediaTemplateFull }
        return nil
    }

    var storyAvailabilityMessage: String? {
        guard activeProjectId != nil else { return MomentsCreateAvailabilityCopy.storyMissingProject }
        guard let storyDraftWorkflow else { return MomentsCreateAvailabilityCopy.storyUnavailable }
        if storyDraftWorkflow.isDrafting { return nil }
        if !storyDraftWorkflow.isConfigured { return MomentsCreateAvailabilityCopy.storyNotConfigured }

        return MomentsStoryDraftRules.availabilityMessage(
            MomentsStoryDraftRules.availability(
                mediaAssets: activeWorkspace?.mediaAssets,
                template: form.template
            ),
            missingMediaMessage: MomentsCreateAvailabilityCopy.storyMissingMedia
        )
    }

    var previewAvailabilityMessage: String? {
        guard activeProjectId != nil else { return MomentsCreateAvailabilityCopy.previewMissingProject }
        guard let previewGenerationWorkflow else { return MomentsCreateAvailabilityCopy.previewUnavailable }
        if previewGenerationWorkflow.isGenerating { return nil }
        if !previewGenerationWorkflow.isConfigured { return MomentsCreateAvailabilityCopy.previewNotConfigured }
        return MomentsPreviewRules.availabilityMessage(
            MomentsPreviewRules.availability(
                project: activeProject,
                template: form.template,
                balance: balance
            ),
            missingProjectMessage: MomentsCreateAvailabilityCopy.previewMissingWorkspace,
            insufficientCreditsMessage: MomentsCreateAvailabilityCopy.previewInsufficientCredits(
                missingCredits: missingCredits
            )
        )
    }

    var previewRefreshAvailabilityMessage: String? {
        previewRefreshAvailability.message
    }

    var finalRenderAvailabilityMessage: String? {
        guard activeProjectId != nil else { return MomentsCreateAvailabilityCopy.finalRenderMissingProject }
        guard let finalRenderWorkflow else { return MomentsCreateAvailabilityCopy.finalRenderUnavailable }
        if finalRenderWorkflow.isGenerating { return nil }
        if !finalRenderWorkflow.isConfigured { return MomentsCreateAvailabilityCopy.finalRenderNotConfigured }
        return MomentsFinalRenderRules.availabilityMessage(
            MomentsFinalRenderRules.availability(
                project: activeProject,
                template: form.template,
                balance: balance,
                latestPreview: latestPreview
            ),
            missingProjectMessage: MomentsCreateAvailabilityCopy.finalRenderMissingWorkspace,
            insufficientCreditsMessage: MomentsCreateAvailabilityCopy.finalRenderInsufficientCredits(
                missingCredits: missingCredits
            )
        )
    }

    var finalRenderRefreshAvailabilityMessage: String? {
        finalRenderRefreshAvailability.message
    }

    private var missingCredits: Int {
        max(form.template.creditCost - balance.spendable, 0)
    }

    var draftFormAvailability: MomentDraftRules.Availability {
        MomentDraftRules.availability(form: form, balance: balance)
    }

    var previewRefreshAvailability: RenderJobStatusRefreshAvailability {
        MomentsCreateRefreshAvailabilityFactory.preview(
            projectId: activeProjectId,
            job: latestPreviewJob,
            isAvailable: previewGenerationWorkflow != nil,
            isConfigured: previewGenerationWorkflow?.isConfigured ?? false,
            isRefreshing: previewGenerationWorkflow?.isRefreshingStatus ?? false
        )
    }

    var finalRenderRefreshAvailability: RenderJobStatusRefreshAvailability {
        MomentsCreateRefreshAvailabilityFactory.finalRender(
            projectId: activeProjectId,
            job: latestFinalJob,
            isAvailable: finalRenderWorkflow != nil,
            isConfigured: finalRenderWorkflow?.isConfigured ?? false,
            isRefreshing: finalRenderWorkflow?.isRefreshingStatus ?? false
        )
    }
}
