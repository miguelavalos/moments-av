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
