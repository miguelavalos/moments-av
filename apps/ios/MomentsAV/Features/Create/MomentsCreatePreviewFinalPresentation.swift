import Foundation

struct MomentsCreatePreviewPresentation: Equatable {
    var summary: MomentsCreatePreviewSummary
    var canGeneratePreview = false
    var canRefreshPreviewStatus = false
    var availabilityMessage: String?
    var refreshAvailabilityMessage: String?

    var usageTitle: String? {
        summary.activeMoment.map(MomentsMomentFormatting.previewUsage)
    }

    var previewArtifactMessage: String? {
        guard let latestPreview = summary.latestPreview else {
            return nil
        }
        return latestPreview.hasWatermark == true
            ? L10n.string("create.preview.artifact.readyFinalCheck")
            : L10n.string("create.preview.status.available")
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? L10n.string("create.preview.action.refreshing") : L10n.string("create.preview.action.refresh")
    }

    var generateButtonTitle: String {
        summary.isGenerating ? L10n.string("create.preview.action.reviewing") : L10n.string("create.preview.action.review")
    }

    var emptyMessage: String {
        canGeneratePreview
            ? L10n.string("create.preview.empty.ready")
            : L10n.string("create.preview.empty.prepareStory")
    }

    var showsEmptyState: Bool {
        summary.latestPreview == nil && summary.latestPreviewJob == nil
    }
}

struct MomentsCreateFinalVideoActionPresentation: Equatable {
    var summary: MomentsCreateFinalRenderSummary
    var template: MomentTemplate
    var balance: MomentsCreditBalance
    var removesWatermark = false

    var hasRenderPlan: Bool {
        summary.renderPlan?.canCreateVideo == true
    }

    var hasBlockedRenderPlan: Bool {
        summary.renderPlan != nil && !hasRenderPlan
    }

    var blockedRenderPlanMessage: String? {
        guard hasBlockedRenderPlan else { return nil }
        let blockers = summary.renderPlan?.createVideoBlockers ?? []
        if blockers.contains("provider_adapter_unavailable") || blockers.contains("render_option_unavailable") {
            return L10n.string("create.final.blocker.providerUnavailable")
        }
        if blockers.contains("insufficient_credits") {
            return L10n.string("create.final.blocker.insufficientCredits")
        }
        if blockers.contains("no_usable_media") || blockers.contains("all_media_rejected") {
            return L10n.string("create.final.blocker.noUsableMedia")
        }
        return L10n.string("create.final.blocker.default")
    }

    var totalCreditCost: Int {
        summary.renderPlan?.plan.totalCreditCost ?? 0
    }

    var totalCreditCostTitle: String {
        MomentsCreditCopy.countTitle(totalCreditCost)
    }

    var primaryTitle: String {
        hasRenderPlan
            ? L10n.string("create.final.confirmCredits", totalCreditCostTitle)
            : L10n.string("create.final.reviewCost")
    }

    var primaryIconName: String {
        hasRenderPlan ? "video.fill" : "creditcard.fill"
    }

    var creditPolicyMessage: String {
        hasRenderPlan
            ? L10n.string("create.final.creditPolicy.create", totalCreditCostTitle)
            : L10n.string("create.final.creditPolicy.preflight")
    }

    var confirmationTitle: String {
        L10n.string("create.final.confirmTitle")
    }

    var confirmationActionTitle: String {
        L10n.string("create.final.createWithCost", totalCreditCostTitle)
    }

    var confirmationMessage: String {
        L10n.string("create.final.confirmMessage", totalCreditCostTitle)
    }

    var canAffordSelectedCost: Bool {
        if let backendCost = summary.renderPlan?.plan.totalCreditCost {
            return balance.spendable >= backendCost
        }
        return true
    }
}

struct MomentsCreatePrimaryActionPresentation: Equatable {
    var workflow: MomentsCreateWorkflowPresentation
    var finalVideoAction: MomentsCreateFinalVideoActionPresentation

    init(workflow: MomentsCreateWorkflowPresentation) {
        self.workflow = workflow
        self.finalVideoAction = MomentsCreateFinalVideoActionPresentation(
            summary: workflow.finalRenderSummary,
            template: workflow.template,
            balance: workflow.balance
        )
    }

    var canRunPrimaryAction: Bool {
        if isBusy {
            return false
        }
        if workflow.finalRenderSummary.pendingGalleryVideo != nil || workflow.finalRenderSummary.finalExport != nil {
            return false
        }
        if workflow.finalRenderSummary.latestFinalJob != nil {
            return false
        }
        if hasFinalVideoIntent {
            if finalVideoAction.hasBlockedRenderPlan {
                return false
            }
            if needsCreditsForPreparedPlan {
                return true
            }
            return workflow.canGenerateFinalRender
                || canPrepareVideoPlan
                || canPrepareLocalVideoPlan
                || workflow.canPlanStory
                || needsSignInForStory
        }
        if workflow.previewSummary.latestPreviewJob != nil {
            return workflow.canRefreshPreviewStatus
        }
        return workflow.canPlanStory || needsSignInForStory
    }

