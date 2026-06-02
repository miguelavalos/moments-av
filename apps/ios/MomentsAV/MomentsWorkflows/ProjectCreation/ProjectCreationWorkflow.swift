import Foundation

@MainActor
final class ProjectCreationWorkflow: ObservableObject {
    @Published private(set) var isCreatingDraft = false
    @Published private(set) var activeProjectId: String?
    @Published private(set) var errorMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let creditBalanceProvider: any MomentsCreditBalanceProviding
    private let projectCreator: any MomentsProjectCreating
    private let projectDeleter: any MomentsProjectDeleting
    private let workspaceObserver: any MomentsActiveWorkspaceObserving
    private var workflowGeneration = WorkflowGeneration()

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        creditBalanceProvider: any MomentsCreditBalanceProviding,
        projectCreator: any MomentsProjectCreating,
        projectDeleter: any MomentsProjectDeleting,
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
            errorMessage = L10n.string("workflow.project.signInStart")
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
            let projectId = try await projectCreator.createDraft(ownerUserId: ownerUserId, form: form)
            guard workflowGeneration.isCurrent(generation) else { return nil }
            activeProjectId = projectId
            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
            isCreatingDraft = false
            return projectId
        } catch {
            guard workflowGeneration.isCurrent(generation) else { return nil }
            errorMessage = error.localizedDescription
            isCreatingDraft = false
            return nil
        }
    }

    func continueProject(_ project: MomentDraftProject) {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = L10n.string("workflow.project.signInContinue")
            return
        }

        workflowGeneration.advance()
        isCreatingDraft = false
        activeProjectId = project.id
        errorMessage = nil
        workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: project.id)
    }

    func resetDraft(force: Bool = false) {
        guard force || !isCreatingDraft else { return }
        workflowGeneration.advance()
        isCreatingDraft = false
        activeProjectId = nil
        errorMessage = nil
        workspaceObserver.clearWorkspace()
    }

    func discardActiveDraft(projectId projectIdOverride: String? = nil) async -> Bool {
        guard !isCreatingDraft else { return false }
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = L10n.string("workflow.project.signInDiscard")
            return false
        }
        guard let projectId = projectIdOverride ?? activeProjectId else { return true }

        let generation = workflowGeneration.begin()
        isCreatingDraft = true
        errorMessage = nil

        do {
            try await projectDeleter.deleteProject(ownerUserId: ownerUserId, projectId: projectId)
            guard workflowGeneration.isCurrent(generation) else { return false }
            isCreatingDraft = false
            self.activeProjectId = nil
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
        MomentDraftRules.availabilityMessage(availability) ?? L10n.string("workflow.project.draftNotReady")
    }
}
