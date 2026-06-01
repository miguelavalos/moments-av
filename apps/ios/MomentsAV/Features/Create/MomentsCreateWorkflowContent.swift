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
                    canUndoAutoStyleSuggestion: viewModel.canUndoAutoStyleSuggestion,
                    styles: viewModel.creationStyles,
                    selectedMusicPreset: viewModel.selectedMusicPreset,
                    presentation: viewModel.workflowPresentation,
                    isPreparingStory: viewModel.isPreparingStory,
                    pickerItems: $pickerItems,
                    importPickerItems: viewModel.importPickerItems,
                    importLatestPhotos: viewModel.importLatestPhotos,
                    importPhotoAlbum: viewModel.importPhotoAlbum,
                    removeMedia: viewModel.removeMedia,
                    moveMedia: viewModel.moveMedia,
                    reorderMedia: viewModel.reorderMedia,
                    restoreLocalMediaForEditing: viewModel.restoreLocalMediaForEditing,
                    autoPickStrongMoments: viewModel.autoPickStrongMoments,
                    selectStyle: viewModel.selectCreationStyle,
                    selectMusicPreset: viewModel.selectMusicPreset,
                    useAutoStyleSuggestion: viewModel.useAutoStyleSuggestion,
                    undoAutoStyleSuggestion: viewModel.undoAutoStyleSuggestion,
                    openPickerRequest: viewModel.mediaPickerOpenRequest,
                    consumeOpenPickerRequest: viewModel.consumeMediaPickerOpenRequest,
                    discardDraft: viewModel.discardDraft,
                    startSignInFlow: startSignInFlow,
                    openCredits: openCredits,
                    generateStoryDraft: viewModel.generateStoryDraft,
                    buyReviewBundle: viewModel.buyStoryReviewBundle,
                    generatePreview: viewModel.preparePreview,
                    refreshPreviewStatus: viewModel.refreshPreviewStatus,
                    generateFinalRender: viewModel.createFinalVideoFromCurrentSelection,
                    refreshFinalRenderStatus: viewModel.refreshFinalRenderStatus,
                    retryFinalVideoDownload: viewModel.retryFinalVideoDownload,
                    finishFinalVideoToGallery: viewModel.finishFinalVideoToGallery,
                    createAnotherFinalVideoVersion: viewModel.createAnotherFinalVideoVersion
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
    let canUndoAutoStyleSuggestion: Bool
    let styles: [MomentCreationStyle]
    let selectedMusicPreset: MomentMusicPreset
    let presentation: MomentsCreateWorkflowPresentation
    let isPreparingStory: Bool
    @Binding var pickerItems: [PhotosPickerItem]
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let importLatestPhotos: () -> Void
    let importPhotoAlbum: (String) -> Void
    let removeMedia: (MomentsSelectedMedia) -> Void
    let moveMedia: (MomentsSelectedMedia, MomentsSelectedMedia) -> Void
    let reorderMedia: ([MomentsSelectedMedia]) -> Void
    let restoreLocalMediaForEditing: () -> Void
    let autoPickStrongMoments: () -> Void
    let selectStyle: (MomentCreationStyle) -> Void
    let selectMusicPreset: (MomentMusicPreset) -> Void
    let useAutoStyleSuggestion: () -> Void
    let undoAutoStyleSuggestion: () -> Void
    let openPickerRequest: Int
    let consumeOpenPickerRequest: () -> Void
    let discardDraft: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void
    let generateStoryDraft: () -> Void
    let buyReviewBundle: () -> Void
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void
    let generateFinalRender: (Bool) -> Void
    let refreshFinalRenderStatus: () -> Void
    let retryFinalVideoDownload: () -> Void
    let finishFinalVideoToGallery: () -> Void
    let createAnotherFinalVideoVersion: () -> Void

    @State private var showsAviOptions = false
    @State private var showsStoryReview = false
    @State private var opensStoryReviewAfterDraft = false
    @State private var showsCreateVideoConfirmation = false
    @State private var showsDiscardDraftConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                MomentsCreateDashboardHeader(presentation: presentation)

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
                    importPhotoAlbum: importPhotoAlbum,
                    removeMedia: removeMedia,
                    moveMedia: moveMedia,
                    reorderMedia: reorderMedia,
                    restoreLocalMediaForEditing: restoreLocalMediaForEditing,
                    autoPickStrongMoments: autoPickStrongMoments,
                    consumeOpenPickerRequest: consumeOpenPickerRequest
                )

                MomentsCreateOptionsSummaryCard(
                    selectedStyle: selectedStyle,
                    selectedMusicPreset: selectedMusicPreset,
                    autoStyleSuggestion: autoStyleSuggestion,
                    canUndoAutoStyleSuggestion: canUndoAutoStyleSuggestion,
                    styles: styles,
                    openOptions: { showsAviOptions = true }
                )

                MomentsCreatePrimaryActionBar(
                    presentation: presentation,
                    discardDraft: { showsDiscardDraftConfirmation = true },
                    startSignInFlow: startSignInFlow,
                    reviewStoryFirst: reviewStoryFirst,
                    generatePreview: generatePreview,
                    refreshPreviewStatus: refreshPreviewStatus,
                    generateFinalRender: reviewStoryFirst,
                    refreshFinalRenderStatus: refreshFinalRenderStatus,
                    retryFinalVideoDownload: retryFinalVideoDownload,
                    finishFinalVideoToGallery: finishFinalVideoToGallery,
                    createAnotherFinalVideoVersion: createAnotherFinalVideoVersion
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 172)
        }
        .scrollIndicators(.hidden)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: presentation.storySummary.hasScenes)
        .onChange(of: presentation.storySummary.hasScenes) { _, hasScenes in
            guard hasScenes, opensStoryReviewAfterDraft else { return }
            opensStoryReviewAfterDraft = false
            showsStoryReview = true
        }
        .alert(MomentsL10n.string("create.final.confirmTitle"), isPresented: $showsCreateVideoConfirmation) {
            Button(MomentsL10n.string("create.action.notNow"), role: .cancel) {}
            Button(MomentsL10n.string("create.final.createWithCost", creditCostTitle)) {
                generateFinalRender(false)
            }
        } message: {
            Text(MomentsL10n.string("create.final.confirmMessage", creditCostTitle))
        }
        .alert(MomentsL10n.string("create.discard.confirmTitle"), isPresented: $showsDiscardDraftConfirmation) {
            Button(MomentsL10n.string("create.discard.keep"), role: .cancel) {}
            Button(discardConfirmationActionTitle, role: .destructive) {
                discardCurrentDraft()
            }
        } message: {
            Text(discardConfirmationMessage)
        }
        .navigationDestination(isPresented: $showsAviOptions) {
            MomentsCreateAviOptionsSheet(
                form: $form,
                selectedStyle: selectedStyle,
                autoStyleSuggestion: autoStyleSuggestion,
                canUndoAutoStyleSuggestion: canUndoAutoStyleSuggestion,
                styles: styles,
                selectedMusicPreset: selectedMusicPreset,
                selectStyle: selectStyle,
                selectMusicPreset: selectMusicPreset,
                useAutoStyleSuggestion: useAutoStyleSuggestion,
                undoAutoStyleSuggestion: undoAutoStyleSuggestion,
                autoPickStrongMoments: autoPickStrongMoments,
                dismiss: { showsAviOptions = false }
            )
        }
        .navigationDestination(isPresented: $showsStoryReview) {
                MomentsCreateStoryReviewPage(
                    presentation: presentation,
                    createVideo: generateFinalRender,
                    buyReviewBundle: buyReviewBundle,
                    openCredits: openCredits,
                discardDraft: discardCurrentDraft,
                dismiss: { showsStoryReview = false }
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

    private func reviewStoryFirst() {
        guard !presentation.storySummary.hasScenes else {
            showsStoryReview = true
            return
        }
        opensStoryReviewAfterDraft = true
        generateStoryDraft()
    }

    private var creditCostTitle: String {
        MomentsCreditCopy.countTitle(presentation.finalRenderSummary.creditCost)
    }

    private func discardCurrentDraft() {
        showsStoryReview = false
        showsAviOptions = false
        discardDraft()
    }

    private var discardConfirmationActionTitle: String {
        presentation.hasUnsavedLocalMoment ? MomentsL10n.string("create.discard.local") : MomentsL10n.string("create.discard.current")
    }

    private var discardConfirmationMessage: String {
        if presentation.hasUnsavedLocalMoment {
            return MomentsL10n.string("create.discard.localMessage")
        }

        return MomentsL10n.string("create.discard.currentMessage")
    }
}

private struct MomentsCreateDashboardHeader: View {
    let presentation: MomentsCreateWorkflowPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Creation Dashboard")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(AVBrandColor.textPrimary)

            Text(subtitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AVBrandColor.textSecondary)
                .lineLimit(2)
        }
    }

    private var subtitle: String {
        if presentation.finalRenderSummary.finalExport != nil {
            return "Your final video is ready to review and share."
        }
        if let realtimeStatus = presentation.finalRenderSummary.realtimeStatus {
            return realtimeStatus.detail
        }
        if presentation.storySummary.hasScenes {
            return "Avi has a story plan. Create the video when ready."
        }
        return "Review what Avi prepared, then create the video when ready."
    }
}

