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
            availability: workflowAvailability
        )
    }

    var workflowAvailability: MomentsCreateWorkflowAvailability {
        MomentsCreateWorkflowAvailability.make(
            canAddMedia: canAddMedia,
            canPlanStory: canPlanStory,
            canGeneratePreview: canGeneratePreview,
            canRefreshPreviewStatus: canRefreshPreviewStatus,
            canPrepareFinalRenderPlan: canPrepareFinalRenderPlan,
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

}
