import PhotosUI
import SwiftUI

struct MomentsCreateWorkflowContent: View {
    @ObservedObject var viewModel: MomentsCreateViewModel
    @Binding var pickerItems: [PhotosPickerItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            MomentsCreateIntroCard(isSignedIn: viewModel.isSignedIn)
            MomentsCreateActiveProjectCard(activeProject: viewModel.activeProject)
                .id(MomentsCreateSection.review)
            MomentsCreateContinuationHintCard(
                focus: viewModel.continuationFocusHint,
                dismiss: viewModel.clearContinuationFocusHint
            )
            MomentsCreateCreditsCard(balance: viewModel.balance)
            draftSetupCard
            MomentsCreateWorkflowCards(
                presentation: viewModel.workflowPresentation,
                pickerItems: $pickerItems,
                importPickerItems: viewModel.importPickerItems,
                removeMedia: viewModel.removeMedia,
                autoPickStrongMoments: viewModel.autoPickStrongMoments,
                generateStoryDraft: viewModel.generateStoryDraft,
                generatePreview: viewModel.generatePreview,
                refreshPreviewStatus: viewModel.refreshPreviewStatus,
                generateFinalRender: viewModel.generateFinalRender,
                refreshFinalRenderStatus: viewModel.refreshFinalRenderStatus
            )
        }
        .padding(20)
    }

    private var templateSelection: Binding<MomentTemplateID> {
        Binding(
            get: { viewModel.form.template.id },
            set: { viewModel.selectTemplate(id: $0) }
        )
    }

    private var draftSetupCard: some View {
        MomentsCreateDraftSetupCard(
            form: $viewModel.form,
            templateSelection: templateSelection,
            templates: viewModel.templates,
            presentation: viewModel.draftSetupPresentation,
            createDraft: viewModel.createDraft,
            startAnotherProject: viewModel.startAnotherProject
        )
    }
}

private struct MomentsCreateWorkflowCards: View {
    let presentation: MomentsCreateWorkflowPresentation
    @Binding var pickerItems: [PhotosPickerItem]
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let removeMedia: (MomentsSelectedMedia) -> Void
    let autoPickStrongMoments: () -> Void
    let generateStoryDraft: () -> Void
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void

    @ViewBuilder
    var body: some View {
        if let activeProjectId = presentation.activeProjectId {
            MomentsCreateMediaCard(
                pickerItems: $pickerItems,
                presentation: MomentsCreateMediaPresentation(
                    activeProjectId: activeProjectId,
                    template: presentation.template,
                    summary: presentation.mediaSummary,
                    canAddMedia: presentation.canAddMedia,
                    availabilityMessage: presentation.mediaAvailabilityMessage
                ),
                importPickerItems: importPickerItems,
                removeMedia: removeMedia,
                autoPickStrongMoments: autoPickStrongMoments
            )
            .id(MomentsCreateSection.media)

            MomentsCreateStoryCard(
                presentation: MomentsCreateStoryPresentation(
                    summary: presentation.storySummary,
                    canDraftStory: presentation.canDraftStory,
                    availabilityMessage: presentation.storyAvailabilityMessage
                ),
                generateStoryDraft: generateStoryDraft
            )
            .id(MomentsCreateSection.story)

            MomentsCreatePreviewCard(
                presentation: MomentsCreatePreviewPresentation(
                    summary: presentation.previewSummary,
                    canGeneratePreview: presentation.canGeneratePreview,
                    canRefreshPreviewStatus: presentation.canRefreshPreviewStatus,
                    availabilityMessage: presentation.previewAvailabilityMessage,
                    refreshAvailabilityMessage: presentation.previewRefreshAvailabilityMessage
                ),
                generatePreview: generatePreview,
                refreshPreviewStatus: refreshPreviewStatus
            )
            .id(MomentsCreateSection.preview)

            MomentsCreateFinalExportCard(
                presentation: MomentsCreateFinalRenderPresentation(
                    summary: presentation.finalRenderSummary,
                    canGenerateFinalRender: presentation.canGenerateFinalRender,
                    canRefreshFinalRenderStatus: presentation.canRefreshFinalRenderStatus,
                    availabilityMessage: presentation.finalRenderAvailabilityMessage,
                    refreshAvailabilityMessage: presentation.finalRenderRefreshAvailabilityMessage
                ),
                generateFinalRender: generateFinalRender,
                refreshFinalRenderStatus: refreshFinalRenderStatus
            )
            .id(MomentsCreateSection.finalRender)
        }
    }
}
