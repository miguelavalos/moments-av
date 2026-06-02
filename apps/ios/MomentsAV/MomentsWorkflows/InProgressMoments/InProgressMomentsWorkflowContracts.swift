import Combine
import Foundation

@MainActor
protocol MomentsProjectSummaryProviding: AnyObject {
    var inProgressSummaryPublisher: AnyPublisher<MomentsProjectListSummary, Never> { get }
}

@MainActor
protocol MomentsInProgressViewing: MomentsProjectSummaryProviding {
    var activeProjectPublisher: AnyPublisher<MomentDraftProject?, Never> { get }
    var activeWorkspacePublisher: AnyPublisher<MomentProjectWorkspace?, Never> { get }
    var isLoadingProjectWorkspacePublisher: AnyPublisher<Bool, Never> { get }
    var isDeletingMomentPublisher: AnyPublisher<Bool, Never> { get }
    var inProgressErrorMessagePublisher: AnyPublisher<String?, Never> { get }

    func observeProjectWorkspace(ownerUserId: String?, projectId: String?)
    func clearProjectWorkspace()
    func deleteMoment(_ project: MomentDraftProject) async -> Bool
}
