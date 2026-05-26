import Foundation
import PhotosUI
import SwiftUI

extension MomentsCreateViewModel {
    func beginNewProject(openMediaPicker: Bool = true) {
        guard canBeginNewProject else { return }
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
        guard canCreateDraft, let projectCreationWorkflow else { return }
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
        guard canStartAnotherProject, let projectCreationWorkflow else { return }

        runOperation {
            let discarded = await projectCreationWorkflow.discardActiveDraft()
            if discarded {
                self.resetActiveProject(force: true)
            }
        }
    }

    func importPickerItems(_ items: [PhotosPickerItem]) {
        guard canAddMedia, let mediaUploadWorkflow else { return }
        let template = form.template

        runOperation {
            await mediaUploadWorkflow.importPickerItems(
                items,
                template: template,
                projectId: self.activeProjectId
            )
        }
    }

    func removeMedia(_ media: MomentsSelectedMedia) {
        mediaUploadWorkflow?.remove(media)
    }

    func autoPickStrongMoments() {
        mediaUploadWorkflow?.autoPickStrongMoments()
    }

    func generateStoryDraft() {
        guard canDraftStory, let storyDraftWorkflow else { return }
        let form = form
        let selectedMedia = selectedMedia

        runOperation {
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

            guard let projectId else { return }

            await storyDraftWorkflow.generateDraft(
                projectId: projectId,
                form: form,
                selectedMedia: selectedMedia
            )
        }
    }

    func generatePreview() {
        guard canGeneratePreview, let previewGenerationWorkflow, let context = activeTemplateContext else { return }

        runOperation {
            await previewGenerationWorkflow.generatePreview(
                projectId: context.projectId,
                template: context.template
            )
        }
    }

    func refreshPreviewStatus() {
        guard canRefreshPreviewStatus, let previewGenerationWorkflow else { return }

        runOperation {
            await previewGenerationWorkflow.refreshStatus()
        }
    }

    func generateFinalRender() {
        guard canGenerateFinalRender, let finalRenderWorkflow, let context = activeTemplateContext else { return }

        runOperation {
            await finalRenderWorkflow.generateFinalRender(
                projectId: context.projectId,
                template: context.template
            )
        }
    }

    func refreshFinalRenderStatus() {
        guard canRefreshFinalRenderStatus, let finalRenderWorkflow else { return }

        runOperation {
            await finalRenderWorkflow.refreshStatus()
        }
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
