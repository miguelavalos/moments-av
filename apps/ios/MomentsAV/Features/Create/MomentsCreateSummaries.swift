import Foundation

enum MomentsCreateAvailabilityCopy {
    static let draftSignInRequired = "Sign in before creating a draft."
    static let projectSyncNotConfigured = "Project sync is not configured for this build."
    static let mediaMissingProject = "Create or continue a draft before adding media."
    static let mediaUploadNotConfigured = "Media upload is not configured for this build."
    static let mediaTemplateFull = "Remove media before adding more to this template."
    static let storyMissingProject = "Create or continue a draft before generating a story."
    static let storyUnavailable = "Story drafting is not available yet."
    static let storyNotConfigured = "Story drafting is not configured for this build."
    static let storyMissingMedia = "Wait for synced media before drafting."
    static let previewMissingProject = "Create or continue a draft before generating a preview."
    static let previewUnavailable = "Preview generation is not available yet."
    static let previewNotConfigured = "Preview generation is not configured for this build."
    static let previewMissingWorkspace = "Wait for the project workspace to sync before generating a preview."
    static let finalRenderMissingProject = "Create or continue a draft before rendering the final export."
    static let finalRenderUnavailable = "Final rendering is not available yet."
    static let finalRenderNotConfigured = "Final rendering is not configured for this build."
    static let finalRenderMissingWorkspace = "Wait for the project workspace to sync before rendering the final export."

    static func previewInsufficientCredits(missingCredits: Int) -> String {
        "Add \(missingCredits) more \(MomentsCreditCopy.noun(missingCredits)) before generating a preview."
    }

    static func finalRenderInsufficientCredits(missingCredits: Int) -> String {
        "Add \(missingCredits) more \(MomentsCreditCopy.noun(missingCredits)) before final render."
    }
}

enum MomentsCreateRefreshAvailabilityFactory {
    static func preview(
        projectId: String?,
        job: MomentRenderJob?,
        isAvailable: Bool,
        isConfigured: Bool,
        isRefreshing: Bool
    ) -> RenderJobStatusRefreshAvailability {
        RenderJobStatusRefreshAvailability(
            projectId: projectId,
            job: job,
            isAvailable: isAvailable,
            isConfigured: isConfigured,
            isRefreshing: isRefreshing,
            unavailableMessage: "Preview status refresh is not available yet.",
            notConfiguredMessage: "Preview status refresh is not configured for this build.",
            missingProjectMessage: "Open a project before refreshing preview status.",
            missingJobMessage: "No preview render job is available yet.",
            missingProviderRequestMessage: "Preview status is missing its provider request id."
        )
    }

    static func finalRender(
        projectId: String?,
        job: MomentRenderJob?,
        isAvailable: Bool,
        isConfigured: Bool,
        isRefreshing: Bool
    ) -> RenderJobStatusRefreshAvailability {
        RenderJobStatusRefreshAvailability(
            projectId: projectId,
            job: job,
            isAvailable: isAvailable,
            isConfigured: isConfigured,
            isRefreshing: isRefreshing,
            unavailableMessage: "Final status refresh is not available yet.",
            notConfiguredMessage: "Final status refresh is not configured for this build.",
            missingProjectMessage: "Open a project before refreshing final status.",
            missingJobMessage: "No final render job is available yet.",
            missingProviderRequestMessage: "Final render status is missing its provider request id."
        )
    }
}

enum MomentsCreateAvailabilityMessageFactory {
    static func draft(
        isDraftLocked: Bool,
        isSignedIn: Bool,
        isProjectCreationConfigured: Bool,
        draftFormAvailability: MomentDraftRules.Availability
    ) -> String? {
        if isDraftLocked { return nil }
        if !isSignedIn { return MomentsCreateAvailabilityCopy.draftSignInRequired }
        if !isProjectCreationConfigured { return MomentsCreateAvailabilityCopy.projectSyncNotConfigured }
        return MomentDraftRules.availabilityMessage(draftFormAvailability)
    }

    static func media(
        activeProjectId: String?,
        isImportingMedia: Bool,
        isMediaUploadConfigured: Bool,
        mediaRemainingSlots: Int
    ) -> String? {
        if activeProjectId == nil { return MomentsCreateAvailabilityCopy.mediaMissingProject }
        if isImportingMedia { return nil }
        if !isMediaUploadConfigured { return MomentsCreateAvailabilityCopy.mediaUploadNotConfigured }
        if mediaRemainingSlots == 0 { return MomentsCreateAvailabilityCopy.mediaTemplateFull }
        return nil
    }

