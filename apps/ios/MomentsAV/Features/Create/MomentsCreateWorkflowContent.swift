import AVAppShellFoundation
import AVBrandFoundation
import PhotosUI
import SwiftUI

struct MomentsCreateWorkflowContent: View {
    @ObservedObject var viewModel: MomentsCreateViewModel
    @Binding var pickerItems: [PhotosPickerItem]
    let startSignInFlow: () -> Void
    let openCredits: () -> Void
    let cancelCreation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.workflowPresentation.showsMediaFirstWorkspace {
                MomentsCreateMediaFirstWorkspace(
                    form: $viewModel.form,
                    selectedStyle: viewModel.selectedCreationStyle,
                    autoStyleSuggestion: viewModel.autoStyleSuggestion,
                    styles: viewModel.creationStyles,
                    selectedMusicPreset: viewModel.selectedMusicPreset,
                    presentation: viewModel.workflowPresentation,
                    pickerItems: $pickerItems,
                    importPickerItems: viewModel.importPickerItems,
                    importLatestPhotos: viewModel.importLatestPhotos,
                    removeMedia: viewModel.removeMedia,
                    moveMedia: viewModel.moveMedia,
                    reorderMedia: viewModel.reorderMedia,
                    autoPickStrongMoments: viewModel.autoPickStrongMoments,
                    selectStyle: viewModel.selectCreationStyle,
                    selectMusicPreset: viewModel.selectMusicPreset,
                    openPickerRequest: viewModel.mediaPickerOpenRequest,
                    consumeOpenPickerRequest: viewModel.consumeMediaPickerOpenRequest,
                    cancelCreation: cancelCreation,
                    generateStoryDraft: viewModel.generateStoryDraft,
                    generatePreview: viewModel.preparePreview,
                    refreshPreviewStatus: viewModel.refreshPreviewStatus,
                    generateFinalRender: viewModel.generateFinalRender,
                    refreshFinalRenderStatus: viewModel.refreshFinalRenderStatus
                )
            } else {
                draftSetupCard
            }
        }
    }

    private var draftSetupCard: some View {
        MomentsCreateDraftSetupCard(
            form: $viewModel.form,
            selectedStyle: viewModel.selectedCreationStyle,
            styles: viewModel.creationStyles,
            selectedMusicPreset: viewModel.selectedMusicPreset,
            presentation: viewModel.draftSetupPresentation,
            newProjectStep: viewModel.newProjectStep,
            isSignedIn: viewModel.isSignedIn,
            balance: viewModel.balance,
            canBeginNewProject: viewModel.canBeginNewProject,
            beginNewProject: { viewModel.beginNewProject() },
            editStyle: viewModel.editNewProjectStyle,
            selectStyle: viewModel.selectCreationStyle,
            selectMusicPreset: viewModel.selectMusicPreset,
            createDraft: viewModel.createDraft,
            discardDraft: viewModel.discardDraft,
            startSignInFlow: startSignInFlow,
            openCredits: openCredits
        )
    }
}

private struct MomentsCreateMediaFirstWorkspace: View {
    @Binding var form: MomentDraftForm
    let selectedStyle: MomentCreationStyle
    let autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    let styles: [MomentCreationStyle]
    let selectedMusicPreset: MomentMusicPreset
    let presentation: MomentsCreateWorkflowPresentation
    @Binding var pickerItems: [PhotosPickerItem]
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let importLatestPhotos: () -> Void
    let removeMedia: (MomentsSelectedMedia) -> Void
    let moveMedia: (MomentsSelectedMedia, MomentsSelectedMedia) -> Void
    let reorderMedia: ([MomentsSelectedMedia]) -> Void
    let autoPickStrongMoments: () -> Void
    let selectStyle: (MomentCreationStyle) -> Void
    let selectMusicPreset: (MomentMusicPreset) -> Void
    let openPickerRequest: Int
    let consumeOpenPickerRequest: () -> Void
    let cancelCreation: () -> Void
    let generateStoryDraft: () -> Void
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void

    @State private var showsAviOptions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentsCreateDashboardHeader()

