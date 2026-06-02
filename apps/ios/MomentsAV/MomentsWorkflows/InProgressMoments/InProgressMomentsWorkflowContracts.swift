import Combine
import Foundation

@MainActor
protocol InProgressMomentsSummaryProviding: AnyObject {
    var inProgressSummaryPublisher: AnyPublisher<InProgressMomentsSummary, Never> { get }
}

@MainActor
protocol InProgressMomentsViewing: InProgressMomentsSummaryProviding {
    var activeProjectPublisher: AnyPublisher<InProgressMoment?, Never> { get }
    var activeWorkspacePublisher: AnyPublisher<MomentWorkspace?, Never> { get }
    var isLoadingProjectWorkspacePublisher: AnyPublisher<Bool, Never> { get }
    var isDeletingMomentPublisher: AnyPublisher<Bool, Never> { get }
    var inProgressErrorMessagePublisher: AnyPublisher<String?, Never> { get }

    func observeMomentWorkspace(ownerUserId: String?, momentId: String?)
    func clearProjectWorkspace()
    func deleteMoment(_ moment: InProgressMoment) async -> Bool
}