struct MomentsCreateBlockingPreparationView: View {
    let presentation: MomentsCreateWorkflowPresentation
    let isPreparingStory: Bool

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 42)

            ZStack {
                Circle()
                    .fill(mode.tint.opacity(0.10))
                    .frame(width: 128, height: 128)

                Circle()
                    .stroke(mode.tint.opacity(0.18), lineWidth: 2)
                    .frame(width: 156, height: 156)
                    .scaleEffect(isAnimating ? 1.08 : 0.92)
                    .opacity(isAnimating ? 0.20 : 0.58)

                Image("AviFullBody")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 86, height: 86)
                    .offset(y: isAnimating ? -4 : 3)

                Image(systemName: mode.iconName)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(mode.tint, in: Circle())
                    .offset(x: 54, y: 48)
                    .shadow(color: mode.tint.opacity(0.24), radius: 10, y: 4)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                Text(message)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 8) {
                if let fractionCompleted = progress?.fractionCompleted {
                    ProgressView(value: fractionCompleted)
                        .tint(mode.tint)
                        .frame(width: 168)
                    Text(progress?.title ?? "Reading media")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(AVBrandColor.textSecondary)
                } else {
                    ProgressView()
                        .tint(mode.tint)
                        .controlSize(.regular)
                }
            }
            .padding(.top, 4)

            Spacer(minLength: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }

    private var title: String {
        mode.title
    }

    private var message: String {
        mode.message(itemCount: progress?.totalCount)
    }

    private var progress: MomentsMediaImportProgress? {
        presentation.mediaSummary.importProgress
    }

    private var mode: PreparationMode {
        if presentation.finalRenderSummary.isGenerating {
            return .createVideo
        }
        if presentation.previewSummary.isGenerating {
            return .createPreview
        }
        if presentation.storySummary.isDrafting {
            return .prepareStory
        }
        if isPreparingStory {
            return .uploadForVideo
        }
        return .importMedia
    }

    private enum PreparationMode {
        case importMedia
        case prepareStory
        case uploadForVideo
        case createVideo
        case createPreview

        var title: String {
            switch self {
            case .importMedia:
                return "Reading your selection"
            case .prepareStory:
                return "Preparing your story"
            case .uploadForVideo:
                return "Uploading media"
            case .createVideo:
                return "Creating your video"
            case .createPreview:
                return "Reviewing your story"
            }
        }

        var iconName: String {
            switch self {
            case .importMedia:
                return "photo.on.rectangle.angled"
            case .prepareStory:
                return "list.bullet.rectangle.portrait.fill"
            case .uploadForVideo:
                return "icloud.and.arrow.up.fill"
            case .createVideo:
                return "video.fill"
            case .createPreview:
                return "text.bubble.fill"
            }
        }

        var tint: Color {
            switch self {
            case .importMedia, .prepareStory:
                return AVBrandColor.accent
            case .uploadForVideo:
                return AVBrandColor.textSecondary
            case .createVideo, .createPreview:
                return AVBrandColor.textPrimary
            }
        }

        func message(itemCount: Int?) -> String {
            switch self {
            case .importMedia:
                if let itemCount, itemCount > 0 {
                    return "Avi is reading \(itemCount) \(itemCount == 1 ? "item" : "items") and setting up the first review."
                }
                return "Avi is reading the selection and setting up the first review."
            case .prepareStory:
                return "Avi is organizing the selected moments into an edited video plan."
            case .uploadForVideo:
                if let itemCount, itemCount > 0 {
                    return "Sending \(itemCount) \(itemCount == 1 ? "item" : "items") needed for final video creation."
                }
                return "Sending the selected media needed for final video creation."
            case .createVideo:
                return "Avi is starting the final edit. This can take a few minutes."
            case .createPreview:
                return "Avi is checking the story plan before final video creation."
            }
        }
    }
}

private struct MomentsCreateOptionsSummaryCard: View {
    let selectedStyle: MomentCreationStyle
    let selectedMusicPreset: MomentMusicPreset
    let autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    let canUndoAutoStyleSuggestion: Bool
    let styles: [MomentCreationStyle]
    let openOptions: () -> Void

    var body: some View {
        Button(action: openOptions) {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text(MomentsL10n.string("create.options.title"))
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary)

                        Spacer(minLength: 0)

                        Text(MomentsL10n.string("common.edit"))
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(AVBrandColor.accent)
                    }

                    HStack(spacing: 8) {
                        MomentsCreateOptionPill(title: selectedStyle.title, systemImage: "sparkles")
                        MomentsCreateOptionPill(title: selectedMusicPreset.title, systemImage: "music.note")
                        MomentsCreateOptionPill(title: MomentsL10n.string("create.duration.auto.title"), systemImage: "timer")
                    }

                    if let suggestionText {
                        HStack(spacing: 8) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(AVBrandColor.accent)

                            Text(suggestionText)
                                .font(.caption)
                                .fontWeight(.black)
                                .foregroundStyle(AVBrandColor.accent)
                                .lineLimit(2)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AVBrandColor.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
        .accessibilityLabel(MomentsL10n.string("create.options.edit"))
    }

    private var detailText: String {
        guard autoStyleSuggestion != nil else {
            return MomentsL10n.string("create.options.detail")
        }

        if canUndoAutoStyleSuggestion {
            return MomentsL10n.string("create.options.suggestionActive")
        }

        return MomentsL10n.string("create.options.suggestionAvailable")
    }

    private var suggestionText: String? {
        guard let autoStyleSuggestion else { return nil }
        let styleTitle = styles.first(where: { $0.id == autoStyleSuggestion.styleID })?.title ?? "another theme"
        if canUndoAutoStyleSuggestion {
            return "Using Avi suggestion: \(styleTitle) · \(autoStyleSuggestion.musicPreset.title)"
        }
        guard selectedStyle.id != autoStyleSuggestion.styleID || selectedMusicPreset != autoStyleSuggestion.musicPreset else {
            return nil
        }
        return MomentsL10n.string("create.options.suggestion", styleTitle, autoStyleSuggestion.musicPreset.title)
    }
}

private struct MomentsCreateStoryReviewCard: View {
    let presentation: MomentsCreateWorkflowPresentation

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Text("Story direction")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Spacer(minLength: 0)

                    Text(sceneCountTitle)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AVBrandColor.accent)
                }

                Text("Review the pacing and message before spending video credits.")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AVBrandColor.textSecondary)

                VStack(alignment: .leading, spacing: 10) {
                    if presentation.storySummary.reviewScenes.isEmpty {
                        Label("Avi needs to prepare the story before the video can be created.", systemImage: "text.bubble.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AVBrandColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AVBrandColor.neutral100.opacity(0.68), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    } else {
                        ForEach(presentation.storySummary.reviewScenes) { scene in
                            MomentsCreateStoryReviewSceneRow(scene: scene)
                        }
                    }
                }

                HStack(spacing: 8) {
                    MomentsCreateOptionPill(title: "\(presentation.mediaSummary.reviewCount) items", systemImage: "photo.on.rectangle")
                    MomentsCreateOptionPill(title: "\(presentation.template.duration)", systemImage: "timer")
                }
            }
        }
    }

    private var sceneCountTitle: String {
        let count = presentation.storySummary.reviewScenes.count
        return "\(count) \(count == 1 ? "scene" : "scenes")"
    }
}

