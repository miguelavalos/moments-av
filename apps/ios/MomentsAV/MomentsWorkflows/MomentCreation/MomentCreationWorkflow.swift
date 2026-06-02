import Foundation

@MainActor
final class MomentCreationWorkflow: ObservableObject {
    @Published private(set) var isCreatingDraft = false
    @Published private(set) var activeMomentId: String?
    @Published private(set) var errorMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let creditBalanceProvider: any MomentsCreditBalanceProviding
    private let projectCreator: any MomentsCreating
    private let projectDeleter: any MomentsDeleting
    private let workspaceObserver: any MomentsActiveWorkspaceObserving
    private var workflowGeneration = WorkflowGeneration()

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        projectCreator: any MomentsCreating,
        projectDeleter: any MomentsDeleting,
        workspaceObserver: any MomentsActiveWorkspaceObserving
    ) {
        self.currentUserProvider = currentUserProvider
        self.creditBalanceProvider = creditBalanceProvider
        self.projectCreator = projectCreator
        self.projectDeleter = projectDeleter
        self.workspaceObserver = workspaceObserver
    }

    var launchTemplates: [MomentTemplate] {
        MomentTemplate.launchTemplates
    }

    var balance: MomentsCreditBalance {
        creditBalanceProvider.currentCreditBalance
    }

    var isConfigured: Bool {
        projectCreator.isConfigured
    }

    func canAfford(_ template: MomentTemplate) -> Bool {
        MomentsCreditGate.canAfford(template, balance: balance)
    }

    func spendPlan(for template: MomentTemplate) -> MomentsCreditSpendPlan? {
        MomentsCreditGate.spendPlan(for: template.creditCost, balance: balance)
    }

    func createDraft(form: MomentDraftForm) async -> String? {
        guard !isCreatingDraft else { return nil }
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = L10n.string("workflow.moment.signInStart")
            return nil
        }

        let availability = MomentDraftRules.availability(form: form, balance: balance)
        guard availability.canCreateDraft else {
            errorMessage = createDraftBlockMessage(availability)
            return nil
        }

        let generation = workflowGeneration.begin()
        isCreatingDraft = true
        errorMessage = nil

        do {
            let momentId = try await projectCreator.createDraft(ownerUserId: ownerUserId, form: form)
            guard workflowGeneration.isCurrent(generation) else { return nil }
            activeMomentId = momentId
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, momentId: momentId)
            isCreatingDraft = false
            return momentId
        } catch {
            guard workflowGeneration.isCurrent(generation) else { return nil }
            errorMessage = error.localizedDescription
            isCreatingDraft = false
            return nil
        }
    }

    func continueMoment(_ moment: InProgressMoment) {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = L10n.string("workflow.moment.signInContinue")
            return
        }

        workflowGeneration.advance()
        isCreatingDraft = false
        activeMomentId = moment.id
        errorMessage = nil
        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, momentId: moment.id)
    }

    func resetDraft(force: Bool = false) {
        guard force || !isCreatingDraft else { return }
        workflowGeneration.advance()
        isCreatingDraft = false
        activeMomentId = nil
        errorMessage = nil
        workspaceObserver.clearWorkspace()
    }

    func discardActiveDraft(momentId momentIdOverride: String? = nil) async -> Bool {
        guard !isCreatingDraft else { return false }
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = L10n.string("workflow.moment.signInDiscard")
            return false
        }
        guard let momentId = momentIdOverride ?? activeMomentId else { return true }

        let generation = workflowGeneration.begin()
        isCreatingDraft = true
        errorMessage = nil

        do {
            try await projectDeleter.deleteMoment(ownerUserId: ownerUserId, momentId: momentId)
            guard workflowGeneration.isCurrent(generation) else { return false }
            isCreatingDraft = false
            self.activeMomentId = nil
            workspaceObserver.clearWorkspace()
            return true
        } catch {
            guard workflowGeneration.isCurrent(generation) else { return false }
            errorMessage = error.localizedDescription
            isCreatingDraft = false
            return false
        }
    }

    private func createDraftBlockMessage(_ availability: MomentDraftRules.Availability) -> String {
        MomentDraftRules.availabilityMessage(availability) ?? L10n.string("workflow.moment.draftNotReady")
    }
}
