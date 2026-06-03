import Foundation
import PhotosUI
import SwiftUI

extension MomentsCreateViewModel {
    @discardableResult
    func beginNewMoment(openMediaPicker: Bool = false, openAlbumPicker: Bool = false) -> Bool {
        guard canBeginNewMoment else {
            updateSetupErrorMessage(setupAvailabilityMessage ?? L10n.string("create.error.startWhenReady"))
            return false
        }
        prepareNewMomentCreation()
        isLocalMomentStarted = true
        pendingFocus = .media
        if openMediaPicker {
            mediaPickerOpenRequest += 1
        } else if openAlbumPicker {
            albumPickerOpenRequest += 1
        }
        return true
    }

    func discardMoment() {
        guard !isBusy else {
            updateSetupErrorMessage(L10n.string("create.error.waitBeforeDiscard"))
            return
        }
        guard effectiveLatestFinalJob?.isActiveRender != true else {
            updateSetupErrorMessage(L10n.string("create.error.waitBeforeDiscard"))
            return
        }
        guard hasMomentWorkspace || hasRecoverableMomentContext else {
            updateSetupErrorMessage(L10n.string("create.error.noActiveMoment"))
            return
        }
        if hasLocalMomentWorkspace {
            resetActiveMoment(force: true)
            return
        }
        guard let momentCreationWorkflow else {
            resetActiveMoment(force: true)
            return
        }

        runOperation {
            let discarded = await momentCreationWorkflow.discardActiveMoment(momentId: self.activeMomentId)
            if discarded {
                self.resetActiveMoment(force: true)
            } else if let message = momentCreationWorkflow.errorMessage {
                self.updateSetupErrorMessage(message)
            } else {
                self.updateSetupErrorMessage(L10n.string("create.error.discardMoment"))
            }
        }
    }

    func importPickerItems(_ items: [PhotosPickerItem]) {
        guard canAddMedia, let mediaUploadWorkflow else {
            updateSetupErrorMessage(mediaAvailabilityMessage ?? L10n.string("create.error.mediaUnavailable"))
            return
        }
        let template = form.template
        markPreparedStoryMediaEdited()

        runOperation {
            await mediaUploadWorkflow.importPickerItems(
                items,
                template: template,
                momentId: self.activeMomentId
            )
        }
    }

    func importLatestPhotos() {
        guard canAddMedia, let mediaUploadWorkflow else {
            updateSetupErrorMessage(mediaAvailabilityMessage ?? L10n.string("create.error.mediaUnavailable"))
            return
        }
        let template = form.template
        markPreparedStoryMediaEdited()

        runOperation {
            await mediaUploadWorkflow.importLatestPhotos(
                template: template,
                momentId: self.activeMomentId
            )
        }
    }

    func importPhotoAlbum(id albumId: String) {
        guard canAddMedia, let mediaUploadWorkflow else {
            updateSetupErrorMessage(mediaAvailabilityMessage ?? L10n.string("create.error.mediaUnavailable"))
            return
        }
        let template = form.template
        markPreparedStoryMediaEdited()

        runOperation {
            await mediaUploadWorkflow.importPhotoAlbum(
                id: albumId,
                template: template,
                momentId: self.activeMomentId
            )
        }
    }

    func removeMedia(_ media: MomentsSelectedMedia) {
        markPreparedStoryMediaEdited()
        mediaUploadWorkflow?.remove(media)
    }

    func moveMedia(_ media: MomentsSelectedMedia, before target: MomentsSelectedMedia) {
        markPreparedStoryMediaEdited()
        mediaUploadWorkflow?.move(media, before: target)
    }

    func reorderMedia(_ media: [MomentsSelectedMedia]) {
        markPreparedStoryMediaEdited()
        mediaUploadWorkflow?.reorder(media)
    }

    func autoPickStrongMoments() {
        markPreparedStoryMediaEdited()
        mediaUploadWorkflow?.autoPickStrongMoments()
    }

    func restoreLocalMediaForEditing() {
        mediaUploadWorkflow?.restoreLocalMediaForEditing()
    }

