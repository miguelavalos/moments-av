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

struct MomentsCreateFinalRenderPresentation: Equatable {
    var summary: MomentsCreateFinalRenderSummary
    var canGenerateFinalRender = false
    var canRefreshFinalRenderStatus = false
    var availabilityMessage: String?
    var refreshAvailabilityMessage: String?

    var creditTitle: String {
        MomentsCreditCopy.countTitle(summary.renderPlan?.plan.totalCreditCost ?? summary.creditCost)
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? L10n.string("create.final.action.refreshing") : L10n.string("create.final.action.refresh")
    }

    var generateButtonTitle: String {
        if summary.isGenerating {
            return L10n.string("create.final.action.creating")
        }
        return summary.renderPlan == nil
            ? L10n.string("create.final.createVideo")
            : L10n.string("create.final.createWithCost", creditTitle)
    }

    var emptyMessage: String {
        guard canGenerateFinalRender else {
            return L10n.string("create.final.empty.prepareStory")
        }
        return summary.renderPlan == nil
            ? L10n.string("create.final.empty.createVideo")
            : L10n.string("create.final.empty.ready")
    }

    var showsEmptyState: Bool {
        summary.finalExport == nil && summary.latestFinalJob == nil
    }

    var creditPolicyMessage: String {
        summary.renderPlan == nil
            ? L10n.string("create.final.creditPolicy.preflight")
            : L10n.string("create.final.creditPolicy.create", creditTitle)
    }
}

struct MomentsCreateFinalVideoActionPresentation: Equatable {
    var summary: MomentsCreateFinalRenderSummary
    var template: MomentTemplate
    var balance: MomentsCreditBalance
    var removesWatermark = false

    var hasRenderPlan: Bool {
        summary.renderPlan != nil
    }

    var totalCreditCost: Int {
        if let backendCost = summary.renderPlan?.plan.totalCreditCost {
            return backendCost
        }
        return MomentsCreditGate.finalRenderCreditCost(
            template: template,
            removesWatermark: removesWatermark,
            balance: balance
        )
    }

    var totalCreditCostTitle: String {
        MomentsCreditCopy.countTitle(totalCreditCost)
    }

    var primaryTitle: String {
        hasRenderPlan
            ? L10n.string("create.final.createWithCost", totalCreditCostTitle)
            : L10n.string("create.final.createVideo")
    }

    var primaryIconName: String {
        "video.fill"
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
        return MomentsCreditGate.canAffordFinalRender(
            template: template,
            removesWatermark: removesWatermark,
            balance: balance
        )
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
            return canRefreshFinalRender
        }
        if hasFinalVideoIntent {
            return workflow.canGenerateFinalRender
                || canPrepareVideoPlan
                || workflow.canPlanStory
                || needsSignInForStory
        }
        if workflow.previewSummary.latestPreviewJob != nil {
            return workflow.canRefreshPreviewStatus
        }
        return workflow.canPlanStory || needsSignInForStory
    }

    var title: String {
        if workflow.finalRenderSummary.finalExport != nil || workflow.finalRenderSummary.latestFinalJob != nil {
            return L10n.string("create.final.video")
        }
        if hasFinalVideoIntent {
            return L10n.string("create.final.createVideoTitle")
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
                : L10n.string("create.final.checkStatus")
        }
        if workflow.finalRenderSummary.isGenerating {
            return L10n.string("create.final.creating")
        }
        if hasFinalVideoIntent {
            return finalVideoAction.primaryTitle
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
            return "arrow.clockwise"
        }
        if hasFinalVideoIntent {
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
            if finalVideoAction.hasRenderPlan {
                return finalVideoAction.creditPolicyMessage
            }
            if workflow.canGenerateFinalRender || canPrepareVideoPlan || workflow.canPlanStory {
                return L10n.string("create.primary.createVideoPreflight")
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
            return L10n.string("create.primary.createVideoPreflight")
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
            return "arrow.clockwise"
        }
        if needsSignInForStory {
            return "person.crop.circle.badge.checkmark"
        }
        return "video.fill"
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

    var canRefreshFinalRender: Bool {
        workflow.finalRenderSummary.latestFinalJob != nil
            && workflow.canRefreshFinalRenderStatus
    }

    var needsSignInForStory: Bool {
        !workflow.isSignedIn
            && workflow.mediaSummary.reviewCount > 0
            && !workflow.storySummary.isPlanning
    }

    private var availabilityMessage: String? {
        if workflow.finalRenderSummary.latestFinalJob != nil {
            return workflow.finalRenderRefreshAvailabilityMessage ?? workflow.finalRenderAvailabilityMessage
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
}