private struct MomentsCreateRenderPlanSummary: View {
    let plan: MomentsRenderPlan?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan == nil ? "Video plan" : "Prepared video plan")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(AVBrandColor.textPrimary)

            HStack(spacing: 8) {
                MomentsCreateOptionPill(title: assetUsageTitle, systemImage: "photo.stack")
                MomentsCreateOptionPill(title: durationTitle, systemImage: "timer")
                MomentsCreateOptionPill(title: renderModeTitle, systemImage: "wand.and.stars")
            }

            Text(message)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AVBrandColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            ForEach((plan?.qualityWarnings ?? []).prefix(2), id: \.self) { warning in
                Label(warning, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(AVBrandColor.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var assetUsageTitle: String {
        guard let plan else { return "Needs plan" }
        if plan.rejectedAssetCount > 0 {
            return "\(plan.usedAssetCount) used · \(plan.rejectedAssetCount) skipped"
        }
        return "\(plan.usedAssetCount) of \(plan.plannedAssetCount) items"
    }

    private var durationTitle: String {
        guard let plan else { return "Before video" }
        return "\(plan.targetDurationMs / 1000)s"
    }

    private var renderModeTitle: String {
        guard let plan else { return "Mode pending" }
        return plan.rendererMode
            .split(separator: "_")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    private var message: String {
        plan?.userMessage ?? "Avi will prepare the media, duration, and quality checks before the video starts."
    }
}

private struct MomentsCreateReviewMetric: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(AVBrandColor.accent)
                .frame(width: 32, height: 32)
                .background(AVBrandColor.accent.opacity(0.10), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AVBrandColor.mutedSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct MomentsCreateStoryReviewPage: View {
    let presentation: MomentsCreateWorkflowPresentation
    let createVideo: (Bool) -> Void
    let buyReviewBundle: () -> Void
    let openCredits: () -> Void
    let discardDraft: () -> Void
    let dismiss: () -> Void

    @State private var showsCreateVideoConfirmation = false
    @State private var showsDiscardDraftConfirmation = false
    @State private var removesWatermark = false

    var body: some View {
        VStack(spacing: 0) {
            MomentsCreateEditorPageHeader(
                title: "Story Review",
                dismiss: dismiss
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    AVAppShellCard {
                        HStack(alignment: .center, spacing: 14) {
                            ZStack(alignment: .bottomTrailing) {
                                Image("AviFullBody")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 74, height: 74)
                                    .padding(12)
                                    .background(AVBrandColor.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                                Image(systemName: "film.stack.fill")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                                    .background(AVBrandColor.accent, in: Circle())
                                    .offset(x: 8, y: 8)
                            }
                            .frame(width: 98, height: 98)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Review before creating")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(AVBrandColor.textPrimary)

                                Text(summaryTitle)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AVBrandColor.textSecondary)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)

                                HStack(spacing: 8) {
                                    MomentsCreateOptionPill(title: "\(presentation.mediaSummary.reviewCount) items", systemImage: "photo.on.rectangle")
                                    MomentsCreateOptionPill(title: "\(presentation.template.duration)", systemImage: "timer")
                                    MomentsCreateOptionPill(title: "\(totalCreditCostTitle)", systemImage: "creditcard.fill")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    MomentsCreateReviewMediaTimingCard(presentation: presentation)

                    MomentsCreateStoryDirectionCard(presentation: presentation)

                    MomentsCreateStoryReviewCard(presentation: presentation)

                    MomentsCreateStoryAllowanceActionCard(
                        presentation: presentation,
                        buyReviewBundle: buyReviewBundle,
                        openCredits: openCredits
                    )

                    MomentsCreateReadinessChecklistCard(presentation: presentation)

                    AVAppShellCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "video.fill")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(.white)
                                    .frame(width: 42, height: 42)
                                    .background(AVBrandColor.textPrimary, in: Circle())

                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Create the video")
                                        .font(.system(size: 17, weight: .black))
                                        .foregroundStyle(AVBrandColor.textPrimary)

                                    Text("Avi will edit your real media into a \(presentation.template.duration) video. You can go back if you want to change the story first.")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AVBrandColor.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            MomentsCreateRenderPlanSummary(plan: presentation.finalRenderSummary.renderPlan?.plan)

                            MomentsCreateFinalVideoOptionsCard(
                                balance: presentation.balance,
                                template: presentation.template,
                                removesWatermark: $removesWatermark
                            )

                            Button(action: primaryCreateAction) {
                                Label(primaryCreateTitle, systemImage: primaryCreateIconName)
                                    .font(.system(size: 15, weight: .black))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            .buttonStyle(MomentsCreateSoftActionButtonStyle())
                            .disabled(isPrimaryCreateDisabled)

                            HStack(spacing: 14) {
                                Button(action: { showsDiscardDraftConfirmation = true }) {
                                    Label("Discard Moment", systemImage: "trash.fill")
                                }
                                .buttonStyle(MomentsCreateDestructiveInlineButtonStyle())

                                Button(action: dismiss) {
                                    Label("Change media or style", systemImage: "slider.horizontal.3")
                                }
                                    .buttonStyle(MomentsCreateNeutralInlineButtonStyle())
                            }
                            .font(.system(size: 13, weight: .bold))
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 172)
            }
            .scrollIndicators(.hidden)
        }
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert(MomentsL10n.string("create.final.confirmTitle"), isPresented: $showsCreateVideoConfirmation) {
            Button(MomentsL10n.string("create.action.notNow"), role: .cancel) {}
            Button(MomentsL10n.string("create.final.createWithCost", totalCreditCostTitle)) {
                dismiss()
                Task { @MainActor in
                    createVideo(removesWatermark)
                }
            }
        } message: {
            Text(MomentsL10n.string("create.final.confirmMessage", totalCreditCostTitle))
        }
        .alert(MomentsL10n.string("create.discard.confirmTitle"), isPresented: $showsDiscardDraftConfirmation) {
            Button(MomentsL10n.string("create.discard.keep"), role: .cancel) {}
            Button(discardConfirmationActionTitle, role: .destructive) {
                discardDraft()
            }
        } message: {
            Text(discardConfirmationMessage)
        }
    }

    private var summaryTitle: String {
        MomentsL10n.string("create.final.summaryTitle")
    }

    private var discardConfirmationActionTitle: String {
        presentation.hasUnsavedLocalMoment ? MomentsL10n.string("create.discard.local") : MomentsL10n.string("create.discard.current")
    }

    private var discardConfirmationMessage: String {
        if presentation.hasUnsavedLocalMoment {
            return MomentsL10n.string("create.discard.localMessage")
        }

        return MomentsL10n.string("create.discard.currentMessage")
    }

    private var creditCostTitle: String {
        MomentsCreditCopy.countTitle(presentation.finalRenderSummary.creditCost)
    }

    private var totalCreditCost: Int {
        MomentsCreditGate.finalRenderCreditCost(
            template: presentation.template,
            removesWatermark: removesWatermark,
            balance: presentation.balance
        )
    }

    private var totalCreditCostTitle: String {
        MomentsCreditCopy.countTitle(totalCreditCost)
    }

    private var mediaCountTitle: String {
        let count = presentation.mediaSummary.reviewCount
        return "\(count) \(count == 1 ? "item" : "items")"
    }

    private var hasRenderPlan: Bool {
        presentation.finalRenderSummary.renderPlan != nil
    }

    private var primaryCreateTitle: String {
        hasRenderPlan ? MomentsL10n.string("create.final.createWithCost", totalCreditCostTitle) : MomentsL10n.string("create.final.preparePlan")
    }

    private var primaryCreateIconName: String {
        hasRenderPlan ? "video.fill" : "checklist"
    }

    private var isPrimaryCreateDisabled: Bool {
        !presentation.canGenerateFinalRender
            || presentation.mediaSummary.reviewCount == 0
            || !presentation.storySummary.hasScenes
            || !MomentsCreditGate.canAffordFinalRender(
                template: presentation.template,
                removesWatermark: removesWatermark,
                balance: presentation.balance
            )
    }

    private func primaryCreateAction() {
        guard !isPrimaryCreateDisabled else { return }
        if hasRenderPlan {
            showsCreateVideoConfirmation = true
        } else {
            createVideo(removesWatermark)
        }
    }
}

private struct MomentsCreateStoryAllowanceActionCard: View {
    let presentation: MomentsCreateWorkflowPresentation
    let buyReviewBundle: () -> Void
    let openCredits: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Story review allowance")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                HStack(spacing: 10) {
                    MomentsCreateReviewMetric(
                        title: "\(presentation.balance.reviewAllowanceRemaining)",
                        subtitle: "reviews left",
                        systemImage: "list.bullet.clipboard.fill"
                    )
                    MomentsCreateReviewMetric(
                        title: "\(presentation.balance.reviewBundleReviewCount)",
                        subtitle: "per bundle",
                        systemImage: "plus.circle.fill"
                    )
                    MomentsCreateReviewMetric(
                        title: MomentsCreditCopy.countTitle(presentation.balance.reviewBundleCreditCost),
                        subtitle: "bundle cost",
                        systemImage: "creditcard.fill"
                    )
                }

                if presentation.balance.reviewAllowanceRemaining == 0 {
                    Text("You can add reviews with credits, add credits first, or create the final video from this approved story.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if presentation.balance.canBuyReviewBundle {
                        Button(action: buyReviewBundle) {
                            Label(reviewBundleButtonTitle, systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MomentsCreateSoftActionButtonStyle())
                        .disabled(presentation.isBuyingReviewBundle)
                    } else {
                        Button(action: openCredits) {
                            Label("Add credits", systemImage: "creditcard.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MomentsCreateSoftActionButtonStyle())
                    }
                }
            }
        }
    }

    private var reviewBundleButtonTitle: String {
        presentation.isBuyingReviewBundle
            ? "Adding reviews..."
            : "Add \(presentation.balance.reviewBundleReviewCount) reviews · \(MomentsCreditCopy.countTitle(presentation.balance.reviewBundleCreditCost))"
    }
}

private struct MomentsCreateStoryDirectionCard: View {
    let presentation: MomentsCreateWorkflowPresentation

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Story direction")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                HStack(spacing: 10) {
                    MomentsCreateReviewMetric(
                        title: presentation.creationStyleTitle,
                        subtitle: "Theme",
                        systemImage: "sparkles"
                    )
                    MomentsCreateReviewMetric(
                        title: presentation.tempoTitle,
                        subtitle: "Pacing",
                        systemImage: "metronome.fill"
                    )
                }

                HStack(spacing: 10) {
                    MomentsCreateReviewMetric(
                        title: presentation.toneTitle,
                        subtitle: "Tone",
                        systemImage: "text.bubble.fill"
                    )
                    MomentsCreateReviewMetric(
                        title: presentation.occasionTitle,
                        subtitle: "Moment",
                        systemImage: "rectangle.stack.fill"
                    )
                }
            }
        }
    }
}

