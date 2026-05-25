extension MomentsCreateViewModel {
    var workspaceSummary: MomentsCreateWorkspaceSummary {
        MomentsCreateWorkspaceSummary.make(
            workspace: effectiveActiveWorkspace,
            latestPreview: effectiveLatestPreview,
            finalExport: effectiveFinalExport
        )
    }

    var mediaSummary: MomentsCreateMediaSummary {
        MomentsCreateMediaSummary(
            selectedMedia: effectiveSelectedMedia,
            syncedMediaAssets: effectiveActiveWorkspace?.mediaAssets ?? [],
            isImporting: isImportingMedia,
            statusMessage: mediaStatusMessage
        )
    }

    var storySummary: MomentsCreateStorySummary {
        MomentsCreateStorySummary(
            savedScenes: effectiveSavedScenes,
            generatedScenes: generatedScenes,
            isDrafting: isDraftingStory,
            statusMessage: storyStatusMessage
        )
    }

    var previewSummary: MomentsCreatePreviewSummary {
        MomentsCreatePreviewSummary(
            activeProject: activeProject,
            latestPreview: effectiveLatestPreview,
            latestPreviewJob: effectiveLatestPreviewJob,
            isGenerating: isGeneratingPreview,
            isRefreshingStatus: isRefreshingPreviewStatus,
            statusMessage: previewStatusMessage
        )
    }

    var finalRenderSummary: MomentsCreateFinalRenderSummary {
        MomentsCreateFinalRenderSummary(
            creditCost: form.template.creditCost,
            finalExport: effectiveFinalExport,
            latestFinalJob: effectiveLatestFinalJob,
            isGenerating: isGeneratingFinalRender,
            isRefreshingStatus: isRefreshingFinalRenderStatus,
            statusMessage: finalRenderStatusMessage
        )
    }

    var mediaSelectedCount: Int {
        mediaSummary.selectedCount
    }

    var mediaRemainingSlots: Int {
        mediaSummary.remainingSlots(template: form.template)
    }
}
