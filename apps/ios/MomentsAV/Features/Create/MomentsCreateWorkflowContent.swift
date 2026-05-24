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
            isDraftLocked: viewModel.isDraftLocked,
            isCreatingDraft: viewModel.isCreatingDraft,
            canCreateDraft: viewModel.canCreateDraft,
            availabilityMessage: viewModel.draftAvailabilityMessage,
            createdProjectId: viewModel.createdProjectId,
            isContinuingProject: viewModel.isContinuingProject,
            canStartAnotherProject: viewModel.canStartAnotherProject,
            draftErrorMessage: viewModel.draftErrorMessage,
            workspaceSummary: viewModel.workspaceSummary,
            canAfford: viewModel.canAfford,
            spendPlanDescription: viewModel.spendPlanDescription,
            createDraft: viewModel.createDraft,
            startAnotherProject: viewModel.startAnotherProject
        )
    }

    @ViewBuilder
    private var workflowCards: some View {
        if let createdProjectId = viewModel.createdProjectId {
            MomentsCreateMediaCard(
                pickerItems: $pickerItems,
                createdProjectId: createdProjectId,
                template: viewModel.form.template,
                summary: viewModel.mediaSummary,
                canAddMedia: viewModel.canAddMedia,
                availabilityMessage: viewModel.mediaAvailabilityMessage,
                importPickerItems: viewModel.importPickerItems,
                removeMedia: viewModel.removeMedia,
                autoPickStrongMoments: viewModel.autoPickStrongMoments
            )
            .id(MomentsCreateSection.media)

            MomentsCreateStoryCard(
                summary: viewModel.storySummary,
                canDraftStory: viewModel.canDraftStory,
                availabilityMessage: viewModel.storyAvailabilityMessage,
                generateStoryDraft: viewModel.generateStoryDraft
            )
            .id(MomentsCreateSection.story)

            MomentsCreatePreviewCard(
                summary: viewModel.previewSummary,
                canGeneratePreview: viewModel.canGeneratePreview,
                canRefreshPreviewStatus: viewModel.canRefreshPreviewStatus,
                availabilityMessage: viewModel.previewAvailabilityMessage,
                refreshAvailabilityMessage: viewModel.previewRefreshAvailabilityMessage,
                generatePreview: viewModel.generatePreview,
                refreshPreviewStatus: viewModel.refreshPreviewStatus
            )
            .id(MomentsCreateSection.preview)

            MomentsCreateFinalExportCard(
                summary: viewModel.finalRenderSummary,
                canGenerateFinalRender: viewModel.canGenerateFinalRender,
                canRefreshFinalRenderStatus: viewModel.canRefreshFinalRenderStatus,
                availabilityMessage: viewModel.finalRenderAvailabilityMessage,
                refreshAvailabilityMessage: viewModel.finalRenderRefreshAvailabilityMessage,
                generateFinalRender: viewModel.generateFinalRender,
                refreshFinalRenderStatus: viewModel.refreshFinalRenderStatus
            )
            .id(MomentsCreateSection.finalRender)
        }
    }
}
