import Combine
import CryptoKit
import Foundation

@MainActor
final class MomentsCreateViewModel: ObservableObject {
    @Published private(set) var isSignedIn = false
    @Published private(set) var balance = MomentsCreditBalance.empty
    @Published private(set) var creditBalanceLoadState = MomentsCreditBalanceLoadState.signedOut
    @Published private(set) var templates = MomentTemplate.launchTemplates
    @Published private(set) var creationStyles = MomentCreationStyle.launchStyles
    @Published var selectedCreationStyle = MomentCreationStyle.launchStyles[0]
    @Published var selectedMusicPreset = MomentCreationStyle.launchStyles[0].defaultMusic
    @Published var form = MomentSetupForm(template: MomentTemplate.launchTemplates[0])
    @Published private(set) var isCreatingMoment = false
    @Published private(set) var isContinuingMoment = false
    @Published var isLocalMomentStarted = false
    @Published private(set) var workflowActiveMomentId: String?
    @Published private(set) var setupErrorMessage: String?
    @Published private(set) var selectedMedia: [MomentsSelectedMedia] = []
    @Published private(set) var mediaStatusMessage: String?
    @Published private(set) var isImportingMedia = false
    @Published private(set) var mediaImportProgress: MomentsMediaImportProgress?
    @Published private(set) var autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    @Published private(set) var canUndoAutoStyleSuggestion = false
    @Published private(set) var savedScenes: [MomentStoryScene] = []
    @Published private(set) var generatedScenes: [MomentsStoryPlanScene] = []
    @Published private(set) var storyStatusMessage: String?
    @Published private(set) var isPlanningStory = false
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
    @Published private(set) var isPreparingFinalPlan = false
    @Published private(set) var isRefreshingFinalRenderStatus = false
    @Published var pendingFocus: MomentsContinuationFocus?
    @Published private(set) var continuationFocusHint: MomentsContinuationFocus?
    @Published var mediaPickerOpenRequest = 0
    @Published var albumPickerOpenRequest = 0

    private(set) var momentCreationWorkflow: MomentCreationWorkflow?
    private(set) var mediaUploadWorkflow: MediaUploadWorkflow?
    private(set) var storyPlanWorkflow: StoryPlanWorkflow?
    private(set) var previewGenerationWorkflow: PreviewGenerationWorkflow?
    private(set) var finalRenderWorkflow: FinalRenderWorkflow?
    let operationRunner = MomentsCreateOperationRunner()
    var cancellables = Set<AnyCancellable>()
    private var autoStyleMediaSignature: String?
    var lastPreparedStoryInputSignature: String?
    private var renderPlanInputSignature: String?
    private var pendingRenderPlanInputSignature: String?
    private var hasExplicitMediaEditsAfterPreparedStory = false
    private var hasUserStyleOverride = false
    private var hasUserDurationOverride = false
    private var autoStyleUndoSelection: (style: MomentCreationStyle, musicPreset: MomentMusicPreset, form: MomentSetupForm)?

    var activeMoment: InProgressMoment? {
        if let fixtureMode = activeUITestFixtureMode {
            return MomentsCreateUITestFixtures.moment(for: fixtureMode)
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
            || isPlanningStory
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
            setupErrorMessage,
            mediaStatusMessage,
            storyStatusMessage,
            previewStatusMessage,
            finalRenderAlertMessage
        ]
            .compactMap(\.self)
            .first(where: Self.isUserFacingErrorMessage)
    }

