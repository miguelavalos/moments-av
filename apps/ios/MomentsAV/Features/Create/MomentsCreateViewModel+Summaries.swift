extension MomentsCreateViewModel {
    var workspaceSummary: MomentsCreateWorkspaceSummary {
        MomentsCreateWorkspaceSummary.make(
            workspace: activeWorkspace,
            latestPreview: latestPreview,
            finalExport: finalExport
        )
    }

    var mediaSummary: MomentsCreateMediaSummary {
        MomentsCreateMediaSummary(
            selectedMedia: selectedMedia,
            syncedMediaAssets: activeWorkspace?.mediaAssets ?? [],
            isImporting: isImportingMedia,
            statusMessage: mediaStatusMessage
        )
    }

    var storySummary: MomentsCreateStorySummary {
        MomentsCreateStorySummary(
            savedScenes: savedScenes,
            generatedScenes: generatedScenes,
            isDrafting: isDraftingStory,
            statusMessage: storyStatusMessage
        )
    }

    var previewSummary: MomentsCreatePreviewSummary {
        MomentsCreatePreviewSummary(
            activeProject: activeProject,
            latestPreview: latestPreview,
            latestPreviewJob: latestPreviewJob,
            isGenerating: isGeneratingPreview,
            isRefreshingStatus: isRefreshingPreviewStatus,
            statusMessage: previewStatusMessage
        )
    }

    var finalRenderSummary: MomentsCreateFinalRenderSummary {
        MomentsCreateFinalRenderSummary(
            creditCost: form.template.creditCost,
            finalExport: finalExport,
            latestFinalJob: latestFinalJob,
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
