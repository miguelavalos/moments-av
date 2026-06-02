extension MomentsCreateViewModel {
    var setupAvailabilityMessage: String? {
        MomentsCreateAvailabilityMessageFactory.setup(
            isSetupLocked: isSetupLocked,
            isSignedIn: isSignedIn,
            isMomentCreationConfigured: momentCreationWorkflow?.isConfigured ?? false,
            setupFormAvailability: setupFormAvailability
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
            isStoryPlanning: storyPlanWorkflow?.isPlanning ?? false,
            isStoryPlanAvailable: storyPlanWorkflow != nil,
            isStoryPlanConfigured: storyPlanWorkflow?.isConfigured ?? false,
            mediaAssets: effectiveActiveWorkspace?.mediaAssets,
            selectedMediaCount: mediaSelectedCount,
            template: form.template
        )
    }

    var previewAvailabilityMessage: String? {
        MomentsCreateAvailabilityMessageFactory.preview(
            activeMomentId: activeMomentId,
            isPreviewGenerationAvailable: previewGenerationWorkflow != nil,
            isPreviewGenerating: previewGenerationWorkflow?.isGenerating ?? false,
            isPreviewGenerationConfigured: previewGenerationWorkflow?.isConfigured ?? false,
            moment: activeMoment,
            template: form.template
        )
    }

    var previewRefreshAvailabilityMessage: String? {
        previewRefreshAvailability.message
    }

    var finalRenderAvailabilityMessage: String? {
        MomentsCreateAvailabilityMessageFactory.finalRender(
            activeMomentId: activeMomentId,
            isFinalRenderAvailable: finalRenderWorkflow != nil,
            isFinalRenderGenerating: finalRenderWorkflow?.isGenerating ?? false,
            isFinalRenderConfigured: finalRenderWorkflow?.isConfigured ?? false,
            moment: activeMoment,
            template: form.template,
            balance: balance,
            latestPreview: effectiveLatestPreview
        )
    }

    var finalRenderRefreshAvailabilityMessage: String? {
        finalRenderRefreshAvailability.message
    }

    var setupFormAvailability: MomentSetupRules.Availability {
        MomentSetupRules.availability(form: form, balance: balance)
    }

    var previewRefreshAvailability: RenderJobStatusRefreshAvailability {
        MomentsCreateRefreshAvailabilityFactory.preview(
            momentId: activeMomentId,
            job: effectiveLatestPreviewJob,
            isAvailable: previewGenerationWorkflow != nil,
            isConfigured: previewGenerationWorkflow?.isConfigured ?? false,
            isRefreshing: previewGenerationWorkflow?.isRefreshingStatus ?? false
        )
    }

    var finalRenderRefreshAvailability: RenderJobStatusRefreshAvailability {
        MomentsCreateRefreshAvailabilityFactory.finalRender(
            momentId: activeMomentId,
            job: effectiveLatestFinalJob,
            isAvailable: finalRenderWorkflow != nil,
            isConfigured: finalRenderWorkflow?.isConfigured ?? false,
            isRefreshing: finalRenderWorkflow?.isRefreshingStatus ?? false
        )
    }
}
