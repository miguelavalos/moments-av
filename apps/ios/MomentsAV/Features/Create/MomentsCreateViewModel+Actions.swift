import Foundation
import PhotosUI
import SwiftUI

extension MomentsCreateViewModel {
    func beginNewProject(openMediaPicker: Bool = true) {
        guard canBeginNewProject else {
            updateDraftErrorMessage(draftAvailabilityMessage ?? L10n.string("create.error.startWhenReady"))
            return
        }
        prepareNewDraftCreation()
        isLocalMomentStarted = true
        pendingFocus = .media
        if openMediaPicker {
            mediaPickerOpenRequest += 1
        }
    }

    func editNewProjectStyle() {
        guard !isDraftLocked else { return }
        newProjectStep = .style
    }

    func editNewProjectSummary() {
        guard !isDraftLocked else { return }
        newProjectStep = .style
    }

    func createDraft() {
        createDraft(openMediaPicker: false)
    }

    func createDraft(openMediaPicker: Bool) {
        guard canCreateDraft, let projectCreationWorkflow else {
            updateDraftErrorMessage(draftAvailabilityMessage ?? L10n.string("create.error.startMoment"))
            return
        }
        let form = form
        prepareNewDraftCreation()

        runOperation {
            let projectId = await projectCreationWorkflow.createDraft(form: form)
            if projectId != nil, openMediaPicker {
                self.mediaPickerOpenRequest += 1
            }
        }
    }

    func discardDraft() {
        guard !isBusy else {
            updateDraftErrorMessage(L10n.string("create.error.waitBeforeDiscard"))
            return
        }
        guard hasMomentWorkspace || hasRecoverableMomentContext else {
            updateDraftErrorMessage(L10n.string("create.error.noActiveMoment"))
            return
        }
        if hasLocalMomentWorkspace {
            resetActiveProject(force: true)
            return
        }
        guard let projectCreationWorkflow else {
            resetActiveProject(force: true)
            return
        }

        runOperation {
            let discarded = await projectCreationWorkflow.discardActiveDraft(projectId: self.activeProjectId)
            if discarded {
                self.resetActiveProject(force: true)
            } else if let message = projectCreationWorkflow.errorMessage {
                self.updateDraftErrorMessage(message)
            } else {
                self.updateDraftErrorMessage(L10n.string("create.error.discardMoment"))
            }
        }
    }

    func importPickerItems(_ items: [PhotosPickerItem]) {
        guard canAddMedia, let mediaUploadWorkflow else {
            updateDraftErrorMessage(mediaAvailabilityMessage ?? L10n.string("create.error.mediaUnavailable"))
            return
        }
        let template = form.template

        runOperation {
            await mediaUploadWorkflow.importPickerItems(
                items,
                template: template,
                projectId: self.activeProjectId
            )
        }
    }

    func importLatestPhotos() {
        guard canAddMedia, let mediaUploadWorkflow else {
            updateDraftErrorMessage(mediaAvailabilityMessage ?? L10n.string("create.error.mediaUnavailable"))
            return
        }
        let template = form.template

        runOperation {
            await mediaUploadWorkflow.importLatestPhotos(
                template: template,
                projectId: self.activeProjectId
            )
        }
    }

