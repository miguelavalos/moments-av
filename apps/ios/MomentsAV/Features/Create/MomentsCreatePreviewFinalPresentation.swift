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
        MomentsCreditCopy.countTitle(summary.creditCost)
    }

    var refreshButtonTitle: String {
        summary.isRefreshingStatus ? L10n.string("create.final.action.refreshing") : L10n.string("create.final.action.refresh")
    }

    var generateButtonTitle: String {
        if summary.isGenerating {
            return L10n.string("create.final.action.creating")
        }
        return summary.renderPlan == nil
            ? L10n.string("create.final.preparePlan")
            : L10n.string("create.final.createWithCost", creditTitle)
    }

    var emptyMessage: String {
        guard canGenerateFinalRender else {
            return L10n.string("create.final.empty.prepareStory")
        }
        return summary.renderPlan == nil
            ? L10n.string("create.final.empty.preparePlan")
            : L10n.string("create.final.empty.ready")
    }

    var showsEmptyState: Bool {
        summary.finalExport == nil && summary.latestFinalJob == nil
    }

    var creditPolicyMessage: String {
        summary.renderPlan == nil
            ? L10n.string("create.final.creditPolicy.plan")
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
        MomentsCreditGate.finalRenderCreditCost(
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
            : L10n.string("create.final.preparePlan")
    }

    var primaryIconName: String {
        hasRenderPlan ? "video.fill" : "checklist"
    }

    var stepTitle: String {
        hasRenderPlan
            ? L10n.string("create.final.step.create")
            : L10n.string("create.final.step.plan")
    }

    var stepDetail: String {
        hasRenderPlan
            ? L10n.string("create.final.step.createDetail", totalCreditCostTitle)
            : L10n.string("create.final.step.planDetail")
    }

    var stepBadgeTitle: String {
        hasRenderPlan ? totalCreditCostTitle : L10n.string("create.final.step.noCredits")
    }

    var stepIconName: String {
        hasRenderPlan ? "creditcard.fill" : "checklist"
    }

    var creditPolicyMessage: String {
        hasRenderPlan
            ? L10n.string("create.final.creditPolicy.create", totalCreditCostTitle)
            : L10n.string("create.final.creditPolicy.plan")
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
        MomentsCreditGate.canAffordFinalRender(
            template: template,
            removesWatermark: removesWatermark,
            balance: balance
        )
    }
}
