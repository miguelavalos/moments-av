import Combine
import Foundation

@MainActor
final class MomentsCreateViewModel: ObservableObject {
    @Published private(set) var isSignedIn = false
    @Published private(set) var balance = MomentsCreditBalance.empty
    @Published private(set) var templates = MomentTemplate.launchTemplates
    @Published private(set) var creationStyles = MomentCreationStyle.launchStyles
    @Published var newMomentStep: MomentsCreateNewMomentStep = .status
    @Published var selectedCreationStyle = MomentCreationStyle.launchStyles[0]
    @Published var selectedMusicPreset = MomentCreationStyle.launchStyles[0].defaultMusic
    @Published var form = MomentSetupForm(template: MomentTemplate.launchTemplates[0])
    @Published private(set) var isCreatingDraft = false
    @Published private(set) var isContinuingMoment = false
    @Published var isLocalMomentStarted = false
    @Published private(set) var workflowActiveMomentId: String?
    @Published private(set) var draftErrorMessage: String?
    @Published private(set) var selectedMedia: [MomentsSelectedMedia] = []
    @Published private(set) var mediaStatusMessage: String?
    @Published private(set) var isImportingMedia = false
    @Published private(set) var mediaImportProgress: MomentsMediaImportProgress?
    @Published private(set) var autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    @Published private(set) var canUndoAutoStyleSuggestion = false
    @Published private(set) var savedScenes: [MomentStoryScene] = []
    @Published private(set) var generatedScenes: [MomentsStoryDraftScene] = []
    @Published private(set) var storyStatusMessage: String?
    @Published private(set) var isDraftingStory = false
    @Published var isBuyingReviewBundle = false
    @Published var isPreparingStory = false
    @Published private(set) var activeWorkspace: MomentWorkspace?
    @Published private(set) var latestPreview: MomentArtifact?
    @Published private(set) var latestPreviewJob: MomentRenderJob?
    @Published private(set) var previewStatusMessage: String?
    @Published private(set) var isGeneratingPreview = false
    @Published private(set) var isRefreshingPreviewStatus = false
    @Published private(set) var finalExport: MomentArtifact?
    @Published private(set) var latestFinalJob: MomentRenderJob?
    @Published private(set) var renderPlan: MomentsRenderPlanResponse?
    @Published private(set) var pendingGalleryVideo: MomentsGalleryVideoRecord?
    @Published private(set) var canRetryFinalVideoDownload = false
    @Published private(set) var finalRenderStatusMessage: String?
    @Published private(set) var isGeneratingFinalRender = false
    @Published private(set) var isRefreshingFinalRenderStatus = false
    @Published var pendingFocus: MomentsContinuationFocus?
    @Published private(set) var continuationFocusHint: MomentsContinuationFocus?
    @Published var mediaPickerOpenRequest = 0

    private(set) var momentCreationWorkflow: MomentCreationWorkflow?
    private(set) var mediaUploadWorkflow: MediaUploadWorkflow?
    private(set) var storyDraftWorkflow: StoryDraftWorkflow?
    private(set) var previewGenerationWorkflow: PreviewGenerationWorkflow?
    private(set) var finalRenderWorkflow: FinalRenderWorkflow?
    let operationRunner = MomentsCreateOperationRunner()
    var cancellables = Set<AnyCancellable>()
    private var autoStyleMediaSignature: String?
    var lastPreparedStoryInputSignature: String?
    private var hasUserStyleOverride = false
    private var autoStyleUndoSelection: (style: MomentCreationStyle, musicPreset: MomentMusicPreset, form: MomentSetupForm)?
    var reviewBundlePurchaser: (any MomentsReviewBundlePurchasing)?

    var activeMoment: InProgressMoment? {
        if usesFullUITestFixture {
            return MomentsCreateUITestFixtures.moment
        }

        return activeWorkspace?.moment
    }

    var activeMomentId: String? {
        activeMoment?.id ?? workflowActiveMomentId
    }

    var hasMomentWorkspace: Bool {
        activeMomentId != nil || isLocalMomentStarted
    }

    var hasRecoverableMomentContext: Bool {
        activeMomentId != nil
            || !selectedMedia.isEmpty
            || isImportingMedia
            || isDraftingStory
            || !savedScenes.isEmpty
            || !generatedScenes.isEmpty
            || latestPreview != nil
            || latestPreviewJob != nil
            || finalExport != nil
            || latestFinalJob != nil
            || renderPlan != nil
    }

    var hasLocalMomentWorkspace: Bool {
        activeMomentId == nil && isLocalMomentStarted
    }

