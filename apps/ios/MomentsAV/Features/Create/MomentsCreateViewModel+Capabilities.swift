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
        !isFinalRenderEditingLocked && workflowCapability.canAddMedia
    }

    var canDraftStory: Bool {
        !isFinalRenderEditingLocked && workflowCapability.canDraftStory
    }

    var canGeneratePreview: Bool {
        !isFinalRenderEditingLocked
            && workflowCapability.canGeneratePreview
            && isStoryPreparedForCurrentInput
    }

    var canRefreshPreviewStatus: Bool {
        workflowCapability.canRefreshPreviewStatus
    }

    var canGenerateFinalRender: Bool {
        !isFinalRenderEditingLocked
            && workflowCapability.canGenerateFinalRender
            && isStoryPreparedForCurrentInput
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

    var isFinalRenderEditingLocked: Bool {
        guard let latestFinalJob = effectiveLatestFinalJob,
              latestFinalJob.isActiveRender else {
            return false
        }
        return latestFinalJob.canEditDraft != true
    }

    var isStoryPreparedForCurrentInput: Bool {
        if usesFullUITestFixture {
            return true
        }
        guard storySummary.hasScenes else { return false }
        guard let activeProjectId else { return false }
        let preparedSignature = lastPreparedStoryInputSignature ?? effectiveActiveWorkspace?.project.storyInputSignature
        guard let preparedSignature else {
            return true
        }
        return currentStoryInputSignature(projectId: activeProjectId) == preparedSignature
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