    var showsPrimaryActionButton: Bool {
        workflow.finalRenderSummary.pendingGalleryVideo == nil
            && workflow.finalRenderSummary.finalExport == nil
            && workflow.finalRenderSummary.latestFinalJob == nil
    }

    var title: String {
        if workflow.finalRenderSummary.finalExport != nil || workflow.finalRenderSummary.latestFinalJob != nil {
            return L10n.string("create.final.video")
        }
        if hasFinalVideoIntent {
            return finalVideoAction.hasRenderPlan
                ? L10n.string("create.final.readyToCreateTitle")
                : L10n.string("common.continue")
        }
        return L10n.string("common.continue")
    }

    var buttonTitle: String {
        if workflow.finalRenderSummary.pendingGalleryVideo != nil {
            return L10n.string("create.final.chooseDestination")
        }
        if workflow.finalRenderSummary.finalExport != nil {
            return L10n.string("create.final.videoReady")
        }
        if workflow.finalRenderSummary.latestFinalJob != nil {
            return workflow.finalRenderSummary.isRefreshingStatus
                ? L10n.string("create.status.checking")
                : L10n.string("create.final.video")
        }
        if workflow.finalRenderSummary.isGenerating {
            return L10n.string("create.final.creating")
        }
        if hasFinalVideoIntent, needsCreditsForPreparedPlan {
            return L10n.string("credits.get.title")
        }
        if hasFinalVideoIntent {
            if finalVideoAction.hasBlockedRenderPlan {
                return L10n.string("create.final.reviewCost")
            }
            return finalVideoAction.hasRenderPlan
                ? finalVideoAction.primaryTitle
                : L10n.string("common.continue")
        }
        if workflow.previewSummary.latestPreviewJob != nil {
            return workflow.previewSummary.isRefreshingStatus
                ? L10n.string("create.status.refreshing")
                : L10n.string("create.preview.refresh")
        }
        if needsSignInForStory {
            return L10n.string("common.signIn")
        }
        return finalVideoAction.primaryTitle
    }

    var buttonIconName: String {
        if workflow.finalRenderSummary.pendingGalleryVideo != nil {
            return "rectangle.stack.badge.play.fill"
        }
        if workflow.finalRenderSummary.finalExport != nil {
            return "checkmark.circle.fill"
        }
        if workflow.finalRenderSummary.latestFinalJob != nil {
            return "video.fill"
        }
        if hasFinalVideoIntent, needsCreditsForPreparedPlan {
            return "plus.circle.fill"
        }
        if hasFinalVideoIntent {
            if finalVideoAction.hasBlockedRenderPlan {
                return "exclamationmark.triangle.fill"
            }
            return finalVideoAction.primaryIconName
        }
        if workflow.previewSummary.latestPreviewJob != nil {
            return "arrow.clockwise"
        }
        if needsSignInForStory {
            return "person.crop.circle.badge.checkmark"
        }
        return finalVideoAction.primaryIconName
    }

    var statusMessage: String? {
        if workflow.finalRenderSummary.pendingGalleryVideo != nil {
            return workflow.finalRenderSummary.statusMessage
                ?? L10n.string("workflow.final.savedLocal")
        }
        if workflow.finalRenderSummary.isGenerating {
            return workflow.finalRenderSummary.statusMessage ?? L10n.string("create.final.action.creating")
        }
        if workflow.previewSummary.isGenerating {
            return workflow.previewSummary.statusMessage ?? L10n.string("create.preview.action.reviewing")
        }
        if workflow.storySummary.isPlanning {
            return workflow.storySummary.statusMessage ?? L10n.string("create.preparation.prepareStory.progress")
        }
        if workflow.mediaSummary.isImporting {
            return workflow.mediaSummary.statusMessage ?? L10n.string("workflow.media.uploading")
        }
        if workflow.finalRenderSummary.finalExport != nil {
            return L10n.string("create.primary.finalReady")
        }
        if workflow.finalRenderSummary.latestFinalJob != nil {
            return workflow.finalRenderSummary.realtimeStatus?.detail
                ?? workflow.finalRenderSummary.statusMessage
                ?? L10n.string("create.primary.videoCreating")
        }
        if hasFinalVideoIntent {
            if let blockedRenderPlanMessage = finalVideoAction.blockedRenderPlanMessage {
                return blockedRenderPlanMessage
            }
            if needsCreditsForPreparedPlan {
                return MomentsCreateAvailabilityCopy.finalRenderInsufficientCredits(
                    missingCredits: missingCreditsForPreparedPlan
                )
            }
            if let finalStatusMessage = workflow.finalRenderSummary.statusMessage,
               !finalStatusMessage.isEmpty,
               Self.isFinalRenderErrorMessage(finalStatusMessage) {
                return finalStatusMessage
            }
            if finalVideoAction.hasRenderPlan {
                return finalVideoAction.creditPolicyMessage
            }
            if let finalStatusMessage = workflow.finalRenderSummary.statusMessage,
               !finalStatusMessage.isEmpty {
                return finalStatusMessage
            }
            if workflow.canGenerateFinalRender || canPrepareVideoPlan || canPrepareLocalVideoPlan || workflow.canPlanStory {
                return L10n.string("create.primary.continuePreflight")
            }
            return availabilityMessage
        }
        if let previewMessage = workflow.previewSummary.statusMessage, !previewMessage.isEmpty {
            return previewMessage
        }
        if let storyMessage = workflow.storySummary.statusMessage, !storyMessage.isEmpty {
            return storyMessage
        }
        if let mediaMessage = workflow.mediaSummary.statusMessage, !mediaMessage.isEmpty {
            return mediaMessage
        }
        if !canRunPrimaryAction {
            return availabilityMessage
        }
        if needsSignInForStory {
            return workflow.storyAvailabilityMessage
        }
        if workflow.canPlanStory {
            return L10n.string("create.primary.continuePreflight")
        }
        return nil
    }

