import Combine
import Foundation

@MainActor
final class MomentDeletionWorkflow: ObservableObject {
    @Published private(set) var isDeletingProject = false
    @Published private(set) var errorMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let projectDeleter: any MomentsProjectDeleting
    private var deletionGeneration = 0

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        projectDeleter: any MomentsProjectDeleting
    ) {
        self.currentUserProvider = currentUserProvider
        self.projectDeleter = projectDeleter
    }

    var isDeletingProjectPublisher: AnyPublisher<Bool, Never> {
        $isDeletingProject.eraseToAnyPublisher()
    }

    var deletionErrorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }

    func deleteProject(_ project: MomentDraftProject) async -> Bool {
        guard !isDeletingProject else { return false }
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = "Sign in before deleting a project."
            return false
        }

        isDeletingProject = true
        errorMessage = nil
        deletionGeneration += 1
        let generation = deletionGeneration

        do {
            try await projectDeleter.deleteProject(ownerUserId: ownerUserId, projectId: project.id)
            guard deletionGeneration == generation else { return false }
            isDeletingProject = false
            return true
        } catch {
            guard deletionGeneration == generation else { return false }
            errorMessage = error.localizedDescription
            isDeletingProject = false
            return false
        }
    }
}
