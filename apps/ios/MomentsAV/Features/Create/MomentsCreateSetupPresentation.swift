import Foundation

struct MomentsCreateSetupPresentation: Equatable {
    var templateSummary: MomentsCreateTemplateSummaryPresentation
    var isDraftLocked = false
    var isCreatingMoment = false
    var canCreateDraft = false
    var availabilityMessage: String?
    var activeMomentId: String?
    var isContinuingMoment = false
    var canStartAnotherProject = false
    var setupErrorMessage: String?
    var workspaceSummary: MomentsCreateWorkspaceSummary

    var createMomentTitle: String {
        isCreatingMoment ? L10n.string("create.moment.action.starting") : L10n.string("create.moment.action.useTheme")
    }

    var activeMomentLabel: String {
        isContinuingMoment ? L10n.string("create.moment.active.continuing") : L10n.string("create.moment.active.ready")
    }

    var activeMomentDetail: String {
        isContinuingMoment
            ? L10n.string("create.moment.active.attached")
            : L10n.string("create.moment.active.nextMedia")
    }

    var showsActiveMoment: Bool {
        activeMomentId != nil
    }

    static func make(
        template: MomentTemplate,
        canAfford: Bool,
        spendPlanDescription: String,
        isDraftLocked: Bool,
        isCreatingMoment: Bool,
        canCreateDraft: Bool,
        availabilityMessage: String?,
        activeMomentId: String?,
        isContinuingMoment: Bool,
        canStartAnotherProject: Bool,
        setupErrorMessage: String?,
        workspaceSummary: MomentsCreateWorkspaceSummary
    ) -> MomentsCreateSetupPresentation {
        MomentsCreateSetupPresentation(
            templateSummary: MomentsCreateTemplateSummaryPresentation(
                template: template,
                canAfford: canAfford,
                spendPlanDescription: spendPlanDescription
            ),
            isDraftLocked: isDraftLocked,
            isCreatingMoment: isCreatingMoment,
            canCreateDraft: canCreateDraft,
            availabilityMessage: availabilityMessage,
            activeMomentId: activeMomentId,
            isContinuingMoment: isContinuingMoment,
            canStartAnotherProject: canStartAnotherProject,
            setupErrorMessage: setupErrorMessage,
            workspaceSummary: workspaceSummary
        )
    }
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
