import Foundation

@MainActor
final class ProjectCreationWorkflow: ObservableObject {
    @Published private(set) var isCreatingDraft = false
    @Published private(set) var activeProjectId: String?
    @Published private(set) var errorMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let creditBalanceProvider: any MomentsCreditBalanceProviding
    private let projectCreator: any MomentsProjectCreating
    private let workspaceObserver: any MomentsActiveWorkspaceObserving
    private var resetGeneration = 0

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        projectCreator: any MomentsProjectCreating,
        workspaceObserver: any MomentsActiveWorkspaceObserving
    ) {
        self.currentUserProvider = currentUserProvider
        self.creditBalanceProvider = creditBalanceProvider
        self.projectCreator = projectCreator
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
            errorMessage = "Sign in before creating a draft."
            return nil
        }

        let availability = MomentDraftRules.availability(form: form, balance: balance)
        guard availability.canCreateDraft else {
            errorMessage = createDraftBlockMessage(availability)
            return nil
        }

        let generation = resetGeneration
        isCreatingDraft = true
        errorMessage = nil

        do {
            let projectId = try await projectCreator.createDraft(ownerUserId: ownerUserId, form: form)
            guard isCurrent(generation) else { return nil }
            activeProjectId = projectId
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
            isCreatingDraft = false
            return projectId
        } catch {
            guard isCurrent(generation) else { return nil }
            errorMessage = error.localizedDescription
            isCreatingDraft = false
            return nil
        }
    }

    func continueProject(_ project: MomentDraftProject) {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = "Sign in before continuing a project."
            return
        }

        resetGeneration += 1
        isCreatingDraft = false
        activeProjectId = project.id
        errorMessage = nil
        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: project.id)
    }

    func resetDraft(force: Bool = false) {
        guard force || !isCreatingDraft else { return }
        resetGeneration += 1
        isCreatingDraft = false
        activeProjectId = nil
        errorMessage = nil
        workspaceObserver.clearWorkspace()
    }

    private func isCurrent(_ generation: Int) -> Bool {
        generation == resetGeneration
    }

    private func createDraftBlockMessage(_ availability: MomentDraftRules.Availability) -> String {
        MomentDraftRules.availabilityMessage(availability) ?? "Draft is not ready to create."
    }
}