private struct MomentsCreateReadinessChecklistCard: View {
    let presentation: MomentsCreateWorkflowPresentation

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Ready check")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                VStack(spacing: 8) {
                    MomentsCreateReadinessRow(
                        title: "Media selected",
                        detail: mediaDetail,
                        isReady: presentation.mediaSummary.reviewCount > 0
                    )
                    MomentsCreateReadinessRow(
                        title: "Story prepared",
                        detail: storyDetail,
                        isReady: presentation.storySummary.hasScenes
                    )
                    MomentsCreateReadinessRow(
                        title: "Video plan",
                        detail: planDetail,
                        isReady: presentation.finalRenderSummary.renderPlan != nil
                    )
                    MomentsCreateReadinessRow(
                        title: "Credits",
                        detail: "\(MomentsCreditCopy.countTitle(presentation.finalRenderSummary.creditCost)) reserved when video starts",
                        isReady: presentation.finalRenderSummary.creditCost > 0
                    )
                }
            }
        }
    }

    private var mediaDetail: String {
        let count = presentation.mediaSummary.reviewCount
        return count > 0 ? "\(count) \(count == 1 ? "item" : "items") ready" : "Add media first"
    }

    private var storyDetail: String {
        let count = presentation.storySummary.reviewScenes.count
        return count > 0 ? "\(count) \(count == 1 ? "scene" : "scenes") ready" : "Prepare the story first"
    }

    private var planDetail: String {
        guard let plan = presentation.finalRenderSummary.renderPlan?.plan else {
            return "Prepared before video creation"
        }
        let seconds = plan.targetDurationMs / 1000
        return "\(seconds)s · \(plan.usedAssetCount) media items"
    }
}