    var workflowErrorAlertMessage: String? {
        [
            draftErrorMessage,
            mediaStatusMessage,
            storyStatusMessage,
            previewStatusMessage,
            finalRenderStatusMessage
        ]
            .compactMap(\.self)
            .first(where: Self.isUserFacingErrorMessage)
    }

    func bind(
        accountStateProvider: any MomentsAccountStateProviding,
        momentCreationWorkflow: MomentCreationWorkflow,
        mediaUploadWorkflow: MediaUploadWorkflow,
        storyDraftWorkflow: StoryDraftWorkflow,
        previewGenerationWorkflow: PreviewGenerationWorkflow,
        finalRenderWorkflow: FinalRenderWorkflow
    ) {
        cancelOperations()
        reviewBundlePurchaser = accountStateProvider as? any MomentsReviewBundlePurchasing
        self.momentCreationWorkflow = momentCreationWorkflow
        self.mediaUploadWorkflow = mediaUploadWorkflow
        self.storyDraftWorkflow = storyDraftWorkflow
        self.previewGenerationWorkflow = previewGenerationWorkflow
        self.finalRenderWorkflow = finalRenderWorkflow
        templates = momentCreationWorkflow.launchTemplates
        creationStyles = MomentCreationStyle.launchStyles
        selectedCreationStyle = MomentCreationStyle.launchStyles[0]
        selectedMusicPreset = selectedCreationStyle.defaultMusic
        form = MomentSetupForm(template: momentCreationWorkflow.launchTemplates[0])
        canUndoAutoStyleSuggestion = false
        autoStyleUndoSelection = nil
        applyStyleDefaults(selectedCreationStyle)
        cancellables.removeAll()

        bindWorkflowState(
            accountStateProvider: accountStateProvider,
            momentCreationWorkflow: momentCreationWorkflow,
            mediaUploadWorkflow: mediaUploadWorkflow,
            storyDraftWorkflow: storyDraftWorkflow,
            previewGenerationWorkflow: previewGenerationWorkflow,
            finalRenderWorkflow: finalRenderWorkflow
        )
    }

    func selectTemplate(id: MomentTemplateID) {
        guard !isDraftLocked else { return }
        guard let template = templates.first(where: { $0.id == id }) else { return }
        form.template = template
    }

    func selectCreationStyle(_ style: MomentCreationStyle) {
        guard style.isEnabled else { return }
        guard canEditCreationOptions else { return }
        selectedCreationStyle = style
        selectedMusicPreset = style.defaultMusic
        hasUserStyleOverride = true
        canUndoAutoStyleSuggestion = false
        autoStyleUndoSelection = nil
        applyStyleDefaults(style)

        if newMomentStep == .style {
            beginNewProject()
        }
    }

    func selectMusicPreset(_ preset: MomentMusicPreset) {
        guard selectedCreationStyle.allowedMusic.contains(preset) else { return }
        hasUserStyleOverride = true
        canUndoAutoStyleSuggestion = false
        autoStyleUndoSelection = nil
        selectedMusicPreset = preset
        form.tone = MomentSetupTone(musicPreset: preset)
    }

    func useAutoStyleSuggestion() {
        guard canEditCreationOptions else { return }
        guard let suggestion = autoStyleSuggestion else { return }
        guard let suggestedStyle = creationStyles.first(where: { $0.id == suggestion.styleID && $0.isEnabled }) else { return }
        autoStyleUndoSelection = (selectedCreationStyle, selectedMusicPreset, form)
        selectedCreationStyle = suggestedStyle
        selectedMusicPreset = suggestion.musicPreset
        hasUserStyleOverride = false
        canUndoAutoStyleSuggestion = true
        applyStyleDefaults(suggestedStyle)
        form.tone = MomentSetupTone(musicPreset: suggestion.musicPreset)
    }

    func undoAutoStyleSuggestion() {
        guard canEditCreationOptions else { return }
        guard let previous = autoStyleUndoSelection else { return }
        selectedCreationStyle = previous.style
        selectedMusicPreset = previous.musicPreset
        form = previous.form
        hasUserStyleOverride = true
        canUndoAutoStyleSuggestion = false
        autoStyleUndoSelection = nil
    }

    func clearSessionState() {
        resetActiveMoment(force: true)
    }

    func prepareNewDraftCreation() {
        isContinuingMoment = false
        continuationFocusHint = nil
        isLocalMomentStarted = false
    }