    func bind(
        accountStateProvider: any MomentsAccountStateProviding,
        momentCreationWorkflow: MomentCreationWorkflow,
        mediaUploadWorkflow: MediaUploadWorkflow,
        storyPlanWorkflow: StoryPlanWorkflow,
        previewGenerationWorkflow: PreviewGenerationWorkflow,
        finalRenderWorkflow: FinalRenderWorkflow
    ) {
        cancelOperations()
        self.momentCreationWorkflow = momentCreationWorkflow
        self.mediaUploadWorkflow = mediaUploadWorkflow
        self.storyPlanWorkflow = storyPlanWorkflow
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
            storyPlanWorkflow: storyPlanWorkflow,
            previewGenerationWorkflow: previewGenerationWorkflow,
            finalRenderWorkflow: finalRenderWorkflow
        )
    }

    func selectTemplate(id: MomentTemplateID) {
        guard !isSetupLocked else { return }
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

    func prepareNewMomentCreation() {
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

    func consumeAlbumPickerOpenRequest() {
        albumPickerOpenRequest = 0
    }

    func applyUITestCreateFixture() {
        guard let fixtureMode = activeUITestFixtureMode else { return }

        let workspace = MomentsCreateUITestFixtures.workspace(for: fixtureMode)
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
        setupErrorMessage = nil
        selectedMedia = MomentsCreateUITestFixtures.selectedMedia
        mediaStatusMessage = L10n.string("create.media.fixture.synced")
        savedScenes = workspace.storyScenes
        generatedScenes = []
        storyStatusMessage = L10n.string("create.story.status.readyToReview")
        lastPreparedStoryInputSignature = workspace.moment.storyInputSignature
            ?? currentStoryPlanInputSignature(momentId: workspace.moment.id)
        activeWorkspace = workspace
        latestPreview = workspace.latestArtifact(kind: "preview")
        latestPreviewJob = workspace.latestRenderJob(kind: "preview")
        previewStatusMessage = latestPreview == nil ? nil : L10n.string("create.preview.status.available")
        finalExport = workspace.latestArtifact(kind: "final_export")
        pendingGalleryVideo = nil
        latestFinalJob = workspace.latestRenderJob(kind: "final")
        renderPlan = fixtureMode == .videoPlanReady ? MomentsCreateUITestFixtures.renderPlan : nil
        renderPlanInputSignature = renderPlan.map { currentFinalRenderInputSignature(momentId: $0.momentId) }
        finalRenderStatusMessage = {
            switch fixtureMode {
            case .aviCutReady:
                return nil
            case .videoPlanReady:
                return L10n.string("workflow.final.planReady")
            case .full:
                return L10n.string("create.final.status.ready")
            }
        }()
        pendingFocus = .review
        continuationFocusHint = .review
    }

    var effectiveActiveWorkspace: MomentWorkspace? {
        if let fixtureMode = activeUITestFixtureMode {
            return MomentsCreateUITestFixtures.workspace(for: fixtureMode)
        }
        return activeWorkspace
    }

    var effectiveSelectedMedia: [MomentsSelectedMedia] {
        usesCreateUITestFixture ? MomentsCreateUITestFixtures.selectedMedia : selectedMedia
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
        if effectiveActiveWorkspace?.canEditSetupDuringRender == false {
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

    var activeUITestFixtureMode: MomentsCreateUITestFixtures.Mode? {
        MomentsCreateUITestFixtures.mode
    }

    var usesCreateUITestFixture: Bool {
        activeUITestFixtureMode != nil
    }

    func resetActiveMoment(force: Bool) {
        cancelOperations()
        isContinuingMoment = false
        isLocalMomentStarted = false
        pendingFocus = nil
        continuationFocusHint = nil
        momentCreationWorkflow?.resetMomentSetup(force: force)
        mediaUploadWorkflow?.reset(force: force)
        storyPlanWorkflow?.reset(force: force)
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
        renderPlanInputSignature = nil
        pendingRenderPlanInputSignature = nil
        isPreparingFinalPlan = false
        hasExplicitMediaEditsAfterPreparedStory = false
        hasUserStyleOverride = false
        hasUserDurationOverride = false
        applyStyleDefaults(selectedCreationStyle)
    }

    private func applyStyleDefaults(_ style: MomentCreationStyle) {
        form.template = style.template
        form.theme = style.id
        form.look = .real
        form.creationMode = .quick
        form.duration = .auto
        hasUserDurationOverride = false
        form.mediaUse = .aviPick
        form.occasion = style.title
        form.tone = style.tone
        form.tempo = style.tempo
    }

    func currentStoryPlanInputSignature(momentId: String) -> String {
        MomentsStoryPlanInputSignature.make(
            momentId: momentId,
            form: form,
            selectedMedia: currentStoryPlanSignatureMedia()
        )
    }

    func currentStoryPlanInputSignature(
        momentId: String,
        persistedMedia: [MomentsStoryPlanMedia]?
    ) -> String {
        MomentsStoryPlanInputSignature.make(
            momentId: momentId,
            form: form,
            selectedMedia: persistedMedia ?? currentStoryPlanSignatureMedia()
        )
    }

    func preparedStoryComparisonInputSignature(momentId: String) -> String {
        if !hasExplicitMediaEditsAfterPreparedStory,
           let workspaceMedia = currentWorkspaceStoryPlanSignatureMedia(),
           !workspaceMedia.isEmpty {
            return currentStoryPlanInputSignature(momentId: momentId, persistedMedia: workspaceMedia)
        }

        return currentStoryPlanInputSignature(momentId: momentId)
    }

    func currentFinalRenderInputSignature(momentId: String, removesWatermark: Bool = false) -> String {
        let input = currentFinalRenderInputSignatureSource(momentId: momentId, removesWatermark: removesWatermark)
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    func currentFinalRenderInputSignatureSource(momentId: String, removesWatermark: Bool = false) -> String {
        let finalForm = effectiveFinalRenderForm()
        let mediaSignature = currentFinalRenderSignatureMedia()
            .map { "\($0.sortOrder):\($0.sourceLocalIdentifier):\($0.mediaKind)" }
            .joined(separator: "|")
        return [
            momentId,
            finalForm.creationMode.rawValue,
            finalForm.look.rawValue,
            finalForm.theme.rawValue,
            finalForm.tone.rawValue,
            finalForm.duration.rawValue,
            finalForm.mediaUse.rawValue,
            finalForm.occasion.trimmingCharacters(in: .whitespacesAndNewlines),
            finalForm.details.trimmingCharacters(in: .whitespacesAndNewlines),
            mediaSignature,
            "\(removesWatermark)"
        ].joined(separator: "|")
    }

    func effectiveFinalRenderForm() -> MomentSetupForm {
        var finalForm = form
        if !hasUserDurationOverride {
            finalForm.duration = .auto
        }
        return finalForm
    }

    var currentRenderPlan: MomentsRenderPlanResponse? {
        currentRenderPlan(removesWatermark: false)
    }

    func currentRenderPlan(removesWatermark: Bool) -> MomentsRenderPlanResponse? {
        guard let renderPlan else { return nil }
        guard renderPlanInputSignature == currentFinalRenderInputSignature(
            momentId: renderPlan.momentId,
            removesWatermark: removesWatermark
        ) else {
            return nil
        }
        return renderPlan
    }

    func hasConfirmableRenderPlan(momentId: String) -> Bool {
        confirmableRenderPlan(momentId: momentId) != nil
    }

    func confirmableRenderPlan(momentId: String) -> MomentsRenderPlanResponse? {
        guard let renderPlan else { return nil }
        guard renderPlan.momentId == momentId, renderPlan.canCreateVideo else { return nil }
        return renderPlan
    }

    func beginFinalPlanPreparation(inputSignature: String) {
        pendingRenderPlanInputSignature = inputSignature
        isPreparingFinalPlan = true
    }

    func finishFinalPlanPreparation() {
        isPreparingFinalPlan = false
    }

    func clearStaleRenderPlan() {
        renderPlan = nil
        renderPlanInputSignature = nil
        pendingRenderPlanInputSignature = nil
        finalRenderWorkflow?.clearRenderPlan()
    }

    func selectDuration(_ duration: MomentDuration) {
        form.duration = duration
        hasUserDurationOverride = true
        clearStaleRenderPlan()
    }

    func markPreparedStoryMediaEdited() {
        clearStaleRenderPlan()
        guard !savedScenes.isEmpty || !generatedScenes.isEmpty else { return }
        hasExplicitMediaEditsAfterPreparedStory = true
    }

    @discardableResult
    func recordPreparedStoryInputSignature(_ inputSignature: String, momentId: String) -> String {
        let recordedSignature: String
        if let workspaceSignature = effectiveActiveWorkspace?.moment.storyInputSignature {
            recordedSignature = workspaceSignature
        } else if currentWorkspaceStoryPlanSignatureMedia()?.isEmpty == false {
            recordedSignature = inputSignature
        } else {
            recordedSignature = currentStoryPlanInputSignature(momentId: momentId)
        }
        lastPreparedStoryInputSignature = recordedSignature
        hasExplicitMediaEditsAfterPreparedStory = false
        return recordedSignature
    }

    private func currentStoryPlanSignatureMedia() -> [MomentsStoryPlanMedia] {
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
                    return MomentsStoryPlanMedia(
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
                MomentsStoryPlanMedia(
                    mediaAssetId: $0.id,
                    mediaKind: $0.kind,
                    sortOrder: Int($0.sortOrder),
                    selected: $0.selected,
                    moderationStatus: $0.moderationStatus
                )
            }
    }

    private func currentFinalRenderSignatureMedia() -> [(sourceLocalIdentifier: String, mediaKind: String, sortOrder: Int)] {
        let localMedia = effectiveSelectedMedia
            .filter(\.selected)
            .sorted { $0.sortOrder < $1.sortOrder }
        if !localMedia.isEmpty {
            return localMedia.map {
                (
                    sourceLocalIdentifier: $0.sourceLocalIdentifier,
                    mediaKind: $0.kind,
                    sortOrder: $0.sortOrder
                )
            }
        }

        return (effectiveActiveWorkspace?.mediaAssets ?? [])
            .filter(\.selected)
            .sorted { $0.sortOrder < $1.sortOrder }
            .map {
                (
                    sourceLocalIdentifier: $0.platformMediaAssetId ?? $0.id,
                    mediaKind: $0.kind,
                    sortOrder: Int($0.sortOrder)
                )
            }
    }

    private func currentWorkspaceStoryPlanSignatureMedia() -> [MomentsStoryPlanMedia]? {
        let mediaAssets = effectiveActiveWorkspace?.mediaAssets ?? []
        guard !mediaAssets.isEmpty else { return nil }
        let selectedAssets = mediaAssets.filter(\.selected)
        return (selectedAssets.isEmpty ? mediaAssets : selectedAssets)
            .sorted { $0.sortOrder < $1.sortOrder }
            .map {
                MomentsStoryPlanMedia(
                    mediaAssetId: $0.id,
                    mediaKind: $0.kind,
                    sortOrder: Int($0.sortOrder),
                    selected: $0.selected,
                    moderationStatus: $0.moderationStatus
                )
            }
    }
}

extension MomentsCreateViewModel {
    func applyAccountState(_ state: MomentsCreateAccountState) {
        guard !usesCreateUITestFixture else { return }
        isSignedIn = state.isSignedIn
        balance = state.balance
        creditBalanceLoadState = state.creditBalanceLoadState
    }

    func applyMomentCreationState(_ state: MomentsCreateMomentCreationState) {
        guard !usesCreateUITestFixture else { return }
        let previousActiveMomentId = workflowActiveMomentId
        isCreatingMoment = state.isCreatingMoment
        workflowActiveMomentId = state.activeMomentId
        setupErrorMessage = state.setupErrorMessage

        if previousActiveMomentId == nil, state.activeMomentId != nil {
            pendingFocus = .media
            continuationFocusHint = nil
        }
    }

    func applyMediaUploadState(_ state: MomentsCreateMediaUploadState) {
        guard !usesCreateUITestFixture else { return }
        selectedMedia = state.selectedMedia
        mediaStatusMessage = state.statusMessage
        isImportingMedia = state.isImporting
        mediaImportProgress = state.importProgress
        updateAutoStyleSuggestion(for: state.selectedMedia)
    }

    func applyStoryPlanState(_ state: MomentsCreateStoryPlanState) {
        guard !usesCreateUITestFixture else { return }
        savedScenes = state.savedScenes
        generatedScenes = state.generatedScenes
        isPlanningStory = state.isPlanning

        let hasStoryScenes = !state.savedScenes.isEmpty || !state.generatedScenes.isEmpty
        if hasStoryScenes {
            reconcilePreparedStorySignature()
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

    func updateSetupErrorMessage(_ message: String?) {
        setupErrorMessage = message
    }

    func updateFinalRenderStatusMessage(_ message: String?) {
        finalRenderStatusMessage = message
    }

    func applyPreviewGenerationState(_ state: MomentsCreatePreviewGenerationState) {
        guard !usesCreateUITestFixture else { return }
        activeWorkspace = state.activeWorkspace
        syncFormWithActiveWorkspace(state.activeWorkspace)
        reconcilePreparedStorySignature()
        latestPreview = state.latestPreview
        latestPreviewJob = state.latestPreviewJob
        previewStatusMessage = state.statusMessage
        isGeneratingPreview = state.isGenerating
        isRefreshingPreviewStatus = state.isRefreshingStatus
    }

    func applyFinalRenderState(_ state: MomentsCreateFinalRenderState) {
        guard !usesCreateUITestFixture else { return }
        finalExport = state.finalExport
        latestFinalJob = state.latestFinalJob
        renderPlan = state.renderPlan
        if let renderPlan = state.renderPlan {
            renderPlanInputSignature = pendingRenderPlanInputSignature
                ?? currentFinalRenderInputSignature(momentId: renderPlan.momentId)
            pendingRenderPlanInputSignature = nil
        } else {
            renderPlanInputSignature = nil
        }
        pendingGalleryVideo = state.pendingGalleryVideo
        canRetryFinalVideoDownload = state.canRetryFinalVideoDownload
        finalRenderStatusMessage = normalizedFinalRenderStatusMessage(
            state.statusMessage,
            latestFinalJob: state.latestFinalJob
        )
        isGeneratingFinalRender = state.isGenerating
        isRefreshingFinalRenderStatus = state.isRefreshingStatus
    }

    private func syncFormWithActiveWorkspace(_ workspace: MomentWorkspace?) {
        guard let moment = workspace?.moment else { return }
        guard moment.id == activeMomentId else { return }
        guard let continuedForm = MomentSetupForm.continuing(moment: moment, templates: templates) else { return }

        form = continuedForm
        hasUserDurationOverride = false
        if let continuedStyle = creationStyles.first(where: { $0.template.id == continuedForm.template.id }) {
            selectedCreationStyle = continuedStyle
            selectedMusicPreset = continuedStyle.allowedMusic.first(where: { $0 == continuedStyle.defaultMusic }) ?? continuedStyle.defaultMusic
        }
        if let continuedStyle = creationStyles.first(where: { $0.id.rawValue == moment.theme }) {
            selectedCreationStyle = continuedStyle
            selectedMusicPreset = continuedStyle.allowedMusic.first(where: { $0 == continuedStyle.defaultMusic }) ?? continuedStyle.defaultMusic
        }
    }

    private func reconcilePreparedStorySignature() {
        guard !savedScenes.isEmpty || !generatedScenes.isEmpty else { return }
        guard let activeMomentId else { return }

        if let workspaceSignature = effectiveActiveWorkspace?.moment.storyInputSignature {
            if lastPreparedStoryInputSignature != workspaceSignature {
                hasExplicitMediaEditsAfterPreparedStory = false
            }
            lastPreparedStoryInputSignature = workspaceSignature
            return
        }

        if lastPreparedStoryInputSignature == nil || currentWorkspaceStoryPlanSignatureMedia()?.isEmpty == false {
            lastPreparedStoryInputSignature = preparedStoryComparisonInputSignature(momentId: activeMomentId)
        }
    }

    private func updateAutoStyleSuggestion(for media: [MomentsSelectedMedia]) {
        guard canEditCreationOptions else { return }
        guard !storySummary.hasScenes || hasExplicitMediaEditsAfterPreparedStory else { return }
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

    private var finalRenderAlertMessage: String? {
        guard let finalRenderStatusMessage else { return nil }
        guard !hasActiveFinalRenderJob else { return nil }
        return finalRenderStatusMessage
    }

    private var hasActiveFinalRenderJob: Bool {
        guard let latestFinalJob else { return false }
        return latestFinalJob.status == "queued" || latestFinalJob.status == "running"
    }

    private func normalizedFinalRenderStatusMessage(
        _ message: String?,
        latestFinalJob: MomentRenderJob?
    ) -> String? {
        guard let message,
              Self.isUserFacingErrorMessage(message),
              let latestFinalJob,
              latestFinalJob.status == "queued" || latestFinalJob.status == "running"
        else {
            return message
        }

        return latestFinalJob.userMessage
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
