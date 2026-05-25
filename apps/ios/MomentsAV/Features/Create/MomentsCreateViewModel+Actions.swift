import Foundation
import PhotosUI
import SwiftUI

extension MomentsCreateViewModel {
    func createDraft() {
        guard canCreateDraft, let projectCreationWorkflow else { return }
        let form = form
        prepareNewDraftCreation()

        runOperation {
            _ = await projectCreationWorkflow.createDraft(form: form)
        }
    }

    func startAnotherProject() {
        guard canStartAnotherProject else { return }

        resetActiveProject(force: false)
    }

    func importPickerItems(_ items: [PhotosPickerItem]) {
        guard canAddMedia, let mediaUploadWorkflow, let context = activeTemplateContext else { return }

        runOperation {
            await mediaUploadWorkflow.importPickerItems(
                items,
                template: context.template,
                projectId: context.projectId
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
        guard canDraftStory, let storyDraftWorkflow, let context = activeFormContext else { return }

        runOperation {
            await storyDraftWorkflow.generateDraft(
                projectId: context.projectId,
                form: context.form
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