    func continueMoment(_ moment: InProgressMoment, focus: MomentsContinuationFocus = .review) {
        cancelOperations()
        isContinuingMoment = true
        isLocalMomentStarted = false
        pendingFocus = focus
        continuationFocusHint = focus

        if let continuedForm = MomentSetupForm.continuing(moment: moment, templates: templates) {
            form = continuedForm
        }

        momentCreationWorkflow?.continueMoment(moment)
    }

    func consumePendingFocus() {
        pendingFocus = nil
    }

    func clearContinuationFocusHint() {
        continuationFocusHint = nil
    }

    func consumeMediaPickerOpenRequest() {
        mediaPickerOpenRequest = 0
    }

    func applyUITestFullWorkflowFixture() {
        guard MomentsUITestEnvironment.current.createFixture == "full" else { return }

        let workspace = MomentsCreateUITestFixtures.workspace
        let template = templates.first(where: { $0.id == workspace.moment.template }) ?? MomentTemplate.birthdayMessage
        form = MomentSetupForm(
            template: template,
            occasion: workspace.moment.occasion ?? "Birthday",
            recipient: "Ava",
            tone: MomentSetupTone(rawValue: workspace.moment.tone ?? "") ?? .warm,
            tempo: MomentSetupTempo(rawValue: workspace.moment.tempo ?? "") ?? .balanced,
            details: workspace.moment.details ?? ""
        )
        isSignedIn = true
        balance = MomentsCreateUITestFixtures.balance
        isContinuingMoment = true
        workflowActiveMomentId = workspace.moment.id
        draftErrorMessage = nil
        selectedMedia = MomentsCreateUITestFixtures.selectedMedia
        mediaStatusMessage = L10n.string("create.media.fixture.synced")
        savedScenes = workspace.storyScenes
        generatedScenes = []
        storyStatusMessage = L10n.string("create.story.status.readyToReview")
        lastPreparedStoryInputSignature = workspace.moment.storyInputSignature
            ?? currentStoryInputSignature(momentId: workspace.moment.id)
        activeWorkspace = workspace
        latestPreview = workspace.latestArtifact(kind: "preview")
        latestPreviewJob = workspace.latestRenderJob(kind: "preview")
        previewStatusMessage = L10n.string("create.preview.status.available")
        finalExport = workspace.latestArtifact(kind: "final_export")
        pendingGalleryVideo = nil
        latestFinalJob = workspace.latestRenderJob(kind: "final")
        finalRenderStatusMessage = L10n.string("create.final.status.ready")
        pendingFocus = .review
        continuationFocusHint = .review
    }

    var effectiveActiveWorkspace: MomentWorkspace? {
        usesFullUITestFixture ? MomentsCreateUITestFixtures.workspace : activeWorkspace
    }

    var effectiveSelectedMedia: [MomentsSelectedMedia] {
        usesFullUITestFixture ? MomentsCreateUITestFixtures.selectedMedia : selectedMedia
    }

    var effectiveSavedScenes: [MomentStoryScene] {
        effectiveActiveWorkspace?.storyScenes ?? savedScenes
    }

    var effectiveLatestPreview: MomentArtifact? {
        effectiveActiveWorkspace?.latestArtifact(kind: "preview") ?? latestPreview
    }

    var effectiveLatestPreviewJob: MomentRenderJob? {
        effectiveActiveWorkspace?.latestRenderJob(kind: "preview") ?? latestPreviewJob
    }

    var effectiveFinalExport: MomentArtifact? {
        effectiveActiveWorkspace?.latestArtifact(kind: "final_export") ?? finalExport
    }

    private var canEditCreationOptions: Bool {
        if isBusy { return false }
        if effectiveActiveWorkspace?.canEditDraftDuringRender == false {
            return false
        }
        if effectiveLatestPreview != nil || effectiveLatestPreviewJob != nil {
            return false
        }
        if effectiveFinalExport != nil || latestFinalJob != nil {
            return false
        }
        return true
    }

    var effectiveLatestFinalJob: MomentRenderJob? {
        effectiveActiveWorkspace?.latestRenderJob(kind: "final") ?? latestFinalJob
    }

    var usesFullUITestFixture: Bool {
        MomentsUITestEnvironment.current.createFixture == "full"
    }