            MomentsCreateCompactAviGuide(
                presentation: presentation,
                openOptions: { showsAviOptions = true }
            )

            MomentsCreateMediaCard(
                pickerItems: $pickerItems,
                openPickerRequest: openPickerRequest,
                presentation: mediaPresentation,
                importPickerItems: importPickerItems,
                importLatestPhotos: importLatestPhotos,
                removeMedia: removeMedia,
                moveMedia: moveMedia,
                reorderMedia: reorderMedia,
                autoPickStrongMoments: autoPickStrongMoments,
                consumeOpenPickerRequest: consumeOpenPickerRequest
            )

            MomentsCreateOptionsSummaryCard(
                selectedStyle: selectedStyle,
                selectedMusicPreset: selectedMusicPreset,
                autoStyleSuggestion: autoStyleSuggestion,
                openOptions: { showsAviOptions = true }
            )

            MomentsCreatePrimaryActionBar(
                presentation: presentation,
                cancelCreation: cancelCreation,
                generateStoryDraft: generateStoryDraft,
                generatePreview: generatePreview,
                refreshPreviewStatus: refreshPreviewStatus,
                generateFinalRender: generateFinalRender,
                refreshFinalRenderStatus: refreshFinalRenderStatus
            )
        }
        .safeAreaPadding(.bottom, 28)
        .navigationDestination(isPresented: $showsAviOptions) {
            MomentsCreateAviOptionsSheet(
                form: $form,
                selectedStyle: selectedStyle,
                autoStyleSuggestion: autoStyleSuggestion,
                styles: styles,
                selectedMusicPreset: selectedMusicPreset,
                selectStyle: selectStyle,
                selectMusicPreset: selectMusicPreset,
                autoPickStrongMoments: autoPickStrongMoments,
                dismiss: { showsAviOptions = false }
            )
        }
    }

    private var mediaPresentation: MomentsCreateMediaPresentation {
        MomentsCreateMediaPresentation(
            activeProjectId: presentation.activeProjectId,
            template: presentation.template,
            summary: presentation.mediaSummary,
            canAddMedia: presentation.canAddMedia,
            availabilityMessage: presentation.mediaAvailabilityMessage
        )
    }

}

private struct MomentsCreateDashboardHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Creation Dashboard")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(AVBrandColor.textPrimary)

            Text("Review what Avi prepared, edit only what you want, then preview.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AVBrandColor.textSecondary)
                .lineLimit(2)
        }
    }
}

private struct MomentsCreateOptionsSummaryCard: View {
    let selectedStyle: MomentCreationStyle
    let selectedMusicPreset: MomentMusicPreset
    let autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    let openOptions: () -> Void

    var body: some View {
        Button(action: openOptions) {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text("Options")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary)

                        Spacer(minLength: 0)

                        Text("Edit")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(AVBrandColor.accent)
                    }

                    HStack(spacing: 8) {
                        MomentsCreateOptionPill(title: selectedStyle.title, systemImage: "sparkles")
                        MomentsCreateOptionPill(title: selectedMusicPreset.title, systemImage: "music.note")
                        MomentsCreateOptionPill(title: "Auto length", systemImage: "timer")
                    }

                    Text(detailText)
                        .font(.caption)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Edit options")
    }

    private var detailText: String {
        guard let autoStyleSuggestion else {
            return "Avi can adjust mood, music, rhythm, and the story note before preview."
        }

        return "Suggested by Avi: \(autoStyleSuggestion.reason)"
    }
}

private struct MomentsCreateOptionPill: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(AVBrandColor.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(AVBrandColor.neutral100, in: Capsule())
    }
}

private struct MomentsCreateCompactAviGuide: View {
    let presentation: MomentsCreateWorkflowPresentation
    let openOptions: () -> Void