    func generateStoryPlan() {
        guard canPlanStory, let storyPlanWorkflow else {
            updateStoryStatusMessage(storyAvailabilityMessage ?? L10n.string("create.error.storyPreparationNotReady"))
            return
        }
        let form = form
        let selectedMedia = selectedMedia
        isPreparingStory = true

        runOperation {
            defer { self.isPreparingStory = false }
            let momentId: String?
            if let activeMomentId = self.activeMomentId {
                momentId = activeMomentId
            } else if let momentCreationWorkflow = self.momentCreationWorkflow {
                momentId = await momentCreationWorkflow.createMoment(form: form)
                if momentId != nil {
                    self.isLocalMomentStarted = false
                }
            } else {
                momentId = nil
            }

            guard let momentId else {
                self.updateStoryStatusMessage(self.momentCreationFailureMessage())
                return
            }
            if self.storySummary.hasScenes,
               self.lastPreparedStoryInputSignature == self.preparedStoryComparisonInputSignature(momentId: momentId) {
                self.updateStoryStatusMessage(L10n.string("create.story.status.alreadyReady"))
                return
            }

            let persistedMedia = await self.mediaUploadWorkflow?.persistSelectedMedia(momentId: momentId)
            guard persistedMedia != nil || selectedMedia.isEmpty else {
                self.updateStoryStatusMessage(self.mediaStatusMessage
                    ?? MomentsRecoveryCopy.mediaStorySaveFailure()
                )
                return
            }
            let inputSignature = self.currentStoryPlanInputSignature(
                momentId: momentId,
                persistedMedia: persistedMedia
            )

            let didPrepareStory = await storyPlanWorkflow.generatePlan(
                momentId: momentId,
                form: form,
                selectedMedia: selectedMedia,
                persistedMedia: persistedMedia
            )
            if didPrepareStory {
                self.recordPreparedStoryInputSignature(inputSignature, momentId: momentId)
            }
        }
    }

    func generatePreview() {
        guard canGeneratePreview, let previewGenerationWorkflow, let context = activeTemplateContext else {
            updatePreviewStatusMessage(previewAvailabilityMessage ?? L10n.string("create.preview.status.notReady"))
            return
        }

        runOperation {
            await previewGenerationWorkflow.generatePreview(
                momentId: context.momentId,
                template: context.template,
                form: self.form
            )
        }
    }

    func preparePreview() {
        if canGeneratePreview {
            generatePreview()
            return
        }

        guard canPlanStory, let storyPlanWorkflow else {
            updateStoryStatusMessage(storyAvailabilityMessage ?? L10n.string("create.error.storyPreparationNotReady"))
            return
        }
        let form = form
        let selectedMedia = selectedMedia
        isPreparingStory = true

        runOperation {
            defer { self.isPreparingStory = false }
            let momentId = await self.resolveMomentIdForPreparation(form: form)

            guard let momentId else {
                self.updateStoryStatusMessage(self.momentCreationFailureMessage())
                return
            }
            guard await self.prepareStoryIfNeeded(
                momentId: momentId,
                form: form,
                selectedMedia: selectedMedia,
                storyPlanWorkflow: storyPlanWorkflow
            ) else {
                return
            }

            guard let previewGenerationWorkflow = self.previewGenerationWorkflow else {
                self.updatePreviewStatusMessage(L10n.string("create.error.storyReviewNotConfigured"))
                return
            }
            await previewGenerationWorkflow.generatePreview(
                momentId: momentId,
                template: form.template,
                form: form
            )
        }
    }

    func createFinalVideoFromCurrentSelection(removesWatermark: Bool = false) {
        guard let finalRenderWorkflow else {
            updateFinalRenderStatusMessage(L10n.string("create.error.videoCreationNotConfigured"))
            return
        }
        guard mediaSelectedCount > 0 else {
            updateFinalRenderStatusMessage(mediaAvailabilityMessage ?? L10n.string("create.error.mediaUnavailable"))
            return
        }
        guard !isFinalRenderEditingLocked else {
            updateFinalRenderStatusMessage(finalRenderAvailabilityMessage ?? L10n.string("create.error.videoCreationNotReady"))
            return
        }
        let form = form
        let creationStyleId = selectedCreationStyle.id
        updateFinalRenderStatusMessage(nil)

        runOperation {
            let momentId = await self.resolveMomentIdForPreparation(form: form)

            guard let momentId else {
                self.updateFinalRenderStatusMessage(self.momentCreationFailureMessage())
                return
            }

            if self.renderPlan == nil || self.renderPlan?.momentId != momentId {
                guard let mediaUploadWorkflow = self.mediaUploadWorkflow else {
                    self.updateFinalRenderStatusMessage(self.mediaAvailabilityMessage ?? L10n.string("create.error.mediaUnavailable"))
                    return
                }
                guard await mediaUploadWorkflow.persistSelectedMediaForFinalVideo(momentId: momentId) else {
                    self.updateFinalRenderStatusMessage(self.mediaStatusMessage ?? MomentsRecoveryCopy.mediaVideoSaveFailure())
                    return
                }
            }

            await finalRenderWorkflow.generateFinalRender(
                momentId: momentId,
                template: form.template,
                creationStyle: creationStyleId,
                form: form,
                removesWatermark: removesWatermark,
                allowPreparedStory: true
            )
        }
    }

