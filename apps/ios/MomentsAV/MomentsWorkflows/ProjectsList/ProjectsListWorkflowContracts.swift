import Combine
import Foundation

@MainActor
protocol MomentsProjectSummaryProviding: AnyObject {
    var projectSummaryPublisher: AnyPublisher<MomentsProjectListSummary, Never> { get }
}

@MainActor
protocol MomentsInProgressViewing: MomentsProjectSummaryProviding {
    var activeProjectPublisher: AnyPublisher<MomentDraftProject?, Never> { get }
    var activeWorkspacePublisher: AnyPublisher<MomentProjectWorkspace?, Never> { get }
    var isLoadingProjectWorkspacePublisher: AnyPublisher<Bool, Never> { get }
    var isDeletingProjectPublisher: AnyPublisher<Bool, Never> { get }
    var projectErrorMessagePublisher: AnyPublisher<String?, Never> { get }

    func observeProjectWorkspace(ownerUserId: String?, projectId: String?)
    func clearProjectWorkspace()
    func deleteProject(_ project: MomentDraftProject) async -> Bool
}
