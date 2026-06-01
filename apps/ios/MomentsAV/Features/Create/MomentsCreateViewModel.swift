import Combine
import Foundation

@MainActor
final class MomentsCreateViewModel: ObservableObject {
    @Published private(set) var isSignedIn = false
    @Published private(set) var balance = MomentsCreditBalance.empty
    @Published private(set) var templates = MomentTemplate.launchTemplates
    @Published private(set) var creationStyles = MomentCreationStyle.launchStyles
    @Published var newProjectStep: MomentsCreateNewProjectStep = .status
    @Published var selectedCreationStyle = MomentCreationStyle.launchStyles[0]
    @Published var selectedMusicPreset = MomentCreationStyle.launchStyles[0].defaultMusic
    @Published var form = MomentDraftForm(template: MomentTemplate.launchTemplates[0])
    @Published private(set) var isCreatingDraft = false
    @Published private(set) var isContinuingProject = false
    @Published var isLocalMomentStarted = false
    @Published private(set) var workflowActiveProjectId: String?
    @Published private(set) var draftErrorMessage: String?
    @Published private(set) var selectedMedia: [MomentsSelectedMedia] = []
    @Published private(set) var mediaStatusMessage: String?
    @Published private(set) var isImportingMedia = false
    @Published private(set) var mediaImportProgress: MomentsMediaImportProgress?
    @Published private(set) var autoStyleSuggestion: MomentsMediaAutoStyleSuggestion?
    @Published private(set) var savedScenes: [MomentStoryScene] = []
    @Published private(set) var generatedScenes: [MomentsStoryDraftScene] = []
    @Published private(set) var storyStatusMessage: String?
    @Published private(set) var isDraftingStory = false
    @Published var isBuyingReviewBundle = false
    @Published var isPreparingStory = false
    @Published private(set) var activeWorkspace: MomentProjectWorkspace?
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
    @Published var pendingFocus: MomentsProjectContinuationFocus?
    @Published private(set) var continuationFocusHint: MomentsProjectContinuationFocus?
    @Published var mediaPickerOpenRequest = 0

    private(set) var projectCreationWorkflow: ProjectCreationWorkflow?
    private(set) var mediaUploadWorkflow: MediaUploadWorkflow?
    private(set) var storyDraftWorkflow: StoryDraftWorkflow?
    private(set) var previewGenerationWorkflow: PreviewGenerationWorkflow?
    private(set) var finalRenderWorkflow: FinalRenderWorkflow?
    let operationRunner = MomentsCreateOperationRunner()
    var cancellables = Set<AnyCancellable>()
    private var autoStyleMediaSignature: String?
    var lastPreparedStoryInputSignature: String?
    private var hasUserStyleOverride = false
    var reviewBundlePurchaser: (any MomentsReviewBundlePurchasing)?

    var activeProject: MomentDraftProject? {
        if usesFullUITestFixture {
            return MomentsCreateUITestFixtures.project
        }

        return activeWorkspace?.project
    }

    var activeProjectId: String? {
        activeProject?.id ?? workflowActiveProjectId
    }

    var hasMomentWorkspace: Bool {
        activeProjectId != nil || isLocalMomentStarted
    }