    var body: some View {
        AVAppShellCard {
            HStack(alignment: .center, spacing: 14) {
                Image("AviFullBody")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(5)
                    .background(AVBrandColor.accent.opacity(0.10), in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(message)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Avi. \(message)")
    }

    private var title: String {
        if presentation.finalRenderSummary.finalExport != nil {
            return "Ready"
        }
        if presentation.previewSummary.latestPreview != nil {
            return "Preview ready"
        }
        if presentation.previewSummary.isGenerating {
            return "Creating preview"
        }
        if presentation.storySummary.isDrafting {
            return "Preparing story"
        }
        if presentation.previewSummary.latestPreviewJob != nil || presentation.finalRenderSummary.latestFinalJob != nil {
            return "Avi is working"
        }
        if presentation.canGeneratePreview {
            return "Story ready"
        }
        if presentation.mediaSummary.selectedCount > 0 || !presentation.mediaSummary.syncedMediaAssets.isEmpty {
            return "Good selection"
        }
        return "Start with your media"
    }

    private var message: String {
        if presentation.finalRenderSummary.finalExport != nil {
            return "Your video is ready to export or share."
        }
        if presentation.previewSummary.latestPreview != nil {
            return "Watch the preview. If it feels right, Avi can create the final video."
        }
        if presentation.previewSummary.isGenerating {
            return presentation.previewSummary.statusMessage ?? "Avi is creating the preview from your selected moments."
        }
        if presentation.storySummary.isDrafting {
            return presentation.storySummary.statusMessage ?? "Avi is organizing the media into a first story plan."
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            return "Avi is finishing the final video."
        }
        if presentation.previewSummary.latestPreviewJob != nil {
            return "Avi is creating the preview from your selected moments."
        }
        if presentation.canGeneratePreview {
            return "Avi has enough to prepare the first preview."
        }
        if presentation.mediaSummary.selectedCount > 0 || !presentation.mediaSummary.syncedMediaAssets.isEmpty {
            return "Avi will organize the story and you can fine tune the selection."
        }
        return "Add photos or clips. Avi will shape the story, mood, and pacing."
    }
}

private struct MomentsCreatePrimaryActionBar: View {
    let presentation: MomentsCreateWorkflowPresentation
    let cancelCreation: () -> Void
    let generateStoryDraft: () -> Void
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Button("Cancel", action: cancelCreation)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)
                        .frame(width: 94, height: 42)
                        .background(AVBrandColor.neutral100, in: Capsule())

                    Button(action: primaryAction) {
                        Label(buttonTitle, systemImage: buttonIconName)
                            .font(.system(size: 14, weight: .black))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                    }
                    .disabled(!canRunPrimaryAction)
                    .buttonStyle(MomentsCreateSoftActionButtonStyle())
                    .opacity(canRunPrimaryAction ? 1 : 0.55)
                }

                if let secondaryActionTitle {
                    Button(secondaryActionTitle, action: secondaryAction)
                        .font(.system(size: 13, weight: .bold))
                        .buttonStyle(MomentsCreateSubtleInlineButtonStyle())
                        .frame(maxWidth: .infinity)
                }

                if let statusMessage {
                    Label(statusMessage, systemImage: statusIconName)
                        .font(.caption)
                        .foregroundStyle(statusColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var canRunPrimaryAction: Bool {
        !isBusy
            && (
                presentation.canGenerateFinalRender
                    || presentation.canGeneratePreview
                    || presentation.canDraftStory
            )
    }

    private var buttonTitle: String {
        if presentation.finalRenderSummary.finalExport != nil {
            return "Final video ready"
        }
        if presentation.previewSummary.latestPreview != nil {
            return presentation.finalRenderSummary.isGenerating ? "Creating final..." : "Create final"
        }
        if presentation.previewSummary.latestPreviewJob != nil {
            return presentation.previewSummary.isRefreshingStatus ? "Refreshing..." : "Refresh preview"
        }
        if presentation.canGeneratePreview {
            return presentation.previewSummary.isGenerating ? "Creating preview..." : "Preview"
        }
        return presentation.storySummary.isDrafting ? "Avi is preparing..." : "Prepare preview"
    }

    private var buttonIconName: String {
        if presentation.finalRenderSummary.finalExport != nil {
            return "checkmark.circle.fill"
        }
        if presentation.previewSummary.latestPreview != nil {
            return "wand.and.stars"
        }
        if presentation.previewSummary.latestPreviewJob != nil {
            return "arrow.clockwise"
        }
        return "play.rectangle.fill"
    }

    private var availabilityMessage: String? {
        if presentation.finalRenderSummary.finalExport != nil {
            return nil
        }
        if presentation.previewSummary.latestPreview != nil {
            return presentation.finalRenderAvailabilityMessage
        }
        if presentation.canGeneratePreview || presentation.previewSummary.latestPreviewJob != nil {
            return presentation.previewAvailabilityMessage
        }
        return presentation.storyAvailabilityMessage
    }

    private var statusMessage: String? {
        if presentation.finalRenderSummary.isGenerating {
            return presentation.finalRenderSummary.statusMessage ?? "Creating final video..."
        }
        if presentation.previewSummary.isGenerating {
            return presentation.previewSummary.statusMessage ?? "Creating preview..."
        }
        if presentation.storySummary.isDrafting {
            return presentation.storySummary.statusMessage ?? "Preparing story..."
        }
        if presentation.finalRenderSummary.finalExport != nil {
            return "Final video ready."
        }
        if presentation.previewSummary.latestPreview != nil {
            return "Preview ready. Review it before final video."
        }
        if let previewMessage = presentation.previewSummary.statusMessage, !previewMessage.isEmpty {
            return previewMessage
        }
        if let storyMessage = presentation.storySummary.statusMessage, !storyMessage.isEmpty {
            return storyMessage
        }
        if let mediaMessage = presentation.mediaSummary.statusMessage, !mediaMessage.isEmpty {
            return mediaMessage
        }
        if !canRunPrimaryAction {
            return availabilityMessage
        }
        if presentation.canGeneratePreview {
            return "Ready to create the first preview."
        }
        if presentation.canDraftStory {
            return "Avi will prepare the story, then create the preview."
        }
        return nil
    }

    private var statusIconName: String {
        if isBusy {
            return "sparkles"
        }
        if presentation.finalRenderSummary.finalExport != nil || presentation.previewSummary.latestPreview != nil {
            return "checkmark.circle.fill"
        }
        if !canRunPrimaryAction {
            return "info.circle.fill"
        }
        return "play.circle.fill"
    }

    private var statusColor: Color {
        if presentation.finalRenderSummary.finalExport != nil || presentation.previewSummary.latestPreview != nil {
            return AVBrandColor.accent
        }
        return AVBrandColor.textSecondary
    }

    private var isBusy: Bool {
        presentation.storySummary.isDrafting
            || presentation.previewSummary.isGenerating
            || presentation.previewSummary.isRefreshingStatus
            || presentation.finalRenderSummary.isGenerating
            || presentation.finalRenderSummary.isRefreshingStatus
    }

    private var secondaryActionTitle: String? {
        if presentation.finalRenderSummary.latestFinalJob != nil && presentation.canRefreshFinalRenderStatus {
            return "Refresh final video"
        }
        return nil
    }

    private func primaryAction() {
        if presentation.finalRenderSummary.finalExport != nil {
            return
        }
        if presentation.previewSummary.latestPreview != nil {
            generateFinalRender()
        } else if presentation.previewSummary.latestPreviewJob != nil {
            refreshPreviewStatus()
        } else if presentation.canGeneratePreview {
            generatePreview()
        } else {
            generateStoryDraft()
        }
    }

    private func secondaryAction() {
        refreshFinalRenderStatus()
    }
}

private struct MomentsCreateLegacyCompactAviGuide: View {
    let presentation: MomentsCreateWorkflowPresentation
    let openOptions: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("AviFullBody")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)
                .padding(4)
                .background(AVBrandColor.accent.opacity(0.10), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Button(action: openOptions) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
            }
            .buttonStyle(MomentsCreateSubtleInlineButtonStyle())
            .accessibilityLabel("Avi options")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AVBrandColor.elevatedSurface.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AVBrandColor.borderSubtle.opacity(0.7), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Avi tip. \(message)")
    }

    private var title: String {
        if presentation.finalRenderSummary.finalExport != nil {
            return "Ready"
        }
        if presentation.previewSummary.latestPreview != nil {
            return "Preview tip"
        }
        if presentation.previewSummary.latestPreviewJob != nil || presentation.finalRenderSummary.latestFinalJob != nil {
            return "Working"
        }
        if presentation.canGeneratePreview {
            return "Story ready"
        }
        if presentation.mediaSummary.selectedCount > 0 || !presentation.mediaSummary.syncedMediaAssets.isEmpty {
            return "Good selection"
        }
        return "Avi tip"
    }

    private var message: String {
        if presentation.finalRenderSummary.finalExport != nil {
            return "Your video is ready to export or share."
        }
        if presentation.previewSummary.latestPreview != nil {
            return "Check the preview. If it feels right, create the final video."
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            return "Avi is finishing the final video. You can refresh when needed."
        }
        if presentation.previewSummary.latestPreviewJob != nil {
            return "Avi is making the preview from your selected moments."
        }
        if presentation.canGeneratePreview {
            return "The story plan is ready. Next step: create the preview."
        }
        if presentation.mediaSummary.selectedCount > 0 || !presentation.mediaSummary.syncedMediaAssets.isEmpty {
            return "Avi uses dates when available, then filename order, then your selection order."
        }
        return "Pick the moments. Avi will shape the story, mood, and pacing."
    }
}

private struct MomentsCreateAviOptionsSheet: View {
    @Binding var form: MomentDraftForm
    let selectedStyle: MomentCreationStyle
    let autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    let styles: [MomentCreationStyle]
    let selectedMusicPreset: MomentMusicPreset
    let selectStyle: (MomentCreationStyle) -> Void
    let selectMusicPreset: (MomentMusicPreset) -> Void
    let autoPickStrongMoments: () -> Void
    let dismiss: () -> Void

