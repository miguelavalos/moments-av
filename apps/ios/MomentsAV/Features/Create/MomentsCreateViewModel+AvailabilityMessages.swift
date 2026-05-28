extension MomentsCreateViewModel {
    var draftAvailabilityMessage: String? {
        MomentsCreateAvailabilityMessageFactory.draft(
            isDraftLocked: isDraftLocked,
            isSignedIn: isSignedIn,
            isProjectCreationConfigured: projectCreationWorkflow?.isConfigured ?? false,
            draftFormAvailability: draftFormAvailability
        )
    }

    var mediaAvailabilityMessage: String? {
        MomentsCreateAvailabilityMessageFactory.media(
            hasMomentWorkspace: hasMomentWorkspace,
            isImportingMedia: isImportingMedia,
            isMediaUploadConfigured: mediaUploadWorkflow?.isConfigured ?? false,
            mediaRemainingSlots: mediaRemainingSlots
        )
    }

    var storyAvailabilityMessage: String? {
        MomentsCreateAvailabilityMessageFactory.story(
            isSignedIn: isSignedIn,
            hasMomentWorkspace: hasMomentWorkspace,
            isStoryDrafting: storyDraftWorkflow?.isDrafting ?? false,
            isStoryDraftAvailable: storyDraftWorkflow != nil,
            isStoryDraftConfigured: storyDraftWorkflow?.isConfigured ?? false,
            mediaAssets: effectiveActiveWorkspace?.mediaAssets,
            selectedMediaCount: mediaSelectedCount,
            template: form.template
        )
    }

    var previewAvailabilityMessage: String? {
        MomentsCreateAvailabilityMessageFactory.preview(
            activeProjectId: activeProjectId,
            isPreviewGenerationAvailable: previewGenerationWorkflow != nil,
            isPreviewGenerating: previewGenerationWorkflow?.isGenerating ?? false,
            isPreviewGenerationConfigured: previewGenerationWorkflow?.isConfigured ?? false,
            project: activeProject,
            template: form.template,
            balance: balance
        )
    }

    var previewRefreshAvailabilityMessage: String? {
        previewRefreshAvailability.message
    }

    var finalRenderAvailabilityMessage: String? {
        MomentsCreateAvailabilityMessageFactory.finalRender(
            activeProjectId: activeProjectId,
            isFinalRenderAvailable: finalRenderWorkflow != nil,
            isFinalRenderGenerating: finalRenderWorkflow?.isGenerating ?? false,
            isFinalRenderConfigured: finalRenderWorkflow?.isConfigured ?? false,
            project: activeProject,
            template: form.template,
            balance: balance,
            latestPreview: effectiveLatestPreview
        )
    }

    var finalRenderRefreshAvailabilityMessage: String? {
        finalRenderRefreshAvailability.message
    }

    var draftFormAvailability: MomentDraftRules.Availability {
        MomentDraftRules.availability(form: form, balance: balance)
    }

    var previewRefreshAvailability: RenderJobStatusRefreshAvailability {
        MomentsCreateRefreshAvailabilityFactory.preview(
            projectId: activeProjectId,
            job: effectiveLatestPreviewJob,
            isAvailable: previewGenerationWorkflow != nil,
            isConfigured: previewGenerationWorkflow?.isConfigured ?? false,
            isRefreshing: previewGenerationWorkflow?.isRefreshingStatus ?? false
        )
    }

    var finalRenderRefreshAvailability: RenderJobStatusRefreshAvailability {
        MomentsCreateRefreshAvailabilityFactory.finalRender(
            projectId: activeProjectId,
            job: effectiveLatestFinalJob,
            isAvailable: finalRenderWorkflow != nil,
            isConfigured: finalRenderWorkflow?.isConfigured ?? false,
            isRefreshing: finalRenderWorkflow?.isRefreshingStatus ?? false
        )
    }
}
