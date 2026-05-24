import XCTest
@testable import MomentsAV

final class MomentsProjectStatusRulesTests: XCTestCase {
    func testGroupsCompletedProjectsAsFinished() {
        let draft = makeProject(id: "draft", status: "draft_created", updatedAt: 10)
        let preview = makeProject(id: "preview", status: "preview_ready", updatedAt: 20)
        let completed = makeProject(id: "completed", status: "completed", updatedAt: 30)

        let groups = MomentsProjectStatusRules.group([draft, preview, completed])

        XCTAssertEqual(groups.inProgress.map(\.id), ["draft", "preview"])
        XCTAssertEqual(groups.finished.map(\.id), ["completed"])
    }

    func testListSummaryCountsAndLatestProjectUseProjectRules() {
        let oldest = makeProject(id: "oldest", status: "completed", updatedAt: 10)
        let newest = makeProject(id: "newest", status: "story_ready", updatedAt: 30)
        let middle = makeProject(id: "middle", status: "completed", updatedAt: 20)

        let summary = MomentsProjectListSummary.make(from: [oldest, newest, middle])

        XCTAssertEqual(summary.projectCount, 3)
        XCTAssertEqual(summary.inProgressCount, 1)
        XCTAssertEqual(summary.finishedCount, 2)
        XCTAssertEqual(summary.latestProject?.id, "newest")
        XCTAssertTrue(summary.hasProjects)
    }

    func testEmptyListSummaryHasNoProjects() {
        let summary = MomentsProjectListSummary.make(from: [])

        XCTAssertEqual(summary.projectCount, 0)
        XCTAssertEqual(summary.inProgressCount, 0)
        XCTAssertEqual(summary.finishedCount, 0)
        XCTAssertNil(summary.latestProject)
        XCTAssertFalse(summary.hasProjects)
    }

    func testDisplayHelpersFormatBackendValuesForUI() {
        XCTAssertEqual(MomentsProjectStatusRules.displayTitle(for: "preview_ready"), "Preview Ready")
        XCTAssertEqual(MomentsProjectStatusRules.displayKind("final_render"), "Final Render")
    }

    private func makeProject(
        id: String,
        status: String,
        updatedAt: Double
    ) -> MomentDraftProject {
        MomentDraftProject(
            id: id,
            template: .birthdayMessage,
            status: status,
            title: id,
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: updatedAt
        )
    }
}