    @State private var showsThemeChooser = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                MomentsCreateEditorPageHeader(
                    title: "Guide Avi",
                    dismiss: dismiss
                )

                MomentsCreateOptionsAviPanel()

                MomentsCreateSelectedThemeCard(
                    style: selectedStyle,
                    autoStyleSuggestion: autoStyleSuggestion,
                    changeTheme: { showsThemeChooser = true }
                )

                VStack(alignment: .leading, spacing: 10) {
                    AVAppShellSectionHeader(title: "Music")

                    HStack(spacing: 8) {
                        Button {
                            selectMusicPreset(selectedStyle.defaultMusic)
                        } label: {
                            Text("Automatic")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(selectedMusicPreset == selectedStyle.defaultMusic ? AVBrandColor.textInverse : AVBrandColor.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(selectedMusicPreset == selectedStyle.defaultMusic ? AVBrandColor.ink : AVBrandColor.neutral100)
                                )
                        }
                        .buttonStyle(.plain)

                        ForEach(selectedStyle.allowedMusic.filter { $0 != selectedStyle.defaultMusic }) { preset in
                            Button {
                                selectMusicPreset(preset)
                            } label: {
                                Text(preset.title)
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(selectedMusicPreset == preset ? AVBrandColor.textInverse : AVBrandColor.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(selectedMusicPreset == preset ? AVBrandColor.ink : AVBrandColor.neutral100)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                MomentsCreateAviNoteField(text: $form.details)
            }
            .padding(20)
            .padding(.top, 8)
            .safeAreaPadding(.bottom, 96)
        }
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .navigationDestination(isPresented: $showsThemeChooser) {
            MomentsCreateThemeChooserPage(
                styles: styles,
                selectedStyle: selectedStyle,
                selectStyle: selectStyle,
                dismiss: { showsThemeChooser = false }
            )
            .id(selectedStyle.id)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MomentsCreateOptionsAviPanel: View {
    var body: some View {
        AVAppShellCard {
            HStack(spacing: 12) {
                Image("AviFullBody")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .padding(4)
                    .background(AVBrandColor.accent.opacity(0.10), in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Avi direction")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text("Tell Avi what matters most, or leave everything automatic.")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

private struct MomentsCreateSelectedThemeCard: View {
    let style: MomentCreationStyle
    let autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    let changeTheme: () -> Void

    var body: some View {
        Button(action: changeTheme) {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Text("Theme")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary)

                        Spacer(minLength: 0)

                        Text("Change")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(AVBrandColor.accent)
                    }

                    HStack(spacing: 12) {
                        Image(style.assetName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 76, height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(AVBrandColor.borderSubtle.opacity(0.7), lineWidth: 1)
                            }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(style.title)
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(AVBrandColor.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.82)

                            Text(style.subtitle)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(AVBrandColor.textSecondary)
                                .lineLimit(2)
                        }
                        .layoutPriority(1)

                        Spacer(minLength: 4)
                    }

                HStack(spacing: 8) {
                    MomentsCreateOptionPill(
                        title: style.tone.title,
                        systemImage: "sparkles"
                    )

                    MomentsCreateOptionPill(
                        title: style.tempo.title,
                        systemImage: "timer"
                    )
                }

                Text("Avi uses this theme to set the mood, pacing, and default music.")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                if let autoStyleSuggestion {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Suggested by Avi · \(autoStyleSuggestion.confidenceTitle)", systemImage: "sparkles")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(AVBrandColor.accent)

                        Text(autoStyleSuggestion.reason)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AVBrandColor.textSecondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(autoStyleSuggestion.metrics.summary)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AVBrandColor.textSecondary.opacity(0.72))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 2)
                }
            }
        }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Change theme, \(style.title)")
    }
}

private struct MomentsCreateAviNoteField: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                MomentsCreateGuideFieldIcon(systemImage: "text.bubble.fill")

                VStack(alignment: .leading, spacing: 2) {
                    Text("Note for Avi")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .textCase(.uppercase)

                    Text("Optional direction for the story.")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(AVBrandColor.textSecondary.opacity(0.82))
                }

                Spacer(minLength: 0)

                Button {
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(AVBrandColor.accent)
                        .frame(width: 34, height: 34)
                        .background(AVBrandColor.accent.opacity(0.10), in: Circle())
                }
                .buttonStyle(.plain)
                .disabled(true)
                .accessibilityLabel("Voice note transcription")
            }

            TextField("Tell Avi what to focus on...", text: $text, axis: .vertical)
                .font(AVBrandTypography.body)
                .foregroundStyle(AVBrandColor.textPrimary)
                .lineLimit(3...5)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)
        }
        .padding(AVBrandSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MomentsCreateGuideFieldBackground())
    }
}

