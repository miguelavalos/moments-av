extension MomentsCreateViewModel {
    func canAfford(_ template: MomentTemplate) -> Bool {
        if MomentsUITestEnvironment.current.createFixture == "full" {
            return MomentsCreditGate.canAfford(template, balance: balance)
        }

        return projectCreationWorkflow?.canAfford(template) ?? false
    }

    var canCreateDraft: Bool {
        !isDraftLocked
            && isSignedIn
            && (projectCreationWorkflow?.isConfigured ?? false)
            && draftFormAvailability.canCreateDraft
    }

    var canBeginNewProject: Bool {
        !isDraftLocked
            && isSignedIn
            && canAfford(selectedCreationStyle.template)
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
        workflowCapability.canAddMedia
    }

    var canDraftStory: Bool {
        workflowCapability.canDraftStory
    }

    var canGeneratePreview: Bool {
        workflowCapability.canGeneratePreview
    }

    var canRefreshPreviewStatus: Bool {
        workflowCapability.canRefreshPreviewStatus
    }

    var canGenerateFinalRender: Bool {
        workflowCapability.canGenerateFinalRender
    }

    var canRefreshFinalRenderStatus: Bool {
        workflowCapability.canRefreshFinalRenderStatus
    }

    var workflowCapability: MomentsCreateWorkflowCapability {
        MomentsCreateWorkflowCapabilityFactory.make(
            activeProjectId: activeProjectId,
            isSignedIn: isSignedIn,
            hasMomentWorkspace: hasMomentWorkspace,
            isImportingMedia: isImportingMedia,
            isMediaUploadConfigured: mediaUploadWorkflow?.isConfigured ?? false,
            mediaRemainingSlots: mediaRemainingSlots,
            storyDraftWorkflow: storyDraftWorkflow,
            previewGenerationWorkflow: previewGenerationWorkflow,
            finalRenderWorkflow: finalRenderWorkflow,
            template: form.template,
            previewRefreshAvailability: previewRefreshAvailability,
            finalRenderRefreshAvailability: finalRenderRefreshAvailability,
            latestPreview: effectiveLatestPreview,
            selectedMediaCount: mediaSelectedCount
        )
    }

    func spendPlanDescription(for template: MomentTemplate) -> String {
        if MomentsUITestEnvironment.current.createFixture == "full" {
            return MomentsCreateFormatting.spendPlanDescription(
                MomentsCreditGate.spendPlan(for: template.creditCost, balance: balance)
            )
        }

        return MomentsCreateFormatting.spendPlanDescription(
            projectCreationWorkflow?.spendPlan(for: template)
        )
    }
}