    func resetActiveMoment(force: Bool) {
        cancelOperations()
        isContinuingMoment = false
        isLocalMomentStarted = false
        pendingFocus = nil
        continuationFocusHint = nil
        momentCreationWorkflow?.resetDraft(force: force)
        mediaUploadWorkflow?.reset(force: force)
        storyDraftWorkflow?.reset(force: force)
        previewGenerationWorkflow?.reset(force: force)
        finalRenderWorkflow?.reset(force: force)

        if let firstTemplate = templates.first {
            form = MomentSetupForm(template: firstTemplate)
        }
        selectedCreationStyle = creationStyles.first ?? MomentCreationStyle.launchStyles[0]
        selectedMusicPreset = selectedCreationStyle.defaultMusic
        autoStyleSuggestion = nil
        canUndoAutoStyleSuggestion = false
        autoStyleUndoSelection = nil
        autoStyleMediaSignature = nil
        lastPreparedStoryInputSignature = nil
        hasUserStyleOverride = false
        isBuyingReviewBundle = false
        applyStyleDefaults(selectedCreationStyle)
        newMomentStep = .status
    }

    private func applyStyleDefaults(_ style: MomentCreationStyle) {
        form.template = style.template
        form.theme = style.id
        form.look = .real
        form.creationMode = .quick
        form.duration = .auto
        form.mediaUse = .aviPick
        form.occasion = style.title
        form.tone = style.tone
        form.tempo = style.tempo
    }

    func currentStoryInputSignature(momentId: String) -> String {
        MomentsStoryDraftInputSignature.make(
            momentId: momentId,
            form: form,
            selectedMedia: currentStorySignatureMedia()
        )
    }

    func currentStoryInputSignature(
        momentId: String,
        persistedMedia: [MomentsStoryDraftMedia]?
    ) -> String {
        MomentsStoryDraftInputSignature.make(
            momentId: momentId,
            form: form,
            selectedMedia: persistedMedia ?? currentStorySignatureMedia()
        )
    }

    private func currentStorySignatureMedia() -> [MomentsStoryDraftMedia] {
        let localMedia = effectiveSelectedMedia
            .filter(\.selected)
            .sorted { $0.sortOrder < $1.sortOrder }
        if !localMedia.isEmpty {
            let syncedMediaBySourceIdentifier = (effectiveActiveWorkspace?.mediaAssets ?? []).reduce(into: [String: MomentMediaAsset]()) {
                guard let sourceIdentifier = $1.platformMediaAssetId else { return }
                $0[sourceIdentifier] = $1
            }

            return localMedia
                .map {
                    let syncedMedia = syncedMediaBySourceIdentifier[$0.sourceLocalIdentifier]
                    return MomentsStoryDraftMedia(
                        mediaAssetId: syncedMedia?.id ?? $0.id.uuidString,
                        mediaKind: syncedMedia?.kind ?? $0.kind,
                        sortOrder: $0.sortOrder,
                        selected: $0.selected,
                        moderationStatus: syncedMedia?.moderationStatus ?? "pending"
                    )
                }
        }

        return (effectiveActiveWorkspace?.mediaAssets ?? [])
            .filter(\.selected)
            .sorted { $0.sortOrder < $1.sortOrder }
            .map {
                MomentsStoryDraftMedia(
                    mediaAssetId: $0.id,
                    mediaKind: $0.kind,
                    sortOrder: Int($0.sortOrder),
                    selected: $0.selected,
                    moderationStatus: $0.moderationStatus
                )
            }
    }
}

enum MomentsCreateNewMomentStep: Equatable {
    case status
    case style
    case summary
}

extension MomentsCreateViewModel {
    func applyAccountState(_ state: MomentsCreateAccountState) {
        isSignedIn = state.isSignedIn
        balance = state.balance
    }

    func applyMomentCreationState(_ state: MomentsCreateMomentCreationState) {
        guard !usesFullUITestFixture else { return }
        let previousActiveMomentId = workflowActiveMomentId
        isCreatingDraft = state.isCreatingDraft
        workflowActiveMomentId = state.activeMomentId
        draftErrorMessage = state.draftErrorMessage

        if previousActiveMomentId == nil, state.activeMomentId != nil {
            pendingFocus = .media
            continuationFocusHint = nil
        }
    }

    func applyMediaUploadState(_ state: MomentsCreateMediaUploadState) {
        guard !usesFullUITestFixture else { return }
        selectedMedia = state.selectedMedia
        mediaStatusMessage = state.statusMessage
        isImportingMedia = state.isImporting
        mediaImportProgress = state.importProgress
        updateAutoStyleSuggestion(for: state.selectedMedia)
    }

