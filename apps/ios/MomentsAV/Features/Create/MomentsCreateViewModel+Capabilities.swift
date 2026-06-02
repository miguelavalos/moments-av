extension MomentsCreateViewModel {
    func canAfford(_ template: MomentTemplate) -> Bool {
        if MomentsUITestEnvironment.current.createFixture == "full" {
            return MomentsCreditGate.canAfford(template, balance: balance)
        }

        return momentCreationWorkflow?.canAfford(template) ?? false
    }

    var canCreateDraft: Bool {
        !isDraftLocked
            && isSignedIn
            && (momentCreationWorkflow?.isConfigured ?? false)
            && draftFormAvailability.canCreateDraft
    }

    var canBeginNewProject: Bool {
        !isDraftLocked && !isBusy
    }

    var isDraftLocked: Bool {
        activeMomentId != nil
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
        activeMomentId != nil && !isBusy
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
            activeMomentId: activeMomentId,
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
        guard let activeMomentId else { return false }
        let preparedSignature = lastPreparedStoryInputSignature ?? effectiveActiveWorkspace?.moment.storyInputSignature
        guard let preparedSignature else {
            return true
        }
        return currentStoryInputSignature(momentId: activeMomentId) == preparedSignature
    }

    func spendPlanDescription(for template: MomentTemplate) -> String {
        if MomentsUITestEnvironment.current.createFixture == "full" {
            return MomentsCreateFormatting.spendPlanDescription(
                MomentsCreditGate.spendPlan(for: template.creditCost, balance: balance)
            )
        }

        return MomentsCreateFormatting.spendPlanDescription(
            momentCreationWorkflow?.spendPlan(for: template)
        )
    }
}