    private func resolveMomentIdForPreparation(form: MomentSetupForm) async -> String? {
        if let activeMomentId {
            return activeMomentId
        }
        guard let momentCreationWorkflow else {
            return nil
        }
        let momentId = await momentCreationWorkflow.createMoment(form: form)
        if momentId != nil {
            isLocalMomentStarted = false
        }
        return momentId
    }

    private func prepareStoryIfNeeded(
        momentId: String,
        form: MomentSetupForm,
        selectedMedia: [MomentsSelectedMedia],
        storyPlanWorkflow: StoryPlanWorkflow
    ) async -> Bool {
        var inputSignature = preparedStoryComparisonInputSignature(momentId: momentId)
        if storySummary.hasScenes, lastPreparedStoryInputSignature == inputSignature {
            updateStoryStatusMessage(L10n.string("create.story.status.alreadyReady"))
            return true
        }

        let persistedMedia = await mediaUploadWorkflow?.persistSelectedMedia(momentId: momentId)
        guard persistedMedia != nil || selectedMedia.isEmpty else {
            updateStoryStatusMessage(mediaStatusMessage ?? MomentsRecoveryCopy.mediaStorySaveFailure())
            return false
        }
        inputSignature = currentStoryPlanInputSignature(
            momentId: momentId,
            persistedMedia: persistedMedia
        )

        let didPrepareStory = await storyPlanWorkflow.generatePlan(
            momentId: momentId,
            form: form,
            selectedMedia: selectedMedia,
            persistedMedia: persistedMedia
        )
        if didPrepareStory {
            recordPreparedStoryInputSignature(inputSignature, momentId: momentId)
        }

        guard storySummary.hasScenes, lastPreparedStoryInputSignature == inputSignature else {
            updateStoryStatusMessage(L10n.string("create.error.storyPreparationUnfinished"))
            return false
        }
        return true
    }

    func refreshPreviewStatus() {
        guard canRefreshPreviewStatus, let previewGenerationWorkflow else {
            updatePreviewStatusMessage(previewRefreshAvailabilityMessage ?? L10n.string("create.error.noStoryReviewStatus"))
            return
        }

        runOperation {
            await previewGenerationWorkflow.refreshStatus()
        }
    }

    func generateFinalRender(removesWatermark: Bool = false) {
        guard let finalRenderWorkflow else {
            updateFinalRenderStatusMessage(L10n.string("create.error.videoCreationUnavailable"))
            return
        }
        guard let context = activeTemplateContext else {
            updateFinalRenderStatusMessage(L10n.string("create.error.currentMomentMissing"))
            return
        }
        guard canGenerateFinalRender else {
            updateFinalRenderStatusMessage(
                finalRenderAvailabilityMessage
                    ?? storyAvailabilityMessage
                    ?? L10n.string("create.error.videoCreationNotReady")
            )
            return
        }

        runOperation {
            await finalRenderWorkflow.generateFinalRender(
                momentId: context.momentId,
                template: context.template,
                creationStyle: self.selectedCreationStyle.id,
                form: self.form,
                removesWatermark: removesWatermark
            )
        }
    }

    func autoRefreshFinalRenderStatus() {
        guard canRefreshFinalRenderStatus, let finalRenderWorkflow else {
            return
        }

        runOperation {
            await finalRenderWorkflow.refreshStatus()
        }
    }

    func retryFinalVideoDownload() {
        guard let finalRenderWorkflow else {
            updateFinalRenderStatusMessage(L10n.string("create.error.finalDownloadUnavailable"))
            return
        }

        finalRenderWorkflow.retryFinalVideoDownload()
    }

    func finishFinalVideoToGallery() {
        guard let finalRenderWorkflow else {
            updateFinalRenderStatusMessage(L10n.string("create.error.galleryUnavailable"))
            return
        }

        finalRenderWorkflow.finishFinalExportToGallery()
    }

    func createAnotherFinalVideoVersion(openMediaPicker: Bool = false, openAlbumPicker: Bool = false) {
        resetActiveMoment(force: true)
        _ = beginNewMoment(openMediaPicker: openMediaPicker, openAlbumPicker: openAlbumPicker)
        updateFinalRenderStatusMessage(L10n.string("create.final.status.startAnother"))
    }

    private var activeTemplateContext: (momentId: String, template: MomentTemplate)? {
        guard let activeMomentId else { return nil }
        return (activeMomentId, form.template)
    }

    private var activeFormContext: (momentId: String, form: MomentSetupForm)? {
        guard let activeMomentId else { return nil }
        return (activeMomentId, form)
    }

    private func momentCreationFailureMessage() -> String {
        momentCreationWorkflow?.errorMessage
            ?? setupErrorMessage
            ?? MomentsRecoveryCopy.storyStartFailure()
    }
}
