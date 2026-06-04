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
            importProgress: mediaImportProgress,
            statusMessage: mediaStatusMessage
        )
    }

    var storySummary: MomentsCreateStorySummary {
        MomentsCreateStorySummary(
            savedScenes: effectiveSavedScenes,
            generatedScenes: generatedScenes,
            isPlanning: isPlanningStory,
            statusMessage: storyStatusMessage
        )
    }

    var previewSummary: MomentsCreatePreviewSummary {
        MomentsCreatePreviewSummary(
            activeMoment: activeMoment,
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
            renderPlan: currentRenderPlan,
            finalExport: effectiveFinalExport,
            pendingGalleryVideo: pendingGalleryVideo,
            canRetryFinalVideoDownload: canRetryFinalVideoDownload,
            latestFinalJob: effectiveLatestFinalJob,
            isGenerating: isGeneratingFinalRender,
            isRefreshingStatus: isRefreshingFinalRenderStatus,
            statusMessage: effectiveLatestFinalJob?.userMessage ?? finalRenderStatusMessage
        )
    }

    var mediaSelectedCount: Int {
        mediaSummary.selectedCount
    }

    var mediaRemainingSlots: Int {
        mediaSummary.remainingSlots(template: form.template)
    }
}
