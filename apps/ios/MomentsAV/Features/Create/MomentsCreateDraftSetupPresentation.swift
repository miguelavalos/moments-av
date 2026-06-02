import Foundation

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
        isCreatingDraft ? L10n.string("create.draft.action.starting") : L10n.string("create.draft.action.useTheme")
    }

    var activeProjectLabel: String {
        isContinuingProject ? L10n.string("create.draft.active.continuing") : L10n.string("create.draft.active.ready")
    }

    var activeProjectDetail: String {
        isContinuingProject
            ? L10n.string("create.draft.active.attached")
            : L10n.string("create.draft.active.nextMedia")
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
