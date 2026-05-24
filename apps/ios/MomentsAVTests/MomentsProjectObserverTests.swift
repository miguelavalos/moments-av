import Combine
import XCTest
@testable import MomentsAV

@MainActor
final class MomentsProjectObserverTests: XCTestCase {
    func testProjectsObserverPublishesProjectUpdates() async throws {
        let repository = MockProjectsRepository()
        let observer = MomentsProjectsObserver(projectRepository: repository)

        observer.observeProjects(ownerUserId: "user-1")
        let project = makeProject(id: "project-1")
        repository.projectsSubject.send([project])
        await waitUntil { observer.projects == [project] }

        XCTAssertEqual(observer.projects, [project])
        XCTAssertNil(observer.errorMessage)
        XCTAssertEqual(repository.observedOwnerUserIds, ["user-1"])
    }

    func testProjectsObserverClearsStateWhenOwnerIsMissing() async {
        let repository = MockProjectsRepository()
        let observer = MomentsProjectsObserver(projectRepository: repository)

        observer.observeProjects(ownerUserId: "user-1")
        repository.projectsSubject.send([makeProject(id: "project-1")])
        await waitUntil { !observer.projects.isEmpty }

        observer.observeProjects(ownerUserId: nil)

        XCTAssertTrue(observer.projects.isEmpty)
        XCTAssertNil(observer.errorMessage)
        XCTAssertEqual(repository.observedOwnerUserIds, ["user-1"])
    }

    func testProjectsObserverPublishesObservationErrors() {
        let repository = MockProjectsRepository(projectsError: TestObservationError.projects)
        let observer = MomentsProjectsObserver(projectRepository: repository)

        observer.observeProjects(ownerUserId: "user-1")

        XCTAssertTrue(observer.projects.isEmpty)
        XCTAssertEqual(observer.errorMessage, TestObservationError.projects.localizedDescription)
    }

    func testWorkspaceObserverPublishesWorkspaceUpdates() async throws {
        let repository = MockWorkspaceRepository()
        let observer = MomentsWorkspaceObserver(projectRepository: repository)

        observer.observeWorkspace(ownerUserId: "user-1", projectId: "project-1")
        let workspace = makeWorkspace(project: makeProject(id: "project-1"))
        repository.workspaceSubject.send(workspace)
        await waitUntil { observer.activeWorkspace == workspace }

        XCTAssertEqual(observer.activeWorkspace, workspace)
        XCTAssertNil(observer.errorMessage)
        XCTAssertEqual(repository.observedRequests, [
            WorkspaceRequest(ownerUserId: "user-1", projectId: "project-1")
        ])
    }

    func testWorkspaceObserverClearsStateWhenRequestIsIncomplete() async {
        let repository = MockWorkspaceRepository()
        let observer = MomentsWorkspaceObserver(projectRepository: repository)

        observer.observeWorkspace(ownerUserId: "user-1", projectId: "project-1")
        repository.workspaceSubject.send(makeWorkspace(project: makeProject(id: "project-1")))
        await waitUntil { observer.activeWorkspace != nil }

        observer.observeWorkspace(ownerUserId: "user-1", projectId: nil)

        XCTAssertNil(observer.activeWorkspace)
        XCTAssertNil(observer.errorMessage)
        XCTAssertEqual(repository.observedRequests, [
            WorkspaceRequest(ownerUserId: "user-1", projectId: "project-1")
        ])
    }

    func testWorkspaceObserverPublishesObservationErrors() {
        let repository = MockWorkspaceRepository(workspaceError: TestObservationError.workspace)
        let observer = MomentsWorkspaceObserver(projectRepository: repository)

        observer.observeWorkspace(ownerUserId: "user-1", projectId: "project-1")

        XCTAssertNil(observer.activeWorkspace)
        XCTAssertEqual(observer.errorMessage, TestObservationError.workspace.localizedDescription)
    }

    private func waitUntil(
        timeoutNanoseconds: UInt64 = 250_000_000,
        condition: @escaping @MainActor () -> Bool
    ) async {
        let deadline = ContinuousClock.now.advanced(by: .nanoseconds(Int(timeoutNanoseconds)))
        while ContinuousClock.now < deadline {
            if condition() {
                return
            }
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }

    private func makeWorkspace(project: MomentDraftProject) -> MomentProjectWorkspace {
        MomentProjectWorkspace(
            project: project,
            mediaAssets: [],
            storyScenes: [],
            renderJobs: [],
            artifacts: []
        )
    }

    private func makeProject(id: String) -> MomentDraftProject {
        MomentDraftProject(
            id: id,
            template: .birthdayMessage,
            status: "draft_created",
            title: "Family Weekend",
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: 10
        )
    }
}

@MainActor
private final class MockProjectsRepository: MomentsProjectsObserving {
    let projectsSubject = CurrentValueSubject<[MomentDraftProject], Never>([])
    private(set) var observedOwnerUserIds: [String] = []
    private let projectsError: Error?

    init(projectsError: Error? = nil) {
        self.projectsError = projectsError
    }

    func observeProjects(ownerUserId: String) throws -> AnyPublisher<[MomentDraftProject], Never> {
        observedOwnerUserIds.append(ownerUserId)
        if let projectsError {
            throw projectsError
        }
        return projectsSubject.eraseToAnyPublisher()
    }
}

@MainActor
private final class MockWorkspaceRepository: MomentsWorkspaceObserving {
    let workspaceSubject = CurrentValueSubject<MomentProjectWorkspace?, Never>(nil)
    private(set) var observedRequests: [WorkspaceRequest] = []
    private let workspaceError: Error?

    init(workspaceError: Error? = nil) {
        self.workspaceError = workspaceError
    }

    func observeProjectWorkspace(
        ownerUserId: String,
        projectId: String
    ) throws -> AnyPublisher<MomentProjectWorkspace?, Never> {
        observedRequests.append(WorkspaceRequest(ownerUserId: ownerUserId, projectId: projectId))
        if let workspaceError {
            throw workspaceError
        }
        return workspaceSubject.eraseToAnyPublisher()
    }
}

private struct WorkspaceRequest: Equatable {
    var ownerUserId: String
    var projectId: String
}

private enum TestObservationError: LocalizedError {
    case projects
    case workspace

    var errorDescription: String? {
        switch self {
        case .projects:
            "Project observation failed."
        case .workspace:
            "Workspace observation failed."
        }
    }
}
