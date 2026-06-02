import Foundation
import PhotosUI
import SwiftUI

extension MomentsCreateViewModel {
    @discardableResult
    func beginNewMoment(openMediaPicker: Bool = true) -> Bool {
        guard canBeginNewMoment else {
            updateSetupErrorMessage(setupAvailabilityMessage ?? L10n.string("create.error.startWhenReady"))
            return false
        }
        prepareNewMomentCreation()
        isLocalMomentStarted = true
        pendingFocus = .media
        if openMediaPicker {
            mediaPickerOpenRequest += 1
        }
        return true
    }

    func discardMoment() {
        guard !isBusy else {
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

        runOperation {
            await mediaUploadWorkflow.importPhotoAlbum(
                id: albumId,
                template: template,
                momentId: self.activeMomentId
            )
        }
    }

    func removeMedia(_ media: MomentsSelectedMedia) {
        mediaUploadWorkflow?.remove(media)
    }

    func moveMedia(_ media: MomentsSelectedMedia, before target: MomentsSelectedMedia) {
        mediaUploadWorkflow?.move(media, before: target)
    }

    func reorderMedia(_ media: [MomentsSelectedMedia]) {
        mediaUploadWorkflow?.reorder(media)
    }

    func autoPickStrongMoments() {
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
               self.lastPreparedStoryInputSignature == self.currentStoryPlanInputSignature(momentId: momentId) {
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
                self.lastPreparedStoryInputSignature = inputSignature
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
            var inputSignature = self.currentStoryPlanInputSignature(momentId: momentId)
            if self.storySummary.hasScenes,
               self.lastPreparedStoryInputSignature == inputSignature {
                self.updateStoryStatusMessage(L10n.string("create.story.status.alreadyReady"))
            } else {
                let persistedMedia = await self.mediaUploadWorkflow?.persistSelectedMedia(momentId: momentId)
                guard persistedMedia != nil || selectedMedia.isEmpty else {
                    self.updateStoryStatusMessage(self.mediaStatusMessage
                        ?? MomentsRecoveryCopy.mediaStorySaveFailure()
                    )
                    return
                }
                inputSignature = self.currentStoryPlanInputSignature(
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
                    self.lastPreparedStoryInputSignature = inputSignature
                }
            }

            guard self.storySummary.hasScenes,
                  self.lastPreparedStoryInputSignature == inputSignature else {
                self.updateStoryStatusMessage(L10n.string("create.error.storyPreparationUnfinished"))
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
        guard canGenerateFinalRender, isStoryPreparedForCurrentInput else {
            updateFinalRenderStatusMessage(finalRenderAvailabilityMessage
                ?? storyAvailabilityMessage
                ?? L10n.string("create.error.reviewBeforeVideo"))
            return
        }
        guard let context = activeTemplateContext else {
            updateFinalRenderStatusMessage(L10n.string("create.error.currentMomentMissing"))
            return
        }

        runOperation {
            await finalRenderWorkflow.generateFinalRender(
                momentId: context.momentId,
                template: context.template,
                creationStyle: self.selectedCreationStyle.id,
                form: self.form,
                removesWatermark: removesWatermark,
                allowPreparedStory: true
            )
        }
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

    func refreshFinalRenderStatus() {
        guard canRefreshFinalRenderStatus, let finalRenderWorkflow else {
            updateFinalRenderStatusMessage(finalRenderRefreshAvailabilityMessage ?? L10n.string("create.error.noVideoStatus"))
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

    func createAnotherFinalVideoVersion() {
        resetActiveMoment(force: true)
        isLocalMomentStarted = true
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
