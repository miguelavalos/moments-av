import Combine
import Foundation

@MainActor
final class MomentDeletionWorkflow: ObservableObject {
    @Published private(set) var isDeletingMoment = false
    @Published private(set) var errorMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let projectDeleter: any MomentsDeleting
    private var deletionGeneration = 0

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        projectDeleter: any MomentsDeleting
    ) {
        self.currentUserProvider = currentUserProvider
        self.projectDeleter = projectDeleter
    }

    var isDeletingMomentPublisher: AnyPublisher<Bool, Never> {
        $isDeletingMoment.eraseToAnyPublisher()
    }

    var deletionErrorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }

    func deleteMoment(_ moment: InProgressMoment) async -> Bool {
        guard !isDeletingMoment else { return false }
        guard let ownerUserId = currentUserProvider.currentUserId else {
            errorMessage = "Sign in before deleting a moment."
            return false
        }

        isDeletingMoment = true
        errorMessage = nil
        deletionGeneration += 1
        let generation = deletionGeneration

        do {
            try await projectDeleter.deleteMoment(ownerUserId: ownerUserId, momentId: moment.id)
            guard deletionGeneration == generation else { return false }
            isDeletingMoment = false
            return true
        } catch {
            guard deletionGeneration == generation else { return false }
            errorMessage = error.localizedDescription
            isDeletingMoment = false
            return false
        }
    }
}
