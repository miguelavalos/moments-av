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
    @Published private(set) var createdProjectId: String?
    @Published private(set) var draftErrorMessage: String?
    @Published private(set) var selectedMedia: [MomentsSelectedMedia] = []
    @Published private(set) var mediaStatusMessage: String?
    @Published private(set) var isImportingMedia = false
    @Published private(set) var savedScenes: [MomentStoryScene] = []
    @Published private(set) var generatedScenes: [MomentsStoryDraftScene] = []
    @Published private(set) var storyStatusMessage: String?
    @Published private(set) var isDraftingStory = false
    @Published private(set) var activeWorkspace: MomentProjectWorkspace?
    @Published private(set) var activeProject: MomentDraftProject?
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
    var cancellables = Set<AnyCancellable>()
    var operationTasks: [UUID: Task<Void, Never>] = [:]

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

        bindAccount(accountStateProvider)
        bindProjectCreation(projectCreationWorkflow)
        bindMediaUpload(mediaUploadWorkflow)
        bindStoryDraft(storyDraftWorkflow)
        bindPreviewGeneration(previewGenerationWorkflow)
        bindFinalRender(finalRenderWorkflow)
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

        if let template = templates.first(where: { $0.id == project.template }) {
            form = MomentDraftForm(
                template: template,
                occasion: project.occasion ?? "",
                recipient: "",
                tone: MomentDraftTone(rawValue: project.tone ?? "") ?? .warm,
                tempo: MomentDraftTempo(rawValue: project.tempo ?? "") ?? .balanced,
                details: project.details ?? ""
            )
        }

        projectCreationWorkflow?.continueProject(project)
    }

    func consumePendingFocus() {
        pendingFocus = nil
    }

    func clearContinuationFocusHint() {
        continuationFocusHint = nil
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
        isCreatingDraft = state.isCreatingDraft
        createdProjectId = state.createdProjectId
        draftErrorMessage = state.draftErrorMessage
    }

    func applyMediaUploadState(_ state: MomentsCreateMediaUploadState) {
        selectedMedia = state.selectedMedia
        mediaStatusMessage = state.statusMessage
        isImportingMedia = state.isImporting
    }

    func applyStoryDraftState(_ state: MomentsCreateStoryDraftState) {
        savedScenes = state.savedScenes
        generatedScenes = state.generatedScenes
        storyStatusMessage = state.statusMessage
        isDraftingStory = state.isDrafting
    }

    func applyPreviewGenerationState(_ state: MomentsCreatePreviewGenerationState) {
        activeWorkspace = state.activeWorkspace
        activeProject = state.activeWorkspace?.project
        latestPreview = state.latestPreview
        latestPreviewJob = state.latestPreviewJob
        previewStatusMessage = state.statusMessage
        isGeneratingPreview = state.isGenerating
        isRefreshingPreviewStatus = state.isRefreshingStatus
    }

    func applyFinalRenderState(_ state: MomentsCreateFinalRenderState) {
        finalExport = state.finalExport
        latestFinalJob = state.latestFinalJob
        finalRenderStatusMessage = state.statusMessage
        isGeneratingFinalRender = state.isGenerating
        isRefreshingFinalRenderStatus = state.isRefreshingStatus
    }
}