    static func story(
        activeProjectId: String?,
        isStoryDrafting: Bool,
        isStoryDraftAvailable: Bool,
        isStoryDraftConfigured: Bool,
        mediaAssets: [MomentMediaAsset]?,
        template: MomentTemplate
    ) -> String? {
        guard activeProjectId != nil else { return MomentsCreateAvailabilityCopy.storyMissingProject }
        guard isStoryDraftAvailable else { return MomentsCreateAvailabilityCopy.storyUnavailable }
        if isStoryDrafting { return nil }
        if !isStoryDraftConfigured { return MomentsCreateAvailabilityCopy.storyNotConfigured }

        return MomentsStoryDraftRules.availabilityMessage(
            MomentsStoryDraftRules.availability(
                mediaAssets: mediaAssets,
                template: template
            ),
            missingMediaMessage: MomentsCreateAvailabilityCopy.storyMissingMedia
        )
    }

    static func preview(
        activeProjectId: String?,
        isPreviewGenerationAvailable: Bool,
        isPreviewGenerating: Bool,
        isPreviewGenerationConfigured: Bool,
        project: MomentDraftProject?,
        template: MomentTemplate,
        balance: MomentsCreditBalance
    ) -> String? {
        guard activeProjectId != nil else { return MomentsCreateAvailabilityCopy.previewMissingProject }
        guard isPreviewGenerationAvailable else { return MomentsCreateAvailabilityCopy.previewUnavailable }
        if isPreviewGenerating { return nil }
        if !isPreviewGenerationConfigured { return MomentsCreateAvailabilityCopy.previewNotConfigured }
        return MomentsPreviewRules.availabilityMessage(
            MomentsPreviewRules.availability(
                project: project,
                template: template,
                balance: balance
            ),
            missingProjectMessage: MomentsCreateAvailabilityCopy.previewMissingWorkspace,
            insufficientCreditsMessage: MomentsCreateAvailabilityCopy.previewInsufficientCredits(
                missingCredits: missingCredits(template: template, balance: balance)
            )
        )
    }

    static func finalRender(
        activeProjectId: String?,
        isFinalRenderAvailable: Bool,
        isFinalRenderGenerating: Bool,
        isFinalRenderConfigured: Bool,
        project: MomentDraftProject?,
        template: MomentTemplate,
        balance: MomentsCreditBalance,
        latestPreview: MomentArtifact?
    ) -> String? {
        guard activeProjectId != nil else { return MomentsCreateAvailabilityCopy.finalRenderMissingProject }
        guard isFinalRenderAvailable else { return MomentsCreateAvailabilityCopy.finalRenderUnavailable }
        if isFinalRenderGenerating { return nil }
        if !isFinalRenderConfigured { return MomentsCreateAvailabilityCopy.finalRenderNotConfigured }
        return MomentsFinalRenderRules.availabilityMessage(
            MomentsFinalRenderRules.availability(
                project: project,
                template: template,
                balance: balance,
                latestPreview: latestPreview
            ),
            missingProjectMessage: MomentsCreateAvailabilityCopy.finalRenderMissingWorkspace,
            insufficientCreditsMessage: MomentsCreateAvailabilityCopy.finalRenderInsufficientCredits(
                missingCredits: missingCredits(template: template, balance: balance)
            )
        )
    }

    private static func missingCredits(template: MomentTemplate, balance: MomentsCreditBalance) -> Int {
        max(template.creditCost - balance.spendable, 0)
    }
}

struct MomentsCreateWorkflowPresentation: Equatable {
    var activeProjectId: String?
    var template: MomentTemplate
    var mediaSummary: MomentsCreateMediaSummary
    var storySummary: MomentsCreateStorySummary
    var previewSummary: MomentsCreatePreviewSummary
    var finalRenderSummary: MomentsCreateFinalRenderSummary
    var canAddMedia = false
    var canDraftStory = false
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
    var mediaAvailabilityMessage: String?
    var storyAvailabilityMessage: String?
    var previewAvailabilityMessage: String?
    var previewRefreshAvailabilityMessage: String?
    var finalRenderAvailabilityMessage: String?
    var finalRenderRefreshAvailabilityMessage: String?

    var showsWorkflowCards: Bool {
        activeProjectId != nil
    }

    static func make(
        activeProjectId: String?,
        template: MomentTemplate,
        mediaSummary: MomentsCreateMediaSummary,
        storySummary: MomentsCreateStorySummary,
        previewSummary: MomentsCreatePreviewSummary,
        finalRenderSummary: MomentsCreateFinalRenderSummary,
        availability: MomentsCreateWorkflowAvailability
    ) -> MomentsCreateWorkflowPresentation {
        MomentsCreateWorkflowPresentation(
            activeProjectId: activeProjectId,
            template: template,
            mediaSummary: mediaSummary,
            storySummary: storySummary,
            previewSummary: previewSummary,
            finalRenderSummary: finalRenderSummary,
            canAddMedia: availability.canAddMedia,
            canDraftStory: availability.canDraftStory,
            canGeneratePreview: availability.canGeneratePreview,
            canRefreshPreviewStatus: availability.canRefreshPreviewStatus,
            canGenerateFinalRender: availability.canGenerateFinalRender,
            canRefreshFinalRenderStatus: availability.canRefreshFinalRenderStatus,
            mediaAvailabilityMessage: availability.mediaMessage,
            storyAvailabilityMessage: availability.storyMessage,
            previewAvailabilityMessage: availability.previewMessage,
            previewRefreshAvailabilityMessage: availability.previewRefreshMessage,
            finalRenderAvailabilityMessage: availability.finalRenderMessage,
            finalRenderRefreshAvailabilityMessage: availability.finalRenderRefreshMessage
        )
    }
}

