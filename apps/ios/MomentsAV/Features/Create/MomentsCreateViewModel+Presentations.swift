extension MomentsCreateViewModel {
    var workflowPresentation: MomentsCreateWorkflowPresentation {
        MomentsCreateWorkflowPresentation.make(
            activeProjectId: activeProjectId,
            isSignedIn: isSignedIn,
            hasMomentWorkspace: hasMomentWorkspace,
            template: form.template,
            balance: balance,
            mediaSummary: mediaSummary,
            storySummary: storySummary,
            previewSummary: previewSummary,
            finalRenderSummary: finalRenderSummary,
            isBuyingReviewBundle: isBuyingReviewBundle,
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
}
