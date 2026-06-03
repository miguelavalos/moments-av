extension MomentsCreateViewModel {
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

    var canPrepareFinalRenderPlan: Bool {
        !isFinalRenderEditingLocked
            && workflowCapability.canPrepareFinalRenderPlan
            && isStoryPreparedForCurrentInput
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
        if let fixtureMode = activeUITestFixtureMode {
            return MomentsCreateWorkflowCapability(
                canAddMedia: false,
                canPlanStory: false,
                canGeneratePreview: false,
                canRefreshPreviewStatus: false,
                canPrepareFinalRenderPlan: fixtureMode != .full
                    && !isBusy,
                canGenerateFinalRender: fixtureMode != .full
                    && !isBusy
                    && MomentsCreditGate.canAfford(form.template, balance: balance),
                canRefreshFinalRenderStatus: false
            )
        }

        return MomentsCreateWorkflowCapabilityFactory.make(
            activeMomentId: activeMomentId,
            isSignedIn: isSignedIn,
            hasMomentWorkspace: hasMomentWorkspace,
            isImportingMedia: isImportingMedia,
            mediaRemainingSlots: mediaRemainingSlots,
            storyPlanWorkflow: storyPlanWorkflow,
            previewGenerationWorkflow: previewGenerationWorkflow,
            finalRenderWorkflow: finalRenderWorkflow,
            creditBalanceLoadState: creditBalanceLoadState,
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
        if usesCreateUITestFixture {
            return true
        }
        guard storySummary.hasScenes else { return false }
        guard let activeMomentId else { return false }
        let preparedSignature = lastPreparedStoryInputSignature ?? effectiveActiveWorkspace?.moment.storyInputSignature
        guard let preparedSignature else {
            return true
        }
        return preparedStoryComparisonInputSignature(momentId: activeMomentId) == preparedSignature
    }
}
