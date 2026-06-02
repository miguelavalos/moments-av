import Foundation

@MainActor
final class MomentCreationWorkflow: ObservableObject {
    @Published private(set) var isCreatingDraft = false
    @Published private(set) var activeMomentId: String?
    @Published private(set) var errorMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let creditBalanceProvider: any MomentsCreditBalanceProviding
    private let momentCreator: any MomentsCreating
    private let momentDeleter: any MomentsDeleting
    private let workspaceObserver: any MomentsActiveWorkspaceObserving
    private var workflowGeneration = WorkflowGeneration()

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        momentCreator: any MomentsCreating,
        momentDeleter: any MomentsDeleting,
        workspaceObserver: any MomentsActiveWorkspaceObserving
    ) {
        self.currentUserProvider = currentUserProvider
        self.creditBalanceProvider = creditBalanceProvider
        self.momentCreator = momentCreator
        self.momentDeleter = momentDeleter
        self.workspaceObserver = workspaceObserver
    }

    var launchTemplates: [MomentTemplate] {
        MomentTemplate.launchTemplates
    }

    var balance: MomentsCreditBalance {
        creditBalanceProvider.currentCreditBalance
    }

    var isConfigured: Bool {
        momentCreator.isConfigured
    }

    func canAfford(_ template: MomentTemplate) -> Bool {
        MomentsCreditGate.canAfford(template, balance: balance)
    }

    func spendPlan(for template: MomentTemplate) -> MomentsCreditSpendPlan? {
        MomentsCreditGate.spendPlan(for: template.creditCost, balance: balance)
    }

    func createMoment(form: MomentSetupForm) async -> String? {
        guard !isCreatingDraft else { return nil }
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = L10n.string("workflow.moment.signInStart")
            return nil
        }

        let availability = MomentSetupRules.availability(form: form, balance: balance)
        guard availability.canCreateDraft else {
            errorMessage = createMomentBlockMessage(availability)
            return nil
        }

        let generation = workflowGeneration.begin()
        isCreatingDraft = true
        errorMessage = nil

        do {
            let momentId = try await momentCreator.createMoment(ownerUserId: ownerUserId, form: form)
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

    func discardActiveMoment(momentId momentIdOverride: String? = nil) async -> Bool {
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
            try await momentDeleter.deleteMoment(ownerUserId: ownerUserId, momentId: momentId)
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

    private func createMomentBlockMessage(_ availability: MomentSetupRules.Availability) -> String {
        MomentSetupRules.availabilityMessage(availability) ?? L10n.string("workflow.moment.draftNotReady")
    }
}