private struct MomentsCreateFinalVideoOptionsCard: View {
    let balance: MomentsCreditBalance
    let template: MomentTemplate
    @Binding var removesWatermark: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                MomentsCreateReviewMetric(
                    title: reviewAllowanceTitle,
                    subtitle: "Story reviews",
                    systemImage: "list.bullet.clipboard.fill"
                )
                MomentsCreateReviewMetric(
                    title: totalCostTitle,
                    subtitle: watermarkSubtitle,
                    systemImage: "creditcard.fill"
                )
            }

            Toggle(isOn: $removesWatermark) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Remove Moments AV mark")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)
                    Text(watermarkDetail)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .toggleStyle(.switch)
            .disabled(balance.watermarkFreeIncluded)

            if !canAffordSelectedCost {
                Label("Add \(MomentsCreditCopy.countTitle(missingCredits)) to create this version.", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(AVBrandColor.neutral100.opacity(0.70), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var reviewAllowanceTitle: String {
        "\(balance.reviewAllowanceRemaining) left"
    }

    private var totalCost: Int {
        MomentsCreditGate.finalRenderCreditCost(
            template: template,
            removesWatermark: removesWatermark,
            balance: balance
        )
    }

    private var totalCostTitle: String {
        MomentsCreditCopy.countTitle(totalCost)
    }

    private var watermarkSubtitle: String {
        if balance.watermarkFreeIncluded {
            return "No mark with Pro"
        }
        return removesWatermark ? "No mark selected" : "Includes mark"
    }

    private var watermarkDetail: String {
        if balance.watermarkFreeIncluded {
            return "Included with Pro."
        }
        return "Optional clean export for \(MomentsCreditCopy.countTitle(balance.watermarkRemovalCreditCost))."
    }

    private var canAffordSelectedCost: Bool {
        balance.spendable >= totalCost
    }

    private var missingCredits: Int {
        max(0, totalCost - balance.spendable)
    }
}

private struct MomentsCreateReadinessRow: View {
    let title: String
    let detail: String
    let isReady: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isReady ? "checkmark.circle.fill" : "circle.dashed")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(isReady ? AVBrandColor.accent : AVBrandColor.textSecondary.opacity(0.6))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                Text(detail)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(AVBrandColor.neutral100.opacity(0.66), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct MomentsCreateReviewMediaTimingCard: View {
    let presentation: MomentsCreateWorkflowPresentation

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Media and timing")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                HStack(spacing: 10) {
                    MomentsCreateReviewMetric(
                        title: mediaCountTitle,
                        subtitle: mediaSubtitle,
                        systemImage: "photo.stack.fill"
                    )
                    MomentsCreateReviewMetric(
                        title: presentation.template.duration,
                        subtitle: "\(creditCostTitle) final video",
                        systemImage: "timer"
                    )
                }

                if presentation.mediaSummary.reviewCount == 0 {
                    Label("Avi needs the media before creating the video.", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    MomentsCreateReviewMediaStrip(mediaSummary: presentation.mediaSummary)

                    Text("Avi will use these selected items, story direction, and timing for the final edit.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var mediaCountTitle: String {
        let count = presentation.mediaSummary.reviewCount
        return "\(count) \(count == 1 ? "item" : "items")"
    }

    private var mediaSubtitle: String {
        presentation.mediaSummary.reviewCount > 0 ? "Selected for this video" : "Not ready"
    }

    private var creditCostTitle: String {
        MomentsCreditCopy.countTitle(presentation.finalRenderSummary.creditCost)
    }
}

private struct MomentsCreateReviewMediaStrip: View {
    let mediaSummary: MomentsCreateMediaSummary

    var body: some View {
        MomentsSharedMediaStrip(
            localMedia: mediaSummary.selectedMedia,
            syncedMedia: mediaSummary.syncedMediaAssets,
            maxCount: 12,
            tileSize: 58
        )
    }
}

private struct MomentsCreateStoryReviewSceneRow: View {
    let scene: MomentsCreateStoryReviewScene

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(AVBrandColor.accent)
                .frame(width: 26, height: 26)
                .background(AVBrandColor.accent.opacity(0.10), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(scene.title)
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                Text(scene.caption)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(2)

                if let detail = scene.detail, !detail.isEmpty {
                    Text(detail)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(AVBrandColor.textSecondary.opacity(0.78))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(AVBrandColor.neutral100.opacity(0.68), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
        if let realtimeStatus = presentation.finalRenderSummary.realtimeStatus {
            return realtimeStatus.title
        }
        if presentation.previewSummary.latestPreview != nil {
            return "Story review ready"
        }
        if presentation.previewSummary.isGenerating {
            return "Reviewing story"
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
            return "Review the story. If it feels right, Avi can create the final video."
        }
        if presentation.previewSummary.isGenerating {
            return presentation.previewSummary.statusMessage ?? "Avi is reviewing the story from your selected moments."
        }
        if presentation.storySummary.isDrafting {
            return presentation.storySummary.statusMessage ?? "Avi is organizing the media into a first story plan."
        }
        if let realtimeStatus = presentation.finalRenderSummary.realtimeStatus {
            return realtimeStatus.detail
        }
        if presentation.previewSummary.latestPreviewJob != nil {
            return "Avi is reviewing the story from your selected moments."
        }
        if presentation.canGeneratePreview {
            return "Avi prepared the story, style, and pacing. Video creation comes next."
        }
        if presentation.mediaSummary.selectedCount > 0 || !presentation.mediaSummary.syncedMediaAssets.isEmpty {
            return "Avi will organize the story and you can fine tune the selection."
        }
        return "Add photos or clips. Avi will shape the story, mood, and pacing."
    }
}

private struct MomentsCreatePrimaryActionBar: View {
    let presentation: MomentsCreateWorkflowPresentation
    let discardDraft: () -> Void
    let startSignInFlow: () -> Void
    let reviewStoryFirst: () -> Void
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void
    let retryFinalVideoDownload: () -> Void
    let finishFinalVideoToGallery: () -> Void
    let createAnotherFinalVideoVersion: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: primaryHeaderIconName)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(primaryHeaderColor, in: Circle())

                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary)

                        if let statusMessage {
                            Text(statusMessage)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(statusColor)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let uploadProgress = presentation.mediaSummary.importProgress,
                   presentation.mediaSummary.isImporting {
                    ProgressView(value: uploadProgress.fractionCompleted ?? 0)
                        .tint(AVBrandColor.accent)
                        .accessibilityLabel("Uploading media")
                        .accessibilityValue(uploadProgress.title)
                }

                if let realtimeStatus = presentation.finalRenderSummary.realtimeStatus {
                    MomentsCreateRealtimeRenderStatusPanel(status: realtimeStatus)
                }

                Button(action: primaryAction) {
                    Label(buttonTitle, systemImage: buttonIconName)
                        .font(.system(size: 15, weight: .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .disabled(!canRunPrimaryAction)
                .buttonStyle(MomentsCreateSoftActionButtonStyle())
                .opacity(canRunPrimaryAction ? 1 : 0.55)

                if presentation.finalRenderSummary.pendingGalleryVideo != nil {
                    VStack(spacing: 10) {
                        Button(action: finishFinalVideoToGallery) {
                            Label(MomentsL10n.string("create.final.finishGallery"), systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MomentsCreateSoftActionButtonStyle())

                        Button(action: createAnotherFinalVideoVersion) {
                            Label(MomentsL10n.string("create.final.createAnother"), systemImage: "plus.rectangle.on.rectangle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MomentsCreateNeutralInlineButtonStyle())
                    }
                    .font(.system(size: 14, weight: .black))
                } else if presentation.finalRenderSummary.canRetryFinalVideoDownload {
                    Button(action: retryFinalVideoDownload) {
                        Label("Retry final video download", systemImage: "arrow.down.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(MomentsCreateSoftActionButtonStyle())
                    .font(.system(size: 14, weight: .black))
                }

                HStack(spacing: 14) {
                    Button(action: discardDraft) {
                        Label(discardTitle, systemImage: "trash.fill")
                    }
                    .buttonStyle(MomentsCreateDestructiveInlineButtonStyle())

                    if let secondaryActionTitle {
                        Button(action: secondaryAction) {
                            Label(secondaryActionTitle, systemImage: secondaryActionIconName)
                        }
                            .buttonStyle(MomentsCreateNeutralInlineButtonStyle())
                    }
                }
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var canRunPrimaryAction: Bool {
        if isBusy {
            return false
        }
        if presentation.finalRenderSummary.pendingGalleryVideo != nil {
            return false
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            return canRefreshFinalRender
        }
        return presentation.canGenerateFinalRender
            || presentation.canDraftStory
            || presentation.storySummary.hasScenes
            || needsSignInForStory
    }

    private var discardTitle: String {
        presentation.hasUnsavedLocalMoment ? MomentsL10n.string("create.discard.local") : MomentsL10n.string("create.discard.current")
    }

    private var buttonTitle: String {
        if presentation.finalRenderSummary.pendingGalleryVideo != nil {
            return MomentsL10n.string("create.final.chooseDestination")
        }
        if presentation.finalRenderSummary.finalExport != nil {
            return MomentsL10n.string("create.final.videoReady")
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            return presentation.finalRenderSummary.isRefreshingStatus ? MomentsL10n.string("create.status.checking") : MomentsL10n.string("create.final.checkStatus")
        }
        if presentation.canGenerateFinalRender {
            return MomentsL10n.string("create.preview.view")
        }
        if presentation.previewSummary.latestPreview != nil {
            return presentation.finalRenderSummary.isGenerating ? MomentsL10n.string("create.final.creating") : MomentsL10n.string("create.final.create")
        }
        if presentation.previewSummary.latestPreviewJob != nil {
            return presentation.previewSummary.isRefreshingStatus ? MomentsL10n.string("create.status.refreshing") : MomentsL10n.string("create.preview.refresh")
        }
        if needsSignInForStory {
            return MomentsL10n.string("common.signIn")
        }
        return presentation.finalRenderSummary.isGenerating ? MomentsL10n.string("create.preview.preparing") : MomentsL10n.string("create.preview.reviewFirst")
    }

    private var buttonIconName: String {
        if presentation.finalRenderSummary.pendingGalleryVideo != nil {
            return "rectangle.stack.badge.play.fill"
        }
        if presentation.finalRenderSummary.finalExport != nil {
            return "checkmark.circle.fill"
        }
        if presentation.previewSummary.latestPreview != nil {
            return "wand.and.stars"
        }
        if presentation.previewSummary.latestPreviewJob != nil {
            return "arrow.clockwise"
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            return "arrow.clockwise"
        }
        if presentation.canGenerateFinalRender {
            return "list.bullet.rectangle.portrait.fill"
        }
        if needsSignInForStory {
            return "person.crop.circle.badge.checkmark"
        }
        return "play.rectangle.fill"
    }

    private var availabilityMessage: String? {
        if presentation.finalRenderSummary.finalExport != nil {
            return nil
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            return presentation.finalRenderRefreshAvailabilityMessage ?? presentation.finalRenderAvailabilityMessage
        }
        if presentation.previewSummary.latestPreview != nil || presentation.canGenerateFinalRender {
            return presentation.finalRenderAvailabilityMessage
        }
        if presentation.previewSummary.latestPreviewJob != nil {
            return presentation.previewAvailabilityMessage
        }
        return presentation.finalRenderAvailabilityMessage ?? presentation.storyAvailabilityMessage
    }

    private var statusMessage: String? {
        if presentation.finalRenderSummary.pendingGalleryVideo != nil {
            return presentation.finalRenderSummary.statusMessage
                ?? "Final video is saved on this device. Finish it into Gallery or create another version."
        }
        if presentation.finalRenderSummary.isGenerating {
            return presentation.finalRenderSummary.statusMessage ?? "Creating video..."
        }
        if presentation.previewSummary.isGenerating {
            return presentation.previewSummary.statusMessage ?? "Reviewing story..."
        }
        if presentation.storySummary.isDrafting {
            return presentation.storySummary.statusMessage ?? "Preparing story..."
        }
        if presentation.finalRenderSummary.finalExport != nil {
            return "Final video ready."
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            return presentation.finalRenderSummary.realtimeStatus?.detail
                ?? presentation.finalRenderSummary.statusMessage
                ?? "Avi is creating the video. You can check progress here."
        }
        if presentation.previewSummary.latestPreview != nil {
            return "Story review ready. Check it before final video."
        }
        if presentation.canGenerateFinalRender {
            return "Review the story and video plan before creating the final video."
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
        if needsSignInForStory {
            return presentation.storyAvailabilityMessage
        }
        if presentation.canDraftStory {
            return "Avi can prepare the story review now."
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

    private var primaryHeaderIconName: String {
        if presentation.finalRenderSummary.pendingGalleryVideo != nil {
            return "rectangle.stack.badge.play.fill"
        }
        if presentation.finalRenderSummary.finalExport != nil {
            return "checkmark.circle.fill"
        }
        if let realtimeStatus = presentation.finalRenderSummary.realtimeStatus {
            return realtimeStatus.systemImage
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            return "arrow.clockwise"
        }
        if needsSignInForStory {
            return "person.crop.circle.badge.checkmark"
        }
        return "video.fill"
    }

    private var primaryHeaderColor: Color {
        if presentation.finalRenderSummary.pendingGalleryVideo != nil {
            return AVBrandColor.accent
        }
        if presentation.finalRenderSummary.finalExport != nil {
            return AVBrandColor.accent
        }
        if presentation.finalRenderSummary.latestFinalJob != nil || isBusy {
            return AVBrandColor.textSecondary
        }
        return AVBrandColor.textPrimary
    }

    private var isBusy: Bool {
        presentation.storySummary.isDrafting
            || presentation.mediaSummary.isImporting
            || presentation.previewSummary.isGenerating
            || presentation.previewSummary.isRefreshingStatus
            || presentation.finalRenderSummary.isGenerating
            || presentation.finalRenderSummary.isRefreshingStatus
    }

    private var secondaryActionTitle: String? {
        guard !isBusy else { return nil }
        return nil
    }

    private var secondaryActionIconName: String {
        presentation.storySummary.hasScenes ? "list.bullet.rectangle.portrait.fill" : "sparkles"
    }

    private func primaryAction() {
        if presentation.finalRenderSummary.pendingGalleryVideo != nil {
            return
        }
        if presentation.finalRenderSummary.finalExport != nil {
            return
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            if canRefreshFinalRender {
                refreshFinalRenderStatus()
            }
        } else if presentation.previewSummary.latestPreview != nil {
            reviewStoryFirst()
        } else if presentation.canGenerateFinalRender || presentation.canDraftStory || presentation.storySummary.hasScenes {
            reviewStoryFirst()
        } else if presentation.previewSummary.latestPreviewJob != nil {
            refreshPreviewStatus()
        } else if needsSignInForStory {
            startSignInFlow()
        }
    }

    private func secondaryAction() {
        reviewStoryFirst()
    }

    private var title: String {
        if presentation.finalRenderSummary.finalExport != nil || presentation.finalRenderSummary.latestFinalJob != nil {
            return MomentsL10n.string("create.final.video")
        }
        return MomentsL10n.string("project.nextAction.createVideo.title")
    }

    private var creditCostTitle: String {
        MomentsCreditCopy.countTitle(presentation.finalRenderSummary.creditCost)
    }

    private var needsSignInForStory: Bool {
        !presentation.isSignedIn
            && presentation.mediaSummary.selectedCount > 0
            && !presentation.storySummary.isDrafting
    }

    private var canRefreshFinalRender: Bool {
        presentation.finalRenderSummary.latestFinalJob != nil
            && presentation.canRefreshFinalRenderStatus
    }
}

private struct MomentsCreateRealtimeRenderStatusPanel: View {
    let status: MomentsRenderRealtimePresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top, spacing: 9) {
                Image(systemName: status.systemImage)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(iconColor)
                    .frame(width: 24, height: 24)
                    .background(iconColor.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(status.title)
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(status.detail)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let progressFraction = status.progressFraction {
                ProgressView(value: progressFraction)
                    .tint(iconColor)
                    .accessibilityLabel("Final video progress")
                    .accessibilityValue("\(Int((progressFraction * 100).rounded())) percent")
            }

            if status.isActive && !status.canEditDraft {
                Label("Editing is locked while the final video is being created.", systemImage: "lock.fill")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AVBrandColor.neutral100.opacity(0.70), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var iconColor: Color {
        status.isActive ? AVBrandColor.accent : AVBrandColor.textSecondary
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
            return "Story review"
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
            return "Check the story review. If it feels right, create the final video."
        }
        if presentation.finalRenderSummary.latestFinalJob != nil {
            return "Avi is finishing the final video. You can refresh when needed."
        }
        if presentation.previewSummary.latestPreviewJob != nil {
            return "Avi is reviewing the story from your selected moments."
        }
        if presentation.canGeneratePreview {
            return "The story plan is ready. Next step: create the video."
        }
        if presentation.mediaSummary.selectedCount > 0 || !presentation.mediaSummary.syncedMediaAssets.isEmpty {
            return "Avi will shape these moments into a simple story plan."
        }
        return "Pick the moments. Avi will shape the story, mood, and pacing."
    }
}

private struct MomentsCreateAviOptionsSheet: View {
    @Binding var form: MomentDraftForm
    let selectedStyle: MomentCreationStyle
    let autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    let canUndoAutoStyleSuggestion: Bool
    let styles: [MomentCreationStyle]
    let selectedMusicPreset: MomentMusicPreset
    let selectStyle: (MomentCreationStyle) -> Void
    let selectMusicPreset: (MomentMusicPreset) -> Void
    let useAutoStyleSuggestion: () -> Void
    let undoAutoStyleSuggestion: () -> Void
    let autoPickStrongMoments: () -> Void
    let dismiss: () -> Void

    @State private var showsThemeChooser = false
    @State private var showsLookChooser = false
    @State private var showsLengthChooser = false
    @State private var showsMoodChooser = false

    var body: some View {
        VStack(spacing: 0) {
            MomentsCreateEditorPageHeader(
                title: MomentsL10n.string("create.guide.title"),
                dismiss: dismiss
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    MomentsCreateOptionsAviPanel(
                        selectedStyle: selectedStyle,
                        selectedMusicPreset: selectedMusicPreset,
                        autoStyleSuggestion: autoStyleSuggestion,
                        canUndoAutoStyleSuggestion: canUndoAutoStyleSuggestion,
                        useAutoStyleSuggestion: useAutoStyleSuggestion,
                        undoAutoStyleSuggestion: undoAutoStyleSuggestion
                    )

                    MomentsCreateGuideSummaryCard(
                        form: $form,
                        style: selectedStyle,
                        selectedMusicPreset: selectedMusicPreset,
                        changeTheme: { showsThemeChooser = true },
                        changeLook: { showsLookChooser = true },
                        changeLength: { showsLengthChooser = true },
                        changeMood: { showsMoodChooser = true },
                        selectMusicPreset: selectMusicPreset
                    )

                    MomentsCreateAviNoteField(text: $form.details)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 172)
            }
            .scrollIndicators(.hidden)
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
        .navigationDestination(isPresented: $showsLookChooser) {
            MomentsCreateLookChooserPage(
                selectedLook: form.look,
                selectLook: {
                    form.look = $0
                    showsLookChooser = false
                },
                dismiss: { showsLookChooser = false }
            )
            .id(form.look.rawValue)
        }
        .navigationDestination(isPresented: $showsLengthChooser) {
            MomentsCreateLengthChooserPage(
                selectedDuration: form.duration,
                selectDuration: {
                    form.duration = $0
                    showsLengthChooser = false
                },
                dismiss: { showsLengthChooser = false }
            )
            .id(form.duration.rawValue)
        }
        .navigationDestination(isPresented: $showsMoodChooser) {
            MomentsCreateMoodChooserPage(
                allowedMusic: selectedStyle.allowedMusic,
                selectedMusicPreset: selectedMusicPreset,
                selectMusicPreset: {
                    selectMusicPreset($0)
                    showsMoodChooser = false
                },
                dismiss: { showsMoodChooser = false }
            )
            .id(selectedMusicPreset.rawValue)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MomentsCreateGuideSummaryCard: View {
    @Binding var form: MomentDraftForm
    let style: MomentCreationStyle
    let selectedMusicPreset: MomentMusicPreset
    let changeTheme: () -> Void
    let changeLook: () -> Void
    let changeLength: () -> Void
    let changeMood: () -> Void
    let selectMusicPreset: (MomentMusicPreset) -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(MomentsL10n.string("create.guide.videoSetup.title"))
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                VStack(spacing: 0) {
                    MomentsCreateEditableOptionRow(
                        title: MomentsL10n.string("create.guide.theme.title"),
                        value: style.title,
                        detail: style.subtitle,
                        systemImage: "paintpalette.fill",
                        action: changeTheme
                    )

                    MomentsCreateOptionDivider()

                    MomentsCreateEditableOptionRow(
                        title: MomentsL10n.string("create.guide.look.title"),
                        value: form.look.title,
                        detail: form.look.subtitle,
                        systemImage: form.look.systemImage,
                        action: changeLook
                    )

                    MomentsCreateOptionDivider()

                    MomentsCreateEditableOptionRow(
                        title: MomentsL10n.string("create.guide.length.title"),
                        value: form.duration.title,
                        detail: lengthDetail,
                        systemImage: "timer",
                        action: changeLength
                    )

                    MomentsCreateOptionDivider()

                    MomentsCreateEditableOptionRow(
                        title: MomentsL10n.string("create.guide.mood.title"),
                        value: selectedMusicPreset.title,
                        detail: MomentsL10n.string("create.guide.mood.detail"),
                        systemImage: "sparkles",
                        action: changeMood
                    )
                }
            }
        }
    }

    private var lengthDetail: String {
        switch form.duration {
        case .auto:
            return MomentsL10n.string("create.guide.length.auto.detail")
        case .short:
            return MomentsL10n.string("create.guide.length.short.detail")
        case .standard:
            return MomentsL10n.string("create.guide.length.standard.detail")
        case .extended:
            return MomentsL10n.string("create.guide.length.extended.detail")
        }
    }
}

private struct MomentsCreateEditableOptionRow: View {
    let title: String
    let value: String
    let detail: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                MomentsCreateGuideFieldIcon(systemImage: systemImage)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(AVBrandColor.textSecondary)

                    Text(value)
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)
                        .lineLimit(1)

                    Text(detail)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .lineLimit(2)
                }
                .layoutPriority(1)

                Spacer(minLength: 8)

                MomentsCreateOptionActionText()
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(RoundedRectangle(cornerRadius: AVBrandRadius.xs, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct MomentsCreateOptionActionText: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .font(.system(size: 13, weight: .black))
            .foregroundStyle(AVBrandColor.accent)
            .frame(width: 32, height: 32)
            .background(AVBrandColor.accent.opacity(0.08), in: Circle())
    }
}

private struct MomentsCreateOptionDivider: View {
    var body: some View {
        Rectangle()
            .fill(AVBrandColor.borderSubtle.opacity(0.42))
            .frame(height: 1)
            .padding(.leading, 42)
    }
}

private struct MomentsCreateOptionsAviPanel: View {
    let selectedStyle: MomentCreationStyle
    let selectedMusicPreset: MomentMusicPreset
    let autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    let canUndoAutoStyleSuggestion: Bool
    let useAutoStyleSuggestion: () -> Void
    let undoAutoStyleSuggestion: () -> Void

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
                    Text(MomentsL10n.string("create.aviDirection.title"))
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(message)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    if autoStyleSuggestion != nil {
                        HStack(spacing: 8) {
                            if canUndoAutoStyleSuggestion {
                                MomentsCreateAviSuggestionButton(
                                    title: MomentsL10n.string("create.aviDirection.undoSuggestion"),
                                    systemImage: "arrow.uturn.backward",
                                    action: undoAutoStyleSuggestion
                                )
                            } else if showsUseAviSuggestion {
                                MomentsCreateAviSuggestionButton(
                                    title: MomentsL10n.string("create.aviDirection.useSuggestion"),
                                    systemImage: "sparkles",
                                    action: useAutoStyleSuggestion
                                )
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var message: String {
        guard let autoStyleSuggestion else {
            return MomentsL10n.string("create.aviDirection.defaultMessage")
        }

        if isUsingAviSuggestion {
            return MomentsL10n.string("create.aviDirection.usingSuggestion", selectedStyle.title.lowercased())
        }

        if isUsingAviDirection {
            return MomentsL10n.string("create.aviDirection.changedMusic", selectedStyle.title.lowercased())
        }

        let suggestedTitle = suggestedStyleTitle(for: autoStyleSuggestion.styleID)
        return MomentsL10n.string("create.aviDirection.changedDirection", selectedStyle.title.lowercased(), suggestedTitle.lowercased())
    }

    private var isUsingAviSuggestion: Bool {
        guard let autoStyleSuggestion else { return false }
        return selectedStyle.id == autoStyleSuggestion.styleID
            && selectedMusicPreset == autoStyleSuggestion.musicPreset
    }

    private var isUsingAviDirection: Bool {
        guard let autoStyleSuggestion else { return false }
        return selectedStyle.id == autoStyleSuggestion.styleID
    }

    private var showsUseAviSuggestion: Bool {
        autoStyleSuggestion != nil && !isUsingAviSuggestion
    }

    private func suggestedStyleTitle(for id: MomentCreationStyleID) -> String {
        switch id {
        case .celebration: MomentsL10n.string("create.theme.celebration.title")
        case .eventRecap: MomentsL10n.string("create.theme.eventRecap.title")
        case .travel: MomentsL10n.string("create.theme.travel.title")
        case .favoritePeople: MomentsL10n.string("create.theme.favoritePeople.title")
        case .birthday: MomentsL10n.string("create.theme.birthday.title")
        case .familyMoments: MomentsL10n.string("create.theme.familyMoments.title")
        case .softRoast: MomentsL10n.string("create.theme.softRoast.title")
        case .milestone: MomentsL10n.string("create.theme.milestone.title")
        }
    }
}

private struct MomentsCreateAviSuggestionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(AVBrandColor.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(AVBrandColor.accent.opacity(0.09), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct MomentsCreateAviNoteField: View {
    @Binding var text: String

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(MomentsL10n.string("create.note.title"))
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 10) {
                        MomentsCreateGuideFieldIcon(systemImage: "text.bubble.fill")

                        VStack(alignment: .leading, spacing: 2) {
                            Text(MomentsL10n.string("create.note.field.title"))
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(AVBrandColor.textSecondary)
                                .textCase(.uppercase)

                            Text(MomentsL10n.string("create.note.field.subtitle"))
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
                        .accessibilityLabel(MomentsL10n.string("create.note.voice.accessibility"))
                    }

                    TextField(MomentsL10n.string("create.note.placeholder"), text: $text, axis: .vertical)
                        .font(AVBrandTypography.body)
                        .foregroundStyle(AVBrandColor.textPrimary)
                        .lineLimit(2...4)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.done)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MomentsCreateGuideFieldBackground())
            }
        }
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

private struct MomentsCreateTwoColumnGrid<Item: Identifiable, Content: View>: View {
    let items: [Item]
    var horizontalSpacing: CGFloat = 12
    var verticalSpacing: CGFloat = 12
    var itemHeight: CGFloat = 106
    let content: (Item) -> Content

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: verticalSpacing) {
            ForEach(items) { item in
                content(item)
                    .frame(width: itemWidth, height: itemHeight)
                    .clipped()
            }
        }
        .frame(width: gridWidth, alignment: .center)
        .frame(maxWidth: .infinity)
    }

    private var gridWidth: CGFloat {
        max(280, UIScreen.main.bounds.width - 40)
    }

    private var itemWidth: CGFloat {
        floor((gridWidth - horizontalSpacing) / 2)
    }

    private var columns: [GridItem] {
        [
            GridItem(.fixed(itemWidth), spacing: horizontalSpacing, alignment: .top),
            GridItem(.fixed(itemWidth), spacing: 0, alignment: .top)
        ]
    }
}

private struct MomentsCreateLookChooserPage: View {
    let selectedLook: MomentLook
    let selectLook: (MomentLook) -> Void
    let dismiss: () -> Void

    @State private var draftLook: MomentLook

    init(
        selectedLook: MomentLook,
        selectLook: @escaping (MomentLook) -> Void,
        dismiss: @escaping () -> Void
    ) {
        self.selectedLook = selectedLook
        self.selectLook = selectLook
        self.dismiss = dismiss
        _draftLook = State(initialValue: selectedLook)
    }

    var body: some View {
        VStack(spacing: 0) {
            MomentsCreateChooserHeader(
                title: MomentsL10n.string("create.selector.look.title"),
                dismiss: dismiss
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
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
                                Text(MomentsL10n.string("create.selector.look.intro.title"))
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(AVBrandColor.textPrimary)

                                Text(MomentsL10n.string("create.selector.look.intro.detail"))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AVBrandColor.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer(minLength: 0)
                        }
                    }

                    MomentsCreateTwoColumnGrid(items: MomentLook.selectorOrder) { look in
                            MomentsCreateLookImageTile(
                                look: look,
                                isSelected: draftLook == look,
                                selectLook: { applySelection(look) }
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .safeAreaPadding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
        }
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func applySelection(_ look: MomentLook) {
        draftLook = look
        selectLook(look)
        dismiss()
    }
}

private struct MomentsCreateLookImageTile: View {
    let look: MomentLook
    let isSelected: Bool
    let selectLook: () -> Void

    private let tileHeight: CGFloat = 106

    var body: some View {
        GeometryReader { proxy in
            Button(action: selectLook) {
                tileContent(width: proxy.size.width)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(MomentsL10n.string("create.selector.look.accessibility", look.title))
        }
        .frame(height: tileHeight)
    }

    private func tileContent(width: CGFloat) -> some View {
            ZStack(alignment: .bottomLeading) {
                Image(look.assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: tileHeight)
                    .clipped()

                LinearGradient(
                    colors: [.black.opacity(0.02), .black.opacity(0.28), .black.opacity(0.80)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white, AVBrandColor.accent)
                                .accessibilityHidden(true)
                        }

                        Text(look.title)
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }

                    Text(look.subtitle)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: width, height: tileHeight)
            .background(AVBrandColor.neutral100, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? AVBrandColor.accent : AVBrandColor.borderSubtle.opacity(0.7), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: AVBrandColor.ink.opacity(isSelected ? 0.12 : 0.05), radius: isSelected ? 8 : 4, x: 0, y: 3)
    }
}

private struct MomentsCreateLengthChooserPage: View {
    let selectedDuration: MomentDuration
    let selectDuration: (MomentDuration) -> Void
    let dismiss: () -> Void

    var body: some View {
        MomentsCreateVisualOptionChooserPage(
            title: MomentsL10n.string("create.selector.length.title"),
            introTitle: MomentsL10n.string("create.selector.length.intro.title"),
            introDetail: MomentsL10n.string("create.selector.length.intro.detail"),
            dismiss: dismiss
        ) {
            MomentsCreateTwoColumnGrid(items: MomentDuration.allCases) { duration in
                    MomentsCreateVisualOptionTile(
                        title: duration.title,
                        detail: detail(for: duration),
                        assetName: duration.assetName,
                        isSelected: selectedDuration == duration,
                        select: { selectDuration(duration) }
                    )
            }
        }
    }

    private func detail(for duration: MomentDuration) -> String {
        switch duration {
        case .auto:
            return MomentsL10n.string("create.selector.length.auto.detail")
        case .short:
            return MomentsL10n.string("create.selector.length.short.detail")
        case .standard:
            return MomentsL10n.string("create.selector.length.standard.detail")
        case .extended:
            return MomentsL10n.string("create.selector.length.extended.detail")
        }
    }
}

private struct MomentsCreateMoodChooserPage: View {
    let allowedMusic: [MomentMusicPreset]
    let selectedMusicPreset: MomentMusicPreset
    let selectMusicPreset: (MomentMusicPreset) -> Void
    let dismiss: () -> Void

    var body: some View {
        MomentsCreateVisualOptionChooserPage(
            title: MomentsL10n.string("create.selector.mood.title"),
            introTitle: MomentsL10n.string("create.selector.mood.intro.title"),
            introDetail: MomentsL10n.string("create.selector.mood.intro.detail"),
            dismiss: dismiss
        ) {
            MomentsCreateTwoColumnGrid(items: allowedMusic) { preset in
                    MomentsCreateVisualOptionTile(
                        title: preset.title,
                        detail: detail(for: preset),
                        assetName: preset.assetName,
                        isSelected: selectedMusicPreset == preset,
                        select: { selectMusicPreset(preset) }
                    )
            }
        }
    }

    private func detail(for preset: MomentMusicPreset) -> String {
        switch preset {
        case .warm:
            return MomentsL10n.string("create.selector.mood.warm.detail")
        case .fun:
            return MomentsL10n.string("create.selector.mood.fun.detail")
        case .cinematic:
            return MomentsL10n.string("create.selector.mood.cinematic.detail")
        case .calm:
            return MomentsL10n.string("create.selector.mood.calm.detail")
        case .upbeat:
            return MomentsL10n.string("create.selector.mood.upbeat.detail")
        }
    }
}

private struct MomentsCreateVisualOptionChooserPage<Content: View>: View {
    let title: String
    let introTitle: String
    let introDetail: String
    let dismiss: () -> Void
    let content: () -> Content

    init(
        title: String,
        introTitle: String,
        introDetail: String,
        dismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.introTitle = introTitle
        self.introDetail = introDetail
        self.dismiss = dismiss
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            MomentsCreateChooserHeader(title: title, dismiss: dismiss)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
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
                                Text(introTitle)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(AVBrandColor.textPrimary)

                                Text(introDetail)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AVBrandColor.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer(minLength: 0)
                        }
                    }

                    content()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .safeAreaPadding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
        }
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MomentsCreateVisualOptionTile: View {
    let title: String
    let detail: String
    let assetName: String
    let isSelected: Bool
    let select: () -> Void

    private let tileHeight: CGFloat = 106

    var body: some View {
        GeometryReader { proxy in
            Button(action: select) {
                tileContent(width: proxy.size.width)
            }
            .buttonStyle(.plain)
        }
        .frame(height: tileHeight)
    }

    private func tileContent(width: CGFloat) -> some View {
            ZStack(alignment: .bottomLeading) {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: tileHeight)
                    .clipped()

                LinearGradient(
                    colors: [.black.opacity(0.02), .black.opacity(0.28), .black.opacity(0.80)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white, AVBrandColor.accent)
                                .accessibilityHidden(true)
                        }

                        Text(title)
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }

                    Text(detail)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.84))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: width, height: tileHeight)
            .background(AVBrandColor.neutral100, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? AVBrandColor.accent : AVBrandColor.borderSubtle.opacity(0.7), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: AVBrandColor.ink.opacity(isSelected ? 0.12 : 0.05), radius: isSelected ? 8 : 4, x: 0, y: 3)
    }
}

private struct MomentsCreateThemeChooserPage: View {
    let styles: [MomentCreationStyle]
    let selectedStyle: MomentCreationStyle
    let selectStyle: (MomentCreationStyle) -> Void
    let dismiss: () -> Void

    @State private var draftStyleID: MomentCreationStyleID

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
        VStack(spacing: 0) {
            MomentsCreateThemeChooserHeader(
                dismiss: dismiss
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
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
                                Text(MomentsL10n.string("create.selector.theme.intro.title"))
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(AVBrandColor.textPrimary)

                                Text(MomentsL10n.string("create.selector.theme.intro.detail"))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AVBrandColor.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer(minLength: 0)
                        }
                    }

                    MomentsCreateTwoColumnGrid(items: styles) { style in
                            MomentsCreateThemeImageTile(
                                style: style,
                                isSelected: draftStyleID == style.id,
                                selectStyle: { applySelection(style) }
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .safeAreaPadding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
        }
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func applySelection(_ style: MomentCreationStyle) {
        draftStyleID = style.id
        selectStyle(style)
        dismiss()
    }
}

private struct MomentsCreateThemeChooserHeader: View {
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: dismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.92), in: Circle())
                    .shadow(color: AVBrandColor.ink.opacity(0.08), radius: 10, x: 0, y: 4)
                    .contentShape(Circle())
            }
            .accessibilityLabel(MomentsL10n.string("common.back"))

            Text(MomentsL10n.string("create.selector.theme.title"))
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(AVBrandColor.textPrimary)
                .frame(maxWidth: .infinity)

            Color.clear
                .frame(width: 44, height: 44)
        }
    }
}

private struct MomentsCreateChooserHeader: View {
    let title: String
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: dismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.92), in: Circle())
                    .shadow(color: AVBrandColor.ink.opacity(0.08), radius: 10, x: 0, y: 4)
                    .contentShape(Circle())
            }
            .accessibilityLabel(MomentsL10n.string("common.back"))

            Text(title)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(AVBrandColor.textPrimary)
                .frame(maxWidth: .infinity)

            Color.clear
                .frame(width: 44, height: 44)
        }
    }
}

private struct MomentsCreateThemeImageTile: View {
    let style: MomentCreationStyle
    let isSelected: Bool
    let selectStyle: () -> Void

    private let tileHeight: CGFloat = 106

    var body: some View {
        GeometryReader { proxy in
            Button(action: selectStyle) {
                tileContent(width: proxy.size.width)
            }
            .buttonStyle(.plain)
            .disabled(!style.isEnabled)
            .accessibilityLabel(accessibilityLabel)
        }
        .frame(height: tileHeight)
    }

    private var accessibilityLabel: String {
        if style.isEnabled {
            return MomentsL10n.string("create.selector.theme.accessibility", style.title)
        }
        return MomentsL10n.string("create.selector.theme.accessibilitySoon", style.title)
    }

    private func tileContent(width: CGFloat) -> some View {
            ZStack(alignment: .bottomLeading) {
                Image(style.assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: tileHeight)
                    .clipped()
                    .saturation(style.isEnabled ? 1 : 0.2)
                    .opacity(style.isEnabled ? 1 : 0.52)

                LinearGradient(
                    colors: [.black.opacity(0.02), .black.opacity(0.28), .black.opacity(0.80)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white, AVBrandColor.accent)
                                .accessibilityHidden(true)
                        }

                        Text(style.title)
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        if !style.isEnabled {
                            Text(MomentsL10n.string("common.soon"))
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
                .padding(.horizontal, 10)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: width, height: tileHeight)
            .background(AVBrandColor.neutral100, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? AVBrandColor.accent : AVBrandColor.borderSubtle.opacity(0.7), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: AVBrandColor.ink.opacity(isSelected ? 0.12 : 0.05), radius: isSelected ? 8 : 4, x: 0, y: 3)
    }
}

private struct MomentsCreateWorkflowCards: View {
    let presentation: MomentsCreateWorkflowPresentation
    @Binding var pickerItems: [PhotosPickerItem]
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let importLatestPhotos: () -> Void
    let importPhotoAlbum: (String) -> Void
    let removeMedia: (MomentsSelectedMedia) -> Void
    let moveMedia: (MomentsSelectedMedia, MomentsSelectedMedia) -> Void
    let reorderMedia: ([MomentsSelectedMedia]) -> Void
    let restoreLocalMediaForEditing: () -> Void
    let autoPickStrongMoments: () -> Void
    let openPickerRequest: Int
    let generateStoryDraft: () -> Void
    let buyReviewBundle: () -> Void = {}
    let openCredits: () -> Void = {}
    let generatePreview: () -> Void
    let refreshPreviewStatus: () -> Void
    let generateFinalRender: () -> Void
    let refreshFinalRenderStatus: () -> Void
    let retryFinalVideoDownload: () -> Void = {}
    let finishFinalVideoToGallery: () -> Void = {}
    let createAnotherFinalVideoVersion: () -> Void = {}

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
                    importPhotoAlbum: importPhotoAlbum,
                    removeMedia: removeMedia,
                    moveMedia: moveMedia,
                    reorderMedia: reorderMedia,
                    restoreLocalMediaForEditing: restoreLocalMediaForEditing,
                    autoPickStrongMoments: autoPickStrongMoments,
                    consumeOpenPickerRequest: {}
                )
                .id(MomentsCreateSection.media)

            case .story:
                MomentsCreateStoryCard(
                    presentation: MomentsCreateStoryPresentation(
                        summary: presentation.storySummary,
                        balance: presentation.balance,
                        canDraftStory: presentation.canDraftStory,
                        isBuyingReviewBundle: presentation.isBuyingReviewBundle,
                        availabilityMessage: presentation.storyAvailabilityMessage
                    ),
                    generateStoryDraft: generateStoryDraft,
                    buyReviewBundle: buyReviewBundle,
                    openCredits: openCredits
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
                    refreshFinalRenderStatus: refreshFinalRenderStatus,
                    retryFinalVideoDownload: retryFinalVideoDownload,
                    finishFinalVideoToGallery: finishFinalVideoToGallery,
                    createAnotherFinalVideoVersion: createAnotherFinalVideoVersion
                )
                .id(MomentsCreateSection.finalRender)
            }
        }
    }
}
