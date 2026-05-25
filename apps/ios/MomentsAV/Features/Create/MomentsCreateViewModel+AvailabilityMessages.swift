extension MomentsCreateViewModel {
    var draftAvailabilityMessage: String? {
        if isDraftLocked { return nil }
        if !isSignedIn { return "Sign in before creating a draft." }
        if !(projectCreationWorkflow?.isConfigured ?? false) { return "Project sync is not configured for this build." }
        return MomentDraftRules.availabilityMessage(draftFormAvailability)
    }

    var mediaAvailabilityMessage: String? {
        if activeProjectId == nil { return "Create or continue a draft before adding media." }
        if isImportingMedia { return nil }
        if !(mediaUploadWorkflow?.isConfigured ?? false) { return "Media upload is not configured for this build." }
        if mediaRemainingSlots == 0 { return "Remove media before adding more to this template." }
        return nil
    }

    var storyAvailabilityMessage: String? {
        guard activeProjectId != nil else { return "Create or continue a draft before generating a story." }
        guard let storyDraftWorkflow else { return "Story drafting is not available yet." }
        if storyDraftWorkflow.isDrafting { return nil }
        if !storyDraftWorkflow.isConfigured { return "Story drafting is not configured for this build." }

        return MomentsStoryDraftRules.availabilityMessage(
            MomentsStoryDraftRules.availability(
                mediaAssets: activeWorkspace?.mediaAssets,
                template: form.template
            ),
            missingMediaMessage: "Wait for synced media before drafting."
        )
    }

    var previewAvailabilityMessage: String? {
        guard activeProjectId != nil else { return "Create or continue a draft before generating a preview." }
        guard let previewGenerationWorkflow else { return "Preview generation is not available yet." }
        if previewGenerationWorkflow.isGenerating { return nil }
        if !previewGenerationWorkflow.isConfigured { return "Preview generation is not configured for this build." }
        return MomentsPreviewRules.availabilityMessage(
            MomentsPreviewRules.availability(
                project: activeProject,
                template: form.template,
                balance: balance
            ),
            missingProjectMessage: "Wait for the project workspace to sync before generating a preview.",
            insufficientCreditsMessage: MomentsCreateAvailabilityCopy.previewInsufficientCredits(
                missingCredits: missingCredits
            )
        )
    }

    var previewRefreshAvailabilityMessage: String? {
        previewRefreshAvailability.message
    }

    var finalRenderAvailabilityMessage: String? {
        guard activeProjectId != nil else { return "Create or continue a draft before rendering the final export." }
        guard let finalRenderWorkflow else { return "Final rendering is not available yet." }
        if finalRenderWorkflow.isGenerating { return nil }
        if !finalRenderWorkflow.isConfigured { return "Final rendering is not configured for this build." }
        return MomentsFinalRenderRules.availabilityMessage(
            MomentsFinalRenderRules.availability(
                project: activeProject,
                template: form.template,
                balance: balance,
                latestPreview: latestPreview
            ),
            missingProjectMessage: "Wait for the project workspace to sync before rendering the final export.",
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
        RenderJobStatusRefreshAvailability(
            projectId: activeProjectId,
            job: latestPreviewJob,
            isAvailable: previewGenerationWorkflow != nil,
            isConfigured: previewGenerationWorkflow?.isConfigured ?? false,
            isRefreshing: previewGenerationWorkflow?.isRefreshingStatus ?? false,
            unavailableMessage: "Preview status refresh is not available yet.",
            notConfiguredMessage: "Preview status refresh is not configured for this build.",
            missingProjectMessage: "Open a project before refreshing preview status.",
            missingJobMessage: "No preview render job is available yet.",
            missingProviderRequestMessage: "Preview status is missing its provider request id."
        )
    }

    var finalRenderRefreshAvailability: RenderJobStatusRefreshAvailability {
        RenderJobStatusRefreshAvailability(
            projectId: activeProjectId,
            job: latestFinalJob,
            isAvailable: finalRenderWorkflow != nil,
            isConfigured: finalRenderWorkflow?.isConfigured ?? false,
            isRefreshing: finalRenderWorkflow?.isRefreshingStatus ?? false,
            unavailableMessage: "Final status refresh is not available yet.",
            notConfiguredMessage: "Final status refresh is not configured for this build.",
            missingProjectMessage: "Open a project before refreshing final status.",
            missingJobMessage: "No final render job is available yet.",
            missingProviderRequestMessage: "Final render status is missing its provider request id."
        )
    }
}
