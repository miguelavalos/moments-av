import AVSettingsFoundation
import PhotosUI
import SwiftUI

struct MomentsCreateScreen: View {
    @EnvironmentObject private var viewModel: MomentsCreateViewModel
    @State private var pickerItems: [PhotosPickerItem] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                introCard
                activeProjectCard
                creditsCard
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
                    MomentsCreateStoryCard(
                        summary: viewModel.storySummary,
                        canDraftStory: viewModel.canDraftStory,
                        availabilityMessage: viewModel.storyAvailabilityMessage,
                        generateStoryDraft: viewModel.generateStoryDraft
                    )
                    MomentsCreatePreviewCard(
                        summary: viewModel.previewSummary,
                        canGeneratePreview: viewModel.canGeneratePreview,
                        canRefreshPreviewStatus: viewModel.canRefreshPreviewStatus,
                        availabilityMessage: viewModel.previewAvailabilityMessage,
                        refreshAvailabilityMessage: viewModel.previewRefreshAvailabilityMessage,
                        generatePreview: viewModel.generatePreview,
                        refreshPreviewStatus: viewModel.refreshPreviewStatus
                    )
                    MomentsCreateFinalExportCard(
                        summary: viewModel.finalRenderSummary,
                        canGenerateFinalRender: viewModel.canGenerateFinalRender,
                        canRefreshFinalRenderStatus: viewModel.canRefreshFinalRenderStatus,
                        availabilityMessage: viewModel.finalRenderAvailabilityMessage,
                        refreshAvailabilityMessage: viewModel.finalRenderRefreshAvailabilityMessage,
                        generateFinalRender: viewModel.generateFinalRender,
                        refreshFinalRenderStatus: viewModel.refreshFinalRenderStatus
                    )
                }
            }
            .padding(20)
        }
        .background(MomentsTheme.canvas.ignoresSafeArea())
        .navigationTitle("Create")
    }

    private var templateSelection: Binding<MomentTemplateID> {
        Binding(
            get: { viewModel.form.template.id },
            set: { viewModel.selectTemplate(id: $0) }
        )
    }

    private var introCard: some View {
        AVSettingsCard {
            Text("Create")
                .font(.headline)
            Text("Build a private memory video from draft setup through media, story, preview, and final export.")
                .foregroundStyle(.secondary)
            Text(viewModel.isSignedIn ? "Ready to create projects." : "Login is required before creating projects.")
                .font(.subheadline.weight(.semibold))
        }
    }

    @ViewBuilder
    private var activeProjectCard: some View {
        if let activeProject = viewModel.activeProject {
            AVSettingsCard {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "rectangle.stack")
                        .font(.title3)
                        .foregroundStyle(MomentsTheme.brandPalette.accent)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(activeProject.title)
                            .font(.headline)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(MomentsProjectStatusRules.displayTitle(for: activeProject.status))
                            .font(.subheadline.weight(.semibold))
                        Text("Updated \(MomentsDateFormatting.formattedDate(milliseconds: activeProject.updatedAt))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var creditsCard: some View {
        AVSettingsCard {
            Text("Spendable credits")
                .font(.headline)
            Text("\(viewModel.balance.spendable)")
                .font(.title2.weight(.semibold))
            Text("Monthly: \(viewModel.balance.proMonthly) · Promo: \(viewModel.balance.promotional) · Purchased: \(viewModel.balance.purchased)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

}
