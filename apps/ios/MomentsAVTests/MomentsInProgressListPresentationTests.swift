import XCTest
@testable import MomentsAV

final class MomentsInProgressListPresentationTests: XCTestCase {
    func testSummaryPillsUseProjectSummaryCounts() {
        let presentation = MomentsInProgressListPresentation.make(
            projectSummary: MomentsProjectListSummary.make(from: [
                makeProject(id: "active", status: "story_ready", updatedAt: 20),
                makeProject(id: "done", status: "completed", updatedAt: 10)
            ]),
            selectedMomentId: nil
        )

        XCTAssertEqual(presentation.summaryPills.map(\.title), ["Total", "Active", "Done"])
        XCTAssertEqual(presentation.summaryPills.map(\.value), [2, 1, 1])
        XCTAssertEqual(presentation.summaryPills.map(\.systemImage), ["rectangle.stack", "clock", "checkmark.circle"])
    }

    func testGroupsOmitEmptySectionsAndPreserveStatusRulesOrder() {
        let presentation = MomentsInProgressListPresentation.make(
            projectSummary: MomentsProjectListSummary.make(from: [
                makeProject(id: "older-active", status: "draft_created", updatedAt: 10),
                makeProject(id: "newer-active", status: "story_ready", updatedAt: 30),
                makeProject(id: "done", status: "completed", updatedAt: 20)
            ]),
            selectedMomentId: nil
        )

        XCTAssertEqual(presentation.groups.map(\.title), ["In progress", "Finished"])
        XCTAssertEqual(presentation.groups[0].rows.map(\.id), ["newer-active", "older-active"])
        XCTAssertEqual(presentation.groups[1].rows.map(\.id), ["done"])
    }

    func testRowPresentationFormatsProjectMetadataAndSelection() {
        let project = makeProject(
            id: "project-1",
            status: "preview_ready",
            title: "Family Weekend",
            creditCost: 3,
            previewCount: 1,
            previewLimit: 4
        )
        let row = MomentsInProgressListRowPresentation(project: project, isSelected: true)

        XCTAssertEqual(row.id, "project-1")
        XCTAssertEqual(row.title, "Family Weekend")
        XCTAssertEqual(row.statusSystemImage, "circle.dashed")
        XCTAssertFalse(row.isFinished)
        XCTAssertEqual(row.metadata.map(\.systemImage), ["clock", "text.bubble"])
        XCTAssertTrue(row.metadata[0].text.hasPrefix("Updated "))
        XCTAssertEqual(row.metadata[1].text, "1/4 Story Reviews")
        XCTAssertEqual(row.statusTitle, "Story Review Ready")
        XCTAssertEqual(row.creditCostTitle, "3 credits")
        XCTAssertEqual(row.accessorySystemImage, "chevron.up.circle.fill")
    }

    func testFinishedRowUsesFinishedMarkerAndCollapsedAccessoryWhenNotSelected() {
        let row = MomentsInProgressListRowPresentation(
            project: makeProject(id: "done", status: "completed"),
            isSelected: false
        )

        XCTAssertTrue(row.isFinished)
        XCTAssertEqual(row.statusSystemImage, "checkmark.circle.fill")
        XCTAssertEqual(row.accessorySystemImage, "chevron.right.circle")
    }

    func testRowPresentationUsesSingularCreditCopy() {
        let row = MomentsInProgressListRowPresentation(
            project: makeProject(id: "one-credit", status: "draft_created", creditCost: 1),
            isSelected: false
        )

        XCTAssertEqual(row.creditCostTitle, "1 credit")
    }

    private func makeProject(
        id: String,
        status: String,
        title: String? = nil,
        creditCost: Double = 2,
        previewCount: Double = 0,
        previewLimit: Double = 3,
        updatedAt: Double = 10
    ) -> MomentDraftProject {
        MomentDraftProject(
            id: id,
            template: .birthdayMessage,
            status: status,
            title: title ?? id,
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: creditCost,
            previewCount: previewCount,
            previewLimit: previewLimit,
            updatedAt: updatedAt
        )
    }
}
