import Combine
import Foundation

@MainActor
final class MomentsCreateViewModel: ObservableObject {
    @Published private(set) var isSignedIn = false
    @Published private(set) var balance = MomentsCreditBalance.empty
    @Published private(set) var templates = MomentTemplate.launchTemplates
    @Published var form = MomentDraftForm(template: MomentTemplate.launchTemplates[0])
    @Published private(set) var isCreatingDraft = false
    @Published private(set) var isContinuingProject = false
    @Published private(set) var workflowActiveProjectId: String?
    @Published private(set) var draftErrorMessage: String?
    @Published private(set) var selectedMedia: [MomentsSelectedMedia] = []
    @Published private(set) var mediaStatusMessage: String?
    @Published private(set) var isImportingMedia = false
    @Published private(set) var savedScenes: [MomentStoryScene] = []
    @Published private(set) var generatedScenes: [MomentsStoryDraftScene] = []
    @Published private(set) var storyStatusMessage: String?
    @Published private(set) var isDraftingStory = false
    @Published private(set) var activeWorkspace: MomentProjectWorkspace?
    @Published private(set) var latestPreview: MomentArtifact?
    @Published private(set) var latestPreviewJob: MomentRenderJob?
    @Published private(set) var previewStatusMessage: String?
    @Published private(set) var isGeneratingPreview = false
    @Published private(set) var isRefreshingPreviewStatus = false
    @Published private(set) var finalExport: MomentArtifact?
    @Published private(set) var latestFinalJob: MomentRenderJob?
    @Published private(set) var finalRenderStatusMessage: String?
    @Published private(set) var isGeneratingFinalRender = false
    @Published private(set) var isRefreshingFinalRenderStatus = false
    @Published private(set) var pendingFocus: MomentsProjectContinuationFocus?
    @Published private(set) var continuationFocusHint: MomentsProjectContinuationFocus?

    private(set) var projectCreationWorkflow: ProjectCreationWorkflow?
    private(set) var mediaUploadWorkflow: MediaUploadWorkflow?
    private(set) var storyDraftWorkflow: StoryDraftWorkflow?
    private(set) var previewGenerationWorkflow: PreviewGenerationWorkflow?
    private(set) var finalRenderWorkflow: FinalRenderWorkflow?
    let operationRunner = MomentsCreateOperationRunner()
    var cancellables = Set<AnyCancellable>()

    var activeProject: MomentDraftProject? {
        if usesFullUITestFixture {
            return MomentsCreateUITestFixtures.project
        }

        return activeWorkspace?.project
    }

    var activeProjectId: String? {
        activeProject?.id ?? workflowActiveProjectId
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
        self.projectCreationWorkflow = projectCreationWorkflow
        self.mediaUploadWorkflow = mediaUploadWorkflow
        self.storyDraftWorkflow = storyDraftWorkflow
        self.previewGenerationWorkflow = previewGenerationWorkflow
        self.finalRenderWorkflow = finalRenderWorkflow
        templates = projectCreationWorkflow.launchTemplates
        form = MomentDraftForm(template: projectCreationWorkflow.launchTemplates[0])
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

    func clearSessionState() {
        resetActiveProject(force: true)
    }

    func prepareNewDraftCreation() {
        isContinuingProject = false
        continuationFocusHint = nil
    }

    func continueProject(_ project: MomentDraftProject, focus: MomentsProjectContinuationFocus = .review) {
        cancelOperations()
        isContinuingProject = true
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
        storyStatusMessage = "Story draft ready for preview."
        activeWorkspace = workspace
        latestPreview = workspace.latestArtifact(kind: "preview")
        latestPreviewJob = workspace.latestRenderJob(kind: "preview")
        previewStatusMessage = "Preview is available with watermark."
        finalExport = workspace.latestArtifact(kind: "final")
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
        effectiveActiveWorkspace?.latestArtifact(kind: "final") ?? finalExport
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
    }
}

extension MomentsCreateViewModel {
    func applyAccountState(_ state: MomentsCreateAccountState) {
        isSignedIn = state.isSignedIn
        balance = state.balance
    }

    func applyProjectCreationState(_ state: MomentsCreateProjectCreationState) {
        guard !usesFullUITestFixture else { return }
        isCreatingDraft = state.isCreatingDraft
        workflowActiveProjectId = state.activeProjectId
        draftErrorMessage = state.draftErrorMessage
    }

    func applyMediaUploadState(_ state: MomentsCreateMediaUploadState) {
        guard !usesFullUITestFixture else { return }
        selectedMedia = state.selectedMedia
        mediaStatusMessage = state.statusMessage
        isImportingMedia = state.isImporting
    }

    func applyStoryDraftState(_ state: MomentsCreateStoryDraftState) {
        guard !usesFullUITestFixture else { return }
        savedScenes = state.savedScenes
        generatedScenes = state.generatedScenes
        storyStatusMessage = state.statusMessage
        isDraftingStory = state.isDrafting
    }

    func applyPreviewGenerationState(_ state: MomentsCreatePreviewGenerationState) {
        guard !usesFullUITestFixture else { return }
        activeWorkspace = state.activeWorkspace
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
        finalRenderStatusMessage = state.statusMessage
        isGeneratingFinalRender = state.isGenerating
        isRefreshingFinalRenderStatus = state.isRefreshingStatus
    }
}
