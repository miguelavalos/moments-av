extension MomentsCreateViewModel {
    var workflowPresentation: MomentsCreateWorkflowPresentation {
        MomentsCreateWorkflowPresentation.make(
            activeMomentId: activeMomentId,
            isSignedIn: isSignedIn,
            hasMomentWorkspace: hasMomentWorkspace,
            hasUnsavedLocalMoment: hasLocalMomentWorkspace,
            template: form.template,
            creationStyleTitle: selectedCreationStyle.title,
            toneTitle: form.tone.title,
            tempoTitle: form.tempo.title,
            occasionTitle: form.title,
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
            activeMomentId: activeMomentId,
            isContinuingMoment: isContinuingMoment,
            canStartAnotherProject: canStartAnotherProject,
            draftErrorMessage: draftErrorMessage,
            workspaceSummary: workspaceSummary
        )
    }
}