struct MomentsCreateDraftSetupPresentation: Equatable {
    var templateSummary: MomentsCreateTemplateSummaryPresentation
    var isDraftLocked = false
    var isCreatingDraft = false
    var canCreateDraft = false
    var availabilityMessage: String?
    var activeProjectId: String?
    var isContinuingProject = false
    var canStartAnotherProject = false
    var draftErrorMessage: String?
    var workspaceSummary: MomentsCreateWorkspaceSummary

    var createDraftTitle: String {
        isCreatingDraft ? "Creating draft..." : "Create draft"
    }

    var activeProjectLabel: String {
        isContinuingProject ? "Continuing project" : "Draft created"
    }

    var activeProjectDetail: String {
        isContinuingProject
            ? "Create is attached to this existing project."
            : "Draft setup is locked for this project."
    }

    var showsActiveProject: Bool {
        activeProjectId != nil
    }

    static func make(
        template: MomentTemplate,
        canAfford: Bool,
        spendPlanDescription: String,
        isDraftLocked: Bool,
        isCreatingDraft: Bool,
        canCreateDraft: Bool,
        availabilityMessage: String?,
        activeProjectId: String?,
        isContinuingProject: Bool,
        canStartAnotherProject: Bool,
        draftErrorMessage: String?,
        workspaceSummary: MomentsCreateWorkspaceSummary
    ) -> MomentsCreateDraftSetupPresentation {
        MomentsCreateDraftSetupPresentation(
            templateSummary: MomentsCreateTemplateSummaryPresentation(
                template: template,
                canAfford: canAfford,
                spendPlanDescription: spendPlanDescription
            ),
            isDraftLocked: isDraftLocked,
            isCreatingDraft: isCreatingDraft,
            canCreateDraft: canCreateDraft,
            availabilityMessage: availabilityMessage,
            activeProjectId: activeProjectId,
            isContinuingProject: isContinuingProject,
            canStartAnotherProject: canStartAnotherProject,
            draftErrorMessage: draftErrorMessage,
            workspaceSummary: workspaceSummary
        )
    }
}

struct MomentsCreateWorkflowAvailability: Equatable {
    var canAddMedia = false
    var canDraftStory = false
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
    var mediaMessage: String?
    var storyMessage: String?
    var previewMessage: String?
    var previewRefreshMessage: String?
    var finalRenderMessage: String?
    var finalRenderRefreshMessage: String?
}

struct MomentsCreateTemplateSummaryPresentation: Equatable {
    var template: MomentTemplate
    var canAfford = false
    var spendPlanDescription: String

    var creditTitle: String {
        "\(template.creditCost) cr"
    }

    var metadataTitle: String {
        "\(template.duration) · \(template.mediaRange)"
    }
}

struct MomentsCreateMediaPresentation: Equatable {
    var activeProjectId: String
    var template: MomentTemplate
    var summary: MomentsCreateMediaSummary
    var canAddMedia = false
    var availabilityMessage: String?

    var remainingSlots: Int {
        summary.remainingSlots(template: template)
    }

    var pickerTitle: String {
        summary.isImporting ? "Importing media..." : "Add Photos or Clips"
    }

    var selectedCountTitle: String {
        "Selected \(summary.selectedCount)/\(template.mediaRange)"
    }

    var selectionMessage: String {
        MomentsMediaRules.selectionMessage(
            MomentsMediaRules.availability(template: template, selectedCount: summary.selectedCount),
            tooFewMessage: { "Add \($0) more synced \(Self.mediaAssetLabel($0))." },
            tooManyMessage: { "Remove \($0) synced \(Self.mediaAssetLabel($0))." }
        )
    }

    var syncedMediaAssets: [MomentMediaAsset] {
        summary.syncedMediaAssets.sorted { $0.sortOrder < $1.sortOrder }
    }

    private static func mediaAssetLabel(_ count: Int) -> String {
        count == 1 ? "media asset" : "media assets"
    }
}

struct MomentsCreateStoryPresentation: Equatable {
    var summary: MomentsCreateStorySummary
    var canDraftStory = false
    var availabilityMessage: String?

