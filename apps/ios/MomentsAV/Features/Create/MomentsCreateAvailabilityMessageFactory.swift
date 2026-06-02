import Foundation

enum MomentsCreateAvailabilityMessageFactory {
    static func draft(
        isDraftLocked: Bool,
        isSignedIn: Bool,
        isMomentCreationConfigured: Bool,
        draftFormAvailability: MomentDraftRules.Availability
    ) -> String? {
        if isDraftLocked { return nil }
        if !isSignedIn { return MomentsCreateAvailabilityCopy.draftSignInRequired }
        if !isMomentCreationConfigured { return MomentsCreateAvailabilityCopy.projectSyncNotConfigured }
        return MomentDraftRules.availabilityMessage(draftFormAvailability)
    }

    static func media(
        hasMomentWorkspace: Bool,
        isImportingMedia: Bool,
        isMediaUploadConfigured: Bool,
        mediaRemainingSlots: Int
    ) -> String? {
        if !hasMomentWorkspace { return MomentsCreateAvailabilityCopy.mediaMissingProject }
        if isImportingMedia { return nil }
        if !isMediaUploadConfigured { return MomentsCreateAvailabilityCopy.mediaUploadNotConfigured }
        if mediaRemainingSlots == 0 { return MomentsCreateAvailabilityCopy.mediaTemplateFull }
        return nil
    }

    static func story(
        isSignedIn: Bool,
        hasMomentWorkspace: Bool,
        isStoryDrafting: Bool,
        isStoryDraftAvailable: Bool,
        isStoryDraftConfigured: Bool,
        mediaAssets: [MomentMediaAsset]?,
        selectedMediaCount: Int,
        template: MomentTemplate
    ) -> String? {
        guard isSignedIn else { return MomentsCreateAvailabilityCopy.storySignInRequired }
        guard hasMomentWorkspace else { return MomentsCreateAvailabilityCopy.storyMissingProject }
        guard isStoryDraftAvailable else { return MomentsCreateAvailabilityCopy.storyUnavailable }
        if isStoryDrafting { return nil }
        if !isStoryDraftConfigured { return MomentsCreateAvailabilityCopy.storyNotConfigured }

        if selectedMediaCount > 0 {
            let availability = MomentsMediaRules.availability(template: template, selectedCount: selectedMediaCount)
            guard !availability.canUseSelection else { return nil }
            return MomentsMediaRules.selectionMessage(
                availability,
                tooFewMessage: { missingCount in
                    missingCount == 1
                        ? L10n.string("create.availability.media.addOne")
                        : L10n.string("create.availability.media.addMany", missingCount)
                },
                tooManyMessage: { extraCount in
                    extraCount == 1
                        ? L10n.string("create.availability.media.removeOne")
                        : L10n.string("create.availability.media.removeMany", extraCount)
                }
            )
        }

        return MomentsStoryDraftRules.availabilityMessage(
            MomentsStoryDraftRules.availability(
                mediaAssets: mediaAssets,
                template: template
            ),
            missingMediaMessage: MomentsCreateAvailabilityCopy.storyMissingMedia
        )
    }

    static func preview(
        activeMomentId: String?,
        isPreviewGenerationAvailable: Bool,
        isPreviewGenerating: Bool,
        isPreviewGenerationConfigured: Bool,
        moment: InProgressMoment?,
        template: MomentTemplate,
        balance: MomentsCreditBalance
    ) -> String? {
        guard activeMomentId != nil else { return MomentsCreateAvailabilityCopy.previewMissingProject }
        guard isPreviewGenerationAvailable else { return MomentsCreateAvailabilityCopy.previewUnavailable }
        if isPreviewGenerating { return nil }
        if !isPreviewGenerationConfigured { return MomentsCreateAvailabilityCopy.previewNotConfigured }
        return MomentsPreviewRules.availabilityMessage(
            MomentsPreviewRules.availability(
                moment: moment,
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
        activeMomentId: String?,
        isFinalRenderAvailable: Bool,
        isFinalRenderGenerating: Bool,
        isFinalRenderConfigured: Bool,
        moment: InProgressMoment?,
        template: MomentTemplate,
        balance: MomentsCreditBalance,
        latestPreview: MomentArtifact?
    ) -> String? {
        guard activeMomentId != nil else { return MomentsCreateAvailabilityCopy.finalRenderMissingProject }
        guard isFinalRenderAvailable else { return MomentsCreateAvailabilityCopy.finalRenderUnavailable }
        if isFinalRenderGenerating { return nil }
        if !isFinalRenderConfigured { return MomentsCreateAvailabilityCopy.finalRenderNotConfigured }
        return MomentsFinalRenderRules.availabilityMessage(
            MomentsFinalRenderRules.availability(
                moment: moment,
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