    func importPhotoAlbum(id albumId: String) {
        guard canAddMedia, let mediaUploadWorkflow else {
            updateDraftErrorMessage(mediaAvailabilityMessage ?? L10n.string("create.error.mediaUnavailable"))
            return
        }
        let template = form.template

        runOperation {
            await mediaUploadWorkflow.importPhotoAlbum(
                id: albumId,
                template: template,
                projectId: self.activeProjectId
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

    func generateStoryDraft() {
        guard canDraftStory, let storyDraftWorkflow else {
            updateStoryStatusMessage(storyAvailabilityMessage ?? L10n.string("create.error.storyPreparationNotReady"))
            return
        }
        let form = form
        let selectedMedia = selectedMedia
        isPreparingStory = true

        runOperation {
            defer { self.isPreparingStory = false }
            let projectId: String?
            if let activeProjectId = self.activeProjectId {
                projectId = activeProjectId
            } else if let projectCreationWorkflow = self.projectCreationWorkflow {
                projectId = await projectCreationWorkflow.createDraft(form: form)
                if projectId != nil {
                    self.isLocalMomentStarted = false
                }
            } else {
                projectId = nil
            }

            guard let projectId else {
                self.updateStoryStatusMessage(self.draftErrorMessage
                    ?? MomentsRecoveryCopy.storyStartFailure()
                )
                return
            }
            if self.storySummary.hasScenes,
               self.lastPreparedStoryInputSignature == self.currentStoryInputSignature(projectId: projectId) {
                self.updateStoryStatusMessage(L10n.string("create.story.status.alreadyReady"))
                return
            }

            let persistedMedia = await self.mediaUploadWorkflow?.persistSelectedMedia(projectId: projectId)
            guard persistedMedia != nil || selectedMedia.isEmpty else {
                self.updateStoryStatusMessage(self.mediaStatusMessage
                    ?? MomentsRecoveryCopy.mediaStorySaveFailure()
                )
                return
            }
            let inputSignature = self.currentStoryInputSignature(
                projectId: projectId,
                persistedMedia: persistedMedia
            )

            let didPrepareStory = await storyDraftWorkflow.generateDraft(
                projectId: projectId,
                form: form,
                selectedMedia: selectedMedia,
                persistedMedia: persistedMedia
            )
            if didPrepareStory {
                self.lastPreparedStoryInputSignature = inputSignature
            }
        }
    }

    func buyStoryReviewBundle() {
        guard let reviewBundlePurchaser else {
            updateStoryStatusMessage(L10n.string("create.reviewBundle.unavailable"))
            return
        }
        guard balance.canBuyReviewBundle else {
            updateStoryStatusMessage(L10n.string("create.reviewBundle.addCreditsFirst"))
            return
        }
        guard !isBusy, !isBuyingReviewBundle else { return }

        isBuyingReviewBundle = true
        updateStoryStatusMessage(nil)
        runOperation {
            defer { self.isBuyingReviewBundle = false }
            do {
                let response = try await reviewBundlePurchaser.purchaseReviewBundle()
                self.updateStoryStatusMessage(
                    L10n.string(
                        "create.reviewBundle.added",
                        response.reviewsGranted,
                        MomentsCreditCopy.countTitle(response.creditsCommitted)
                    )
                )
            } catch let error as LocalizedError {
                self.updateStoryStatusMessage(error.errorDescription ?? L10n.string("create.error.addStoryReviews"))
            } catch {
                self.updateStoryStatusMessage(L10n.string("create.error.addStoryReviews"))
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
                projectId: context.projectId,
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

        guard canDraftStory, let storyDraftWorkflow else {
            updateStoryStatusMessage(storyAvailabilityMessage ?? L10n.string("create.error.storyPreparationNotReady"))
            return
        }
        let form = form
        let selectedMedia = selectedMedia
        isPreparingStory = true

        runOperation {
            defer { self.isPreparingStory = false }
            let projectId: String?
            if let activeProjectId = self.activeProjectId {
                projectId = activeProjectId
            } else if let projectCreationWorkflow = self.projectCreationWorkflow {
                projectId = await projectCreationWorkflow.createDraft(form: form)
                if projectId != nil {
                    self.isLocalMomentStarted = false
                }
            } else {
                projectId = nil
            }

            guard let projectId else {
                self.updateStoryStatusMessage(self.draftErrorMessage
                    ?? MomentsRecoveryCopy.storyStartFailure()
                )
                return
            }
            var inputSignature = self.currentStoryInputSignature(projectId: projectId)
            if self.storySummary.hasScenes,
               self.lastPreparedStoryInputSignature == inputSignature {
                self.updateStoryStatusMessage(L10n.string("create.story.status.alreadyReady"))
            } else {
                let persistedMedia = await self.mediaUploadWorkflow?.persistSelectedMedia(projectId: projectId)
                guard persistedMedia != nil || selectedMedia.isEmpty else {
                    self.updateStoryStatusMessage(self.mediaStatusMessage
                        ?? MomentsRecoveryCopy.mediaStorySaveFailure()
                    )
                    return
                }
                inputSignature = self.currentStoryInputSignature(
                    projectId: projectId,
                    persistedMedia: persistedMedia
                )

                let didPrepareStory = await storyDraftWorkflow.generateDraft(
                    projectId: projectId,
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
                projectId: projectId,
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
                projectId: context.projectId,
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
                projectId: context.projectId,
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
        resetActiveProject(force: true)
        isLocalMomentStarted = true
        updateFinalRenderStatusMessage(L10n.string("create.final.status.startAnother"))
    }

    private var activeTemplateContext: (projectId: String, template: MomentTemplate)? {
        guard let activeProjectId else { return nil }
        return (activeProjectId, form.template)
    }

    private var activeFormContext: (projectId: String, form: MomentDraftForm)? {
        guard let activeProjectId else { return nil }
        return (activeProjectId, form)
    }
}