private struct MomentsCreateGuideFieldIcon: View {
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(AVBrandColor.accent)
            .frame(width: 28, height: 28)
            .background(
                AVBrandColor.accent.opacity(0.12),
                in: RoundedRectangle(cornerRadius: AVBrandRadius.xs, style: .continuous)
            )
    }
}

private struct MomentsCreateGuideFieldBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: AVBrandRadius.xs, style: .continuous)
            .fill(AVBrandColor.cardSurface.opacity(0.72))
            .overlay {
                RoundedRectangle(cornerRadius: AVBrandRadius.xs, style: .continuous)
                    .stroke(AVBrandColor.borderSubtle.opacity(0.5), lineWidth: 1)
            }
    }
}

private struct MomentsCreateThemeChooserPage: View {
    let styles: [MomentCreationStyle]
    let selectedStyle: MomentCreationStyle
    let selectStyle: (MomentCreationStyle) -> Void
    let dismiss: () -> Void

    @State private var draftStyleID: MomentCreationStyleID

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    init(
        styles: [MomentCreationStyle],
        selectedStyle: MomentCreationStyle,
        selectStyle: @escaping (MomentCreationStyle) -> Void,
        dismiss: @escaping () -> Void
    ) {
        self.styles = styles
        self.selectedStyle = selectedStyle
        self.selectStyle = selectStyle
        self.dismiss = dismiss
        _draftStyleID = State(initialValue: selectedStyle.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    Button(action: dismiss) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(AVBrandColor.elevatedSurface.opacity(0.92), in: Circle())
                            .contentShape(Circle())
                    }
                    .accessibilityLabel("Back")

                    Spacer(minLength: 8)

                    Text("Choose theme")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Spacer(minLength: 8)

                    Button(action: applySelection) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(AVBrandColor.textInverse)
                            .frame(width: 44, height: 44)
                            .background(AVBrandColor.accent, in: Circle())
                            .contentShape(Circle())
                    }
                    .accessibilityLabel("Apply theme")
                }

                AVAppShellCard {
                    HStack(spacing: 12) {
                        Image("AviFullBody")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 42, height: 42)
                            .padding(4)
                            .background(AVBrandColor.accent.opacity(0.10), in: Circle())
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Theme sets the mood")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(AVBrandColor.textPrimary)

                            Text("Choose a visual direction. Avi will adjust tone, pacing, and music from it.")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(AVBrandColor.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 0)
                    }
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(styles) { style in
                        MomentsCreateThemeImageTile(
                            style: style,
                            isSelected: draftStyleID == style.id,
                            selectStyle: { draftStyleID = style.id }
                        )
                    }
                }
            }
            .padding(20)
            .padding(.top, 8)
            .safeAreaPadding(.bottom, 96)
        }
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func applySelection() {
        guard let style = styles.first(where: { $0.id == draftStyleID }) else {
            dismiss()
            return
        }
        selectStyle(style)
        dismiss()
    }
}

