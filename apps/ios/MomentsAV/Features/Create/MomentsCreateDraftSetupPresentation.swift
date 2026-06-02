import Foundation

struct MomentsCreateDraftSetupPresentation: Equatable {
    var templateSummary: MomentsCreateTemplateSummaryPresentation
    var isDraftLocked = false
    var isCreatingDraft = false
    var canCreateDraft = false
    var availabilityMessage: String?
    var activeMomentId: String?
    var isContinuingMoment = false
    var canStartAnotherProject = false
    var draftErrorMessage: String?
    var workspaceSummary: MomentsCreateWorkspaceSummary

    var createDraftTitle: String {
        isCreatingDraft ? L10n.string("create.draft.action.starting") : L10n.string("create.draft.action.useTheme")
    }

    var activeProjectLabel: String {
        isContinuingMoment ? L10n.string("create.draft.active.continuing") : L10n.string("create.draft.active.ready")
    }

    var activeProjectDetail: String {
        isContinuingMoment
            ? L10n.string("create.draft.active.attached")
            : L10n.string("create.draft.active.nextMedia")
    }

    var showsActiveProject: Bool {
        activeMomentId != nil
    }

    static func make(
        template: MomentTemplate,
        canAfford: Bool,
        spendPlanDescription: String,
        isDraftLocked: Bool,
        isCreatingDraft: Bool,
        canCreateDraft: Bool,
        availabilityMessage: String?,
        activeMomentId: String?,
        isContinuingMoment: Bool,
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
            activeMomentId: activeMomentId,
            isContinuingMoment: isContinuingMoment,
            canStartAnotherProject: canStartAnotherProject,
            draftErrorMessage: draftErrorMessage,
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