    var draftButtonTitle: String {
        summary.isDrafting ? "Drafting story..." : "Ask Avi for story draft"
    }

    var emptyMessage: String {
        canDraftStory
            ? "Avi can draft the first story from the synced media."
            : "Add enough synced media before generating a story draft."
    }

    var savedScenes: [MomentStoryScene] {
        summary.savedScenes.sorted { $0.sceneIndex < $1.sceneIndex }
    }
}

struct MomentsCreatePreviewPresentation: Equatable {
    var summary: MomentsCreatePreviewSummary
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var availabilityMessage: String?
    var refreshAvailabilityMessage: String?

    var usageTitle: String? {
        summary.activeProject.map(MomentsProjectFormatting.previewUsage)
    }

    var previewArtifactMessage: String? {
        guard let latestPreview = summary.latestPreview else {
            return nil
        }
        return latestPreview.hasWatermark == true
            ? "Includes a subtle Moments AV mark."
            : "Preview artifact is available."
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? "Refreshing preview status..." : "Refresh preview status"
    }

    var generateButtonTitle: String {
        summary.isGenerating ? "Generating preview..." : "Generate preview"
    }

    var emptyMessage: String {
        canGeneratePreview
            ? "Story is ready. Generate a preview to review the result."
            : "Generate a story draft before creating a preview."
    }

    var showsEmptyState: Bool {
        summary.latestPreview == nil && summary.latestPreviewJob == nil
    }
}

struct MomentsCreateFinalRenderPresentation: Equatable {
    var summary: MomentsCreateFinalRenderSummary
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
    var availabilityMessage: String?
    var refreshAvailabilityMessage: String?

    var creditTitle: String {
        MomentsCreditCopy.countTitle(summary.creditCost)
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? "Refreshing final status..." : "Refresh final status"
    }

    var generateButtonTitle: String {
        summary.isGenerating ? "Rendering final..." : "Render final"
    }

    var emptyMessage: String {
        canGenerateFinalRender
            ? "Preview is ready. Render the final export when approved."
            : "Generate a preview before rendering the final export."
    }

    var showsEmptyState: Bool {
        summary.finalExport == nil && summary.latestFinalJob == nil
    }
}

struct MomentsCreateWorkspaceSummary: Equatable {
    var mediaCount = 0
    var sceneCount = 0
    var renderJobCount = 0
    var hasPreviewArtifact = false
    var hasFinalExport = false

    var mediaDetail: String {
        "\(mediaCount) synced"
    }

    var storyDetail: String {
        Self.countTitle(sceneCount, singular: "scene", plural: "scenes")
    }

    var previewDetail: String {
        hasPreviewArtifact ? "Ready" : Self.countTitle(renderJobCount, singular: "render job", plural: "render jobs")
    }

    static func make(
        workspace: MomentProjectWorkspace?,
        latestPreview: MomentArtifact?,
        finalExport: MomentArtifact?
    ) -> MomentsCreateWorkspaceSummary {
        MomentsCreateWorkspaceSummary(
            mediaCount: workspace?.mediaAssets.count ?? 0,
            sceneCount: workspace?.storyScenes.count ?? 0,
            renderJobCount: workspace?.renderJobs.count ?? 0,
            hasPreviewArtifact: latestPreview != nil,
            hasFinalExport: finalExport != nil
        )
    }

    private static func countTitle(_ count: Int, singular: String, plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }
}

struct MomentsCreateMediaSummary: Equatable {
    var selectedMedia: [MomentsSelectedMedia] = []
    var syncedMediaAssets: [MomentMediaAsset] = []
    var isImporting = false
    var statusMessage: String?

    var selectedCount: Int {
        MomentsMediaRules.selectedCount(
            localMedia: selectedMedia,
            syncedMedia: syncedMediaAssets
        )
    }

    func remainingSlots(template: MomentTemplate) -> Int {
        MomentsMediaRules.remainingSlots(template: template, selectedCount: selectedCount)
    }
}

struct MomentsCreateStorySummary: Equatable {
    var savedScenes: [MomentStoryScene] = []
    var generatedScenes: [MomentsStoryDraftScene] = []
    var isDrafting = false
    var statusMessage: String?
}

struct MomentsCreatePreviewSummary: Equatable {
    var activeProject: MomentDraftProject?
    var latestPreview: MomentArtifact?
    var latestPreviewJob: MomentRenderJob?
    var isGenerating = false
    var isRefreshingStatus = false
    var statusMessage: String?
}

struct MomentsCreateFinalRenderSummary: Equatable {
    var creditCost = 0
    var finalExport: MomentArtifact?
    var latestFinalJob: MomentRenderJob?
    var isGenerating = false
    var isRefreshingStatus = false
    var statusMessage: String?
}