    var statusIconName: String {
        if isBusy {
            return "sparkles"
        }
        if workflow.finalRenderSummary.finalExport != nil || workflow.previewSummary.latestPreview != nil {
            return "checkmark.circle.fill"
        }
        if !canRunPrimaryAction {
            return "info.circle.fill"
        }
        return "play.circle.fill"
    }

    var primaryHeaderIconName: String {
        if workflow.finalRenderSummary.pendingGalleryVideo != nil {
            return "rectangle.stack.badge.play.fill"
        }
        if workflow.finalRenderSummary.finalExport != nil {
            return "checkmark.circle.fill"
        }
        if let realtimeStatus = workflow.finalRenderSummary.realtimeStatus {
            return realtimeStatus.systemImage
        }
        if workflow.finalRenderSummary.latestFinalJob != nil {
            return "video.fill"
        }
        if needsSignInForStory {
            return "person.crop.circle.badge.checkmark"
        }
        if hasFinalVideoIntent {
            return finalVideoAction.primaryIconName
        }
        return "creditcard.fill"
    }

    var hasFinalVideoIntent: Bool {
        workflow.mediaSummary.reviewCount > 0
            || workflow.storySummary.hasScenes
            || workflow.previewSummary.latestPreview != nil
            || workflow.finalRenderSummary.renderPlan != nil
            || workflow.finalRenderSummary.latestFinalJob != nil
            || workflow.finalRenderSummary.finalExport != nil
            || workflow.finalRenderSummary.pendingGalleryVideo != nil
    }

    var isBusy: Bool {
        workflow.mediaSummary.isImporting
            || workflow.storySummary.isPlanning
            || workflow.previewSummary.isGenerating
            || workflow.previewSummary.isRefreshingStatus
            || workflow.finalRenderSummary.isGenerating
            || workflow.finalRenderSummary.isRefreshingStatus
    }

    var canPrepareVideoPlan: Bool {
        workflow.canPrepareFinalRenderPlan
            && workflow.finalRenderSummary.renderPlan == nil
    }

    var canPrepareLocalVideoPlan: Bool {
        workflow.isSignedIn
            && workflow.mediaSummary.reviewCount > 0
            && workflow.finalRenderSummary.renderPlan == nil
    }

    var needsSignInForStory: Bool {
        !workflow.isSignedIn
            && workflow.mediaSummary.reviewCount > 0
            && !workflow.storySummary.isPlanning
    }

    var needsCreditsForPreparedPlan: Bool {
        finalVideoAction.hasRenderPlan && !finalVideoAction.canAffordSelectedCost
    }

    private var missingCreditsForPreparedPlan: Int {
        max(0, finalVideoAction.totalCreditCost - workflow.balance.spendable)
    }

    private var availabilityMessage: String? {
        if workflow.finalRenderSummary.latestFinalJob != nil {
            return workflow.finalRenderAvailabilityMessage
        }
        if hasFinalVideoIntent {
            return workflow.finalRenderAvailabilityMessage
                ?? workflow.storyAvailabilityMessage
                ?? workflow.mediaAvailabilityMessage
        }
        if workflow.previewSummary.latestPreviewJob != nil {
            return workflow.previewAvailabilityMessage
        }
        return workflow.finalRenderAvailabilityMessage ?? workflow.storyAvailabilityMessage
    }

    private static func isFinalRenderErrorMessage(_ message: String) -> Bool {
        let lowercased = message.lowercased()
        return lowercased.contains("couldn’t")
            || lowercased.contains("couldn't")
            || lowercased.contains("failed")
            || lowercased.contains("not configured")
            || lowercased.contains("not available")
            || lowercased.contains("sign in again")
            || lowercased.contains("try again")
            || lowercased.contains("changed")
    }
}
