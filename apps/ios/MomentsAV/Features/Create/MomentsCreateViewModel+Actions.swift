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
        guard canAddMedia, let mediaUploadWorkflow, let createdProjectId else { return }
        let template = form.template

        runOperation {
            await mediaUploadWorkflow.importPickerItems(
                items,
                template: template,
                projectId: createdProjectId
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
        guard canDraftStory, let storyDraftWorkflow, let createdProjectId else { return }
        let form = form

        runOperation {
            await storyDraftWorkflow.generateDraft(
                projectId: createdProjectId,
                form: form
            )
        }
    }

    func generatePreview() {
        guard canGeneratePreview, let previewGenerationWorkflow, let createdProjectId else { return }
        let template = form.template

        runOperation {
            await previewGenerationWorkflow.generatePreview(
                projectId: createdProjectId,
                template: template
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
        guard canGenerateFinalRender, let finalRenderWorkflow, let createdProjectId else { return }
        let template = form.template

        runOperation {
            await finalRenderWorkflow.generateFinalRender(
                projectId: createdProjectId,
                template: template
            )
        }
    }

    func refreshFinalRenderStatus() {
        guard canRefreshFinalRenderStatus, let finalRenderWorkflow else { return }

        runOperation {
            await finalRenderWorkflow.refreshStatus()
        }
    }
}