    var hasRecoverableMomentContext: Bool {
        activeProjectId != nil
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
        activeProjectId == nil && isLocalMomentStarted
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
        projectCreationWorkflow: ProjectCreationWorkflow,
        mediaUploadWorkflow: MediaUploadWorkflow,
        storyDraftWorkflow: StoryDraftWorkflow,
        previewGenerationWorkflow: PreviewGenerationWorkflow,
        finalRenderWorkflow: FinalRenderWorkflow
    ) {
        cancelOperations()
        reviewBundlePurchaser = accountStateProvider as? any MomentsReviewBundlePurchasing
        self.projectCreationWorkflow = projectCreationWorkflow
        self.mediaUploadWorkflow = mediaUploadWorkflow
        self.storyDraftWorkflow = storyDraftWorkflow
        self.previewGenerationWorkflow = previewGenerationWorkflow
        self.finalRenderWorkflow = finalRenderWorkflow
        templates = projectCreationWorkflow.launchTemplates
        creationStyles = MomentCreationStyle.launchStyles
        selectedCreationStyle = MomentCreationStyle.launchStyles[0]
        selectedMusicPreset = selectedCreationStyle.defaultMusic
        form = MomentDraftForm(template: projectCreationWorkflow.launchTemplates[0])
        applyStyleDefaults(selectedCreationStyle)
        cancellables.removeAll()

        bindWorkflowState(
            accountStateProvider: accountStateProvider,
            projectCreationWorkflow: projectCreationWorkflow,
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
        applyStyleDefaults(style)

        if newProjectStep == .style {
            beginNewProject()
        }
    }

    func selectMusicPreset(_ preset: MomentMusicPreset) {
        guard selectedCreationStyle.allowedMusic.contains(preset) else { return }
        hasUserStyleOverride = true
        selectedMusicPreset = preset
    }

    func useAutoStyleSuggestion() {
        guard canEditCreationOptions else { return }
        guard let suggestion = autoStyleSuggestion else { return }
        guard let suggestedStyle = creationStyles.first(where: { $0.id == suggestion.styleID && $0.isEnabled }) else { return }
        selectedCreationStyle = suggestedStyle
        selectedMusicPreset = suggestion.musicPreset
        hasUserStyleOverride = false
        applyStyleDefaults(suggestedStyle)
    }

    func clearSessionState() {
        resetActiveProject(force: true)
    }

    func prepareNewDraftCreation() {
        isContinuingProject = false
        continuationFocusHint = nil
        isLocalMomentStarted = false
    }

    func continueProject(_ project: MomentDraftProject, focus: MomentsProjectContinuationFocus = .review) {
        cancelOperations()
        isContinuingProject = true
        isLocalMomentStarted = false
        pendingFocus = focus
        continuationFocusHint = focus

        if let continuedForm = MomentDraftForm.continuing(project: project, templates: templates) {
            form = continuedForm
        }

        projectCreationWorkflow?.continueProject(project)
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
        let template = templates.first(where: { $0.id == workspace.project.template }) ?? MomentTemplate.birthdayMessage
        form = MomentDraftForm(
            template: template,
            occasion: workspace.project.occasion ?? "Birthday",
            recipient: "Ava",
            tone: MomentDraftTone(rawValue: workspace.project.tone ?? "") ?? .warm,
            tempo: MomentDraftTempo(rawValue: workspace.project.tempo ?? "") ?? .balanced,
            details: workspace.project.details ?? ""
        )
        isSignedIn = true
        balance = MomentsCreateUITestFixtures.balance
        isContinuingProject = true
        workflowActiveProjectId = workspace.project.id
        draftErrorMessage = nil
        selectedMedia = MomentsCreateUITestFixtures.selectedMedia
        mediaStatusMessage = "3 assets synced. Avi selected the strongest opening order."
        savedScenes = workspace.storyScenes
        generatedScenes = []
        storyStatusMessage = "Story draft ready for review."
        lastPreparedStoryInputSignature = workspace.project.storyInputSignature
            ?? currentStoryInputSignature(projectId: workspace.project.id)
        activeWorkspace = workspace
        latestPreview = workspace.latestArtifact(kind: "preview")
        latestPreviewJob = workspace.latestRenderJob(kind: "preview")
        previewStatusMessage = "Story review is available."
        finalExport = workspace.latestArtifact(kind: "final_export")
        pendingGalleryVideo = nil
        latestFinalJob = workspace.latestRenderJob(kind: "final")
        finalRenderStatusMessage = "Final export is ready."
        pendingFocus = .review
        continuationFocusHint = .review
    }

    var effectiveActiveWorkspace: MomentProjectWorkspace? {
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

    func resetActiveProject(force: Bool) {
        cancelOperations()
        isContinuingProject = false
        isLocalMomentStarted = false
        pendingFocus = nil
        continuationFocusHint = nil
        projectCreationWorkflow?.resetDraft(force: force)
        mediaUploadWorkflow?.reset(force: force)
        storyDraftWorkflow?.reset(force: force)
        previewGenerationWorkflow?.reset(force: force)
        finalRenderWorkflow?.reset(force: force)

        if let firstTemplate = templates.first {
            form = MomentDraftForm(template: firstTemplate)
        }
        selectedCreationStyle = creationStyles.first ?? MomentCreationStyle.launchStyles[0]
        selectedMusicPreset = selectedCreationStyle.defaultMusic
        autoStyleSuggestion = nil
        autoStyleMediaSignature = nil
        lastPreparedStoryInputSignature = nil
        hasUserStyleOverride = false
        isBuyingReviewBundle = false
        applyStyleDefaults(selectedCreationStyle)
        newProjectStep = .status
    }

    private func applyStyleDefaults(_ style: MomentCreationStyle) {
        form.template = style.template
        form.occasion = style.title
        form.tone = style.tone
        form.tempo = style.tempo
    }

    func currentStoryInputSignature(projectId: String) -> String {
        MomentsStoryDraftInputSignature.make(
            projectId: projectId,
            form: form,
            selectedMedia: currentStorySignatureMedia()
        )
    }

    func currentStoryInputSignature(
        projectId: String,
        persistedMedia: [MomentsStoryDraftMedia]?
    ) -> String {
        MomentsStoryDraftInputSignature.make(
            projectId: projectId,
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

enum MomentsCreateNewProjectStep: Equatable {
    case status
    case style
    case summary
}

extension MomentsCreateViewModel {
    func applyAccountState(_ state: MomentsCreateAccountState) {
        isSignedIn = state.isSignedIn
        balance = state.balance
    }

    func applyProjectCreationState(_ state: MomentsCreateProjectCreationState) {
        guard !usesFullUITestFixture else { return }
        let previousActiveProjectId = workflowActiveProjectId
        isCreatingDraft = state.isCreatingDraft
        workflowActiveProjectId = state.activeProjectId
        draftErrorMessage = state.draftErrorMessage

        if previousActiveProjectId == nil, state.activeProjectId != nil {
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
            if let activeProjectId {
                lastPreparedStoryInputSignature = effectiveActiveWorkspace?.project.storyInputSignature
                    ?? lastPreparedStoryInputSignature
                    ?? currentStoryInputSignature(projectId: activeProjectId)
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

    private func syncFormWithActiveWorkspace(_ workspace: MomentProjectWorkspace?) {
        guard let project = workspace?.project else { return }
        guard project.id == activeProjectId else { return }
        guard let continuedForm = MomentDraftForm.continuing(project: project, templates: templates) else { return }

        form = continuedForm
        if let continuedStyle = creationStyles.first(where: { $0.template.id == continuedForm.template.id }) {
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
