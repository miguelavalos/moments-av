extension MomentsCreateViewModel {
    func canAfford(_ template: MomentTemplate) -> Bool {
        if MomentsUITestEnvironment.current.createFixture == "full" {
            return MomentsCreditGate.canAfford(template, balance: balance)
        }

        return momentCreationWorkflow?.canAfford(template) ?? false
    }

    var canCreateMoment: Bool {
        !isSetupLocked
            && isSignedIn
            && (momentCreationWorkflow?.isConfigured ?? false)
            && setupFormAvailability.canCreateMoment
    }

    var canBeginNewMoment: Bool {
        !isSetupLocked && !isBusy
    }

    var isSetupLocked: Bool {
        activeMomentId != nil
    }

    var isBusy: Bool {
        isCreatingMoment
            || isImportingMedia
            || isPlanningStory
            || isGeneratingPreview
            || isRefreshingPreviewStatus
            || isGeneratingFinalRender
            || isRefreshingFinalRenderStatus
    }

    var canStartAnotherMoment: Bool {
        activeMomentId != nil && !isBusy
    }

    var canAddMedia: Bool {
        !isFinalRenderEditingLocked && workflowCapability.canAddMedia
    }

    var canPlanStory: Bool {
        !isFinalRenderEditingLocked && workflowCapability.canPlanStory
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
            storyPlanWorkflow: storyPlanWorkflow,
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
        return latestFinalJob.canEditSetup != true
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
        return currentStoryPlanInputSignature(momentId: activeMomentId) == preparedSignature
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
