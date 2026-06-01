import Foundation
import PhotosUI
import SwiftUI

extension MomentsCreateViewModel {
    func beginNewProject(openMediaPicker: Bool = true) {
        guard canBeginNewProject else {
            updateDraftErrorMessage(draftAvailabilityMessage ?? "Start a Moment when the account and credits are ready.")
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
            updateDraftErrorMessage(draftAvailabilityMessage ?? "Couldn't start this Moment yet.")
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
            updateDraftErrorMessage("Wait for the current step to finish before discarding this draft.")
            return
        }
        guard hasMomentWorkspace || hasRecoverableMomentContext else {
            updateDraftErrorMessage("There is no active draft to discard.")
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
                self.updateDraftErrorMessage("Couldn't discard this draft. Please try again.")
            }
        }
    }

    func importPickerItems(_ items: [PhotosPickerItem]) {
        guard canAddMedia, let mediaUploadWorkflow else {
            updateDraftErrorMessage(mediaAvailabilityMessage ?? "Media cannot be added right now.")
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
            updateDraftErrorMessage(mediaAvailabilityMessage ?? "Media cannot be added right now.")
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
            updateDraftErrorMessage(mediaAvailabilityMessage ?? "Media cannot be added right now.")
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
            updateStoryStatusMessage(storyAvailabilityMessage ?? "Story preparation is not ready yet.")
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
                self.updateStoryStatusMessage("Story plan is already ready.")
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
            updateStoryStatusMessage("Story reviews are not available in this build.")
            return
        }
        guard balance.canBuyReviewBundle else {
            updateStoryStatusMessage("Add credits before adding more story reviews.")
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
                    "Added \(response.reviewsGranted) story reviews for \(MomentsCreditCopy.countTitle(response.creditsCommitted))."
                )
            } catch let error as LocalizedError {
                self.updateStoryStatusMessage(error.errorDescription ?? "Story reviews could not be added. Please try again.")
            } catch {
                self.updateStoryStatusMessage("Story reviews could not be added. Please try again.")
            }
        }
    }

    func generatePreview() {
        guard canGeneratePreview, let previewGenerationWorkflow, let context = activeTemplateContext else {
            updatePreviewStatusMessage(previewAvailabilityMessage ?? "Story review is not ready yet.")
            return
        }

        runOperation {
            await previewGenerationWorkflow.generatePreview(
                projectId: context.projectId,
                template: context.template
            )
        }
    }

    func preparePreview() {
        if canGeneratePreview {
            generatePreview()
            return
        }

        guard canDraftStory, let storyDraftWorkflow else {
            updateStoryStatusMessage(storyAvailabilityMessage ?? "Story preparation is not ready yet.")
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
                self.updateStoryStatusMessage("Story plan is already ready.")
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
                self.updateStoryStatusMessage("Story preparation did not finish. Please try again.")
                return
            }

            guard let previewGenerationWorkflow = self.previewGenerationWorkflow else {
                self.updatePreviewStatusMessage("Story review is not configured for this build.")
                return
            }
            await previewGenerationWorkflow.generatePreview(
                projectId: projectId,
                template: form.template
            )
        }
    }

    func createFinalVideoFromCurrentSelection(removesWatermark: Bool = false) {
        guard let finalRenderWorkflow else {
            updateFinalRenderStatusMessage("Video creation is not configured for this build.")
            return
        }
        guard canGenerateFinalRender, isStoryPreparedForCurrentInput else {
            updateFinalRenderStatusMessage(finalRenderAvailabilityMessage
                ?? storyAvailabilityMessage
                ?? "Review the story before creating the final video.")
            return
        }
        guard let context = activeTemplateContext else {
            updateFinalRenderStatusMessage("Couldn't find the current Moment. Please go back and try again.")
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
            updatePreviewStatusMessage(previewRefreshAvailabilityMessage ?? "No story review status is available yet.")
            return
        }

        runOperation {
            await previewGenerationWorkflow.refreshStatus()
        }
    }

    func generateFinalRender(removesWatermark: Bool = false) {
        guard let finalRenderWorkflow else {
            updateFinalRenderStatusMessage("Video creation is not available in this build.")
            return
        }
        guard let context = activeTemplateContext else {
            updateFinalRenderStatusMessage("Couldn't find the current Moment. Please go back and try again.")
            return
        }
        guard canGenerateFinalRender else {
            updateFinalRenderStatusMessage(
                finalRenderAvailabilityMessage
                    ?? storyAvailabilityMessage
                    ?? "Video creation is not ready yet."
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
            updateFinalRenderStatusMessage(finalRenderRefreshAvailabilityMessage ?? "No video status is available yet.")
            return
        }

        runOperation {
            await finalRenderWorkflow.refreshStatus()
        }
    }

    func retryFinalVideoDownload() {
        guard let finalRenderWorkflow else {
            updateFinalRenderStatusMessage("Final video download is not available in this build.")
            return
        }

        finalRenderWorkflow.retryFinalVideoDownload()
    }

    func finishFinalVideoToGallery() {
        guard let finalRenderWorkflow else {
            updateFinalRenderStatusMessage("Gallery is not available in this build.")
            return
        }

        finalRenderWorkflow.finishFinalExportToGallery()
    }

    func createAnotherFinalVideoVersion() {
        resetActiveProject(force: true)
        isLocalMomentStarted = true
        updateFinalRenderStatusMessage("Start another version with a fresh Moment.")
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