private struct MomentsCreateThemeImageTile: View {
    let style: MomentCreationStyle
    let isSelected: Bool
    let selectStyle: () -> Void

    var body: some View {
        Button(action: selectStyle) {
            ZStack(alignment: .bottomLeading) {
                Image(style.assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 94)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .saturation(style.isEnabled ? 1 : 0.2)
                    .opacity(style.isEnabled ? 1 : 0.52)

                LinearGradient(
                    colors: [.black.opacity(0.04), .black.opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(style.title)
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        if !style.isEnabled {
                            Text("Soon")
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(.white.opacity(0.24), in: Capsule())
                        }
                    }

                    Text(style.subtitle)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(10)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white, AVBrandColor.accent)
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(height: 94)
            .background(AVBrandColor.neutral100, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? AVBrandColor.accent : AVBrandColor.borderSubtle.opacity(0.7), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: AVBrandColor.ink.opacity(isSelected ? 0.12 : 0.05), radius: isSelected ? 8 : 4, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(!style.isEnabled)
        .accessibilityLabel("\(style.title) theme\(style.isEnabled ? "" : ", coming soon")")
    }
}

private struct MomentsCreateWorkflowCards: View {
    let presentation: MomentsCreateWorkflowPresentation
    @Binding var pickerItems: [PhotosPickerItem]
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let importLatestPhotos: () -> Void
    let removeMedia: (MomentsSelectedMedia) -> Void
    let moveMedia: (MomentsSelectedMedia, MomentsSelectedMedia) -> Void
    let reorderMedia: ([MomentsSelectedMedia]) -> Void
    let autoPickStrongMoments: () -> Void
    let openPickerRequest: Int
    let generateStoryDraft: () -> Void
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void

    @ViewBuilder
    var body: some View {
        if presentation.showsWorkflowCards {
            switch presentation.currentStage {
            case .media:
                MomentsCreateMediaCard(
                    pickerItems: $pickerItems,
                    openPickerRequest: openPickerRequest,
                    presentation: MomentsCreateMediaPresentation(
                        activeProjectId: presentation.activeProjectId,
                        template: presentation.template,
                        summary: presentation.mediaSummary,
                        canAddMedia: presentation.canAddMedia,
                        availabilityMessage: presentation.mediaAvailabilityMessage
                    ),
                    importPickerItems: importPickerItems,
                    importLatestPhotos: importLatestPhotos,
                    removeMedia: removeMedia,
                    moveMedia: moveMedia,
                    reorderMedia: reorderMedia,
                    autoPickStrongMoments: autoPickStrongMoments,
                    consumeOpenPickerRequest: {}
                )
                .id(MomentsCreateSection.media)

            case .story:
                MomentsCreateStoryCard(
                    presentation: MomentsCreateStoryPresentation(
                        summary: presentation.storySummary,
                        canDraftStory: presentation.canDraftStory,
                        availabilityMessage: presentation.storyAvailabilityMessage
                    ),
                    generateStoryDraft: generateStoryDraft
                )
                .id(MomentsCreateSection.story)

            case .preview:
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

            case .finalVideo:
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
}