    func applyStoryDraftState(_ state: MomentsCreateStoryDraftState) {
        guard !usesFullUITestFixture else { return }
        savedScenes = state.savedScenes
        generatedScenes = state.generatedScenes
        isDraftingStory = state.isDrafting

        let hasStoryScenes = !state.savedScenes.isEmpty || !state.generatedScenes.isEmpty
        if hasStoryScenes {
            if let activeMomentId {
                lastPreparedStoryInputSignature = effectiveActiveWorkspace?.moment.storyInputSignature
                    ?? lastPreparedStoryInputSignature
                    ?? currentStoryInputSignature(momentId: activeMomentId)
            }
            storyStatusMessage = nil
        } else {
            storyStatusMessage = state.statusMessage
        }
    }

    func updateStoryStatusMessage(_ message: String?) {
        storyStatusMessage = message
    }

    func updatePreviewStatusMessage(_ message: String?) {
        previewStatusMessage = message
    }

    func updateDraftErrorMessage(_ message: String?) {
        draftErrorMessage = message
    }

    func updateFinalRenderStatusMessage(_ message: String?) {
        finalRenderStatusMessage = message
    }

    func applyPreviewGenerationState(_ state: MomentsCreatePreviewGenerationState) {
        guard !usesFullUITestFixture else { return }
        activeWorkspace = state.activeWorkspace
        syncFormWithActiveWorkspace(state.activeWorkspace)
        latestPreview = state.latestPreview
        latestPreviewJob = state.latestPreviewJob
        previewStatusMessage = state.statusMessage
        isGeneratingPreview = state.isGenerating
        isRefreshingPreviewStatus = state.isRefreshingStatus
    }

    func applyFinalRenderState(_ state: MomentsCreateFinalRenderState) {
        guard !usesFullUITestFixture else { return }
        finalExport = state.finalExport
        latestFinalJob = state.latestFinalJob
        renderPlan = state.renderPlan
        pendingGalleryVideo = state.pendingGalleryVideo
        canRetryFinalVideoDownload = state.canRetryFinalVideoDownload
        finalRenderStatusMessage = state.statusMessage
        isGeneratingFinalRender = state.isGenerating
        isRefreshingFinalRenderStatus = state.isRefreshingStatus
    }

    private func syncFormWithActiveWorkspace(_ workspace: MomentWorkspace?) {
        guard let moment = workspace?.moment else { return }
        guard moment.id == activeMomentId else { return }
        guard let continuedForm = MomentSetupForm.continuing(moment: moment, templates: templates) else { return }

        form = continuedForm
        if let continuedStyle = creationStyles.first(where: { $0.template.id == continuedForm.template.id }) {
            selectedCreationStyle = continuedStyle
            selectedMusicPreset = continuedStyle.allowedMusic.first(where: { $0 == continuedStyle.defaultMusic }) ?? continuedStyle.defaultMusic
        }
        if let continuedStyle = creationStyles.first(where: { $0.id.rawValue == moment.theme }) {
            selectedCreationStyle = continuedStyle
            selectedMusicPreset = continuedStyle.allowedMusic.first(where: { $0 == continuedStyle.defaultMusic }) ?? continuedStyle.defaultMusic
        }
    }

    private func updateAutoStyleSuggestion(for media: [MomentsSelectedMedia]) {
        guard canEditCreationOptions else { return }
        let signature = mediaSignature(media)
        guard signature != autoStyleMediaSignature else { return }
        autoStyleMediaSignature = signature
        guard let suggestion = MomentsMediaAutoStyleSuggester.suggest(
            media: media,
            styles: creationStyles
        ) else {
            autoStyleSuggestion = nil
            return
        }
        guard let suggestedStyle = creationStyles.first(where: { $0.id == suggestion.styleID && $0.isEnabled }) else {
            autoStyleSuggestion = nil
            return
        }

        autoStyleSuggestion = suggestion
        guard !hasUserStyleOverride else { return }
        selectedCreationStyle = suggestedStyle
        selectedMusicPreset = suggestion.musicPreset
        applyStyleDefaults(suggestedStyle)
        form.tone = MomentSetupTone(musicPreset: suggestion.musicPreset)
    }

    private func mediaSignature(_ media: [MomentsSelectedMedia]) -> String {
        media
            .map { "\($0.id.uuidString):\($0.sha256):\($0.sortOrder)" }
            .joined(separator: "|")
    }

    private static func isUserFacingErrorMessage(_ message: String) -> Bool {
        let lowercased = message.lowercased()
        return lowercased.contains("couldn’t")
            || lowercased.contains("couldn't")
            || lowercased.contains("failed")
            || lowercased.contains("not configured")
            || lowercased.contains("not available")
            || lowercased.contains("sign in again")
            || lowercased.contains("try again")
    }
}
