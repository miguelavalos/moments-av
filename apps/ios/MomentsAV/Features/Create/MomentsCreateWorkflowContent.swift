import AVSettingsFoundation
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

private struct MomentsCreateIntroCard: View {
    let isSignedIn: Bool

    var body: some View {
        AVSettingsCard {
            Text("Create")
                .font(.headline)
            Text("Build a private memory video from draft setup through media, story, preview, and final export.")
                .foregroundStyle(.secondary)
            Text(isSignedIn ? "Ready to create projects." : "Login is required before creating projects.")
                .font(.subheadline.weight(.semibold))
        }
    }
}

private struct MomentsCreateActiveProjectCard: View {
    let activeProject: MomentDraftProject?

    var body: some View {
        if let activeProject {
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
}

private struct MomentsCreateContinuationHintCard: View {
    let focus: MomentsProjectContinuationFocus?
    let dismiss: () -> Void

    var body: some View {
        if let focus {
            AVSettingsCard {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: focus.systemImage)
                        .font(.title3)
                        .foregroundStyle(MomentsTheme.brandPalette.accent)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(focus.title)
                            .font(.headline)
                        Text(focus.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Button(action: dismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Dismiss continuation hint")
                }
            }
        }
    }
}

private struct MomentsCreateCreditsCard: View {
    let balance: MomentsCreditBalance

    var body: some View {
        AVSettingsCard {
            Text("Spendable credits")
                .font(.headline)
            Text("\(balance.spendable)")
                .font(.title2.weight(.semibold))
            Text("Monthly: \(balance.proMonthly) · Promo: \(balance.promotional) · Purchased: \(balance.purchased)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private extension MomentsProjectContinuationFocus {
    var title: String {
        switch self {
        case .review:
            "Review project"
        case .media:
            "Continue with media"
        case .story:
            "Continue with story"
        case .preview:
            "Continue with preview"
        case .finalRender:
            "Continue with final export"
        }
    }

    var message: String {
        switch self {
        case .review:
            "Check the active project details before continuing the workflow."
        case .media:
            "Add photos or clips for this project, then continue to story generation."
        case .story:
            "Generate the story scenes from the selected media."
        case .preview:
            "Generate or refresh the preview before spending credits on the final export."
        case .finalRender:
            "Render or refresh the final export for the finished video."
        }
    }

    var systemImage: String {
        switch self {
        case .review:
            "rectangle.stack"
        case .media:
            "photo.badge.plus"
        case .story:
            "text.bubble"
        case .preview:
            "play.rectangle"
        case .finalRender:
            "square.and.arrow.up"
        }
    }
}
