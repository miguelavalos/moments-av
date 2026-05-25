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
            workflowCards
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

    @ViewBuilder
    private var workflowCards: some View {
        let presentation = viewModel.workflowPresentation

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
                importPickerItems: viewModel.importPickerItems,
                removeMedia: viewModel.removeMedia,
                autoPickStrongMoments: viewModel.autoPickStrongMoments
            )
            .id(MomentsCreateSection.media)

            MomentsCreateStoryCard(
                presentation: MomentsCreateStoryPresentation(
                    summary: presentation.storySummary,
                    canDraftStory: presentation.canDraftStory,
                    availabilityMessage: presentation.storyAvailabilityMessage
                ),
                generateStoryDraft: viewModel.generateStoryDraft
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
                generatePreview: viewModel.generatePreview,
                refreshPreviewStatus: viewModel.refreshPreviewStatus
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
                generateFinalRender: viewModel.generateFinalRender,
                refreshFinalRenderStatus: viewModel.refreshFinalRenderStatus
            )
            .id(MomentsCreateSection.finalRender)
        }
    }
}
