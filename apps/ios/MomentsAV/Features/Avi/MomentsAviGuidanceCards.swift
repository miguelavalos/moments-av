import AVAviFoundation
import SwiftUI

struct MomentsAviHelpCard: View {
    var body: some View {
        AVAviGuidanceCard(
            title: "How Avi helps",
            detail: "Avi keeps the memory-video workflow focused without becoming a full chat product."
        ) {
            AVAviInfoRow(
                title: "Draft",
                detail: "Turns the occasion, tone, template, and selected media into a scene outline.",
                systemImage: "text.quote"
            )
            AVAviInfoRow(
                title: "Preview",
                detail: "Helps validate pacing and story shape before credits are committed to the final export.",
                systemImage: "rectangle.inset.filled.and.person.filled"
            )
            AVAviInfoRow(
                title: "Project review",
                detail: "Points you back to story scenes, render jobs, and artifacts when a project needs inspection.",
                systemImage: "rectangle.stack"
            )
        }
    }
}

struct MomentsAviProjectGuidanceCard: View {
    let openProjects: () -> Void

    var body: some View {
        AVAviGuidanceCard(
            title: "Project guidance",
            detail: "Use Projects when a draft, preview, render job, or final artifact needs review."
        ) {
            AVAviInfoRow(
                title: "In progress",
                detail: "Use Projects to check story scenes, preview artifacts, and render jobs while a video is moving through the workflow.",
                systemImage: "clock"
            )
            AVAviInfoRow(
                title: "Finished",
                detail: "Completed projects keep the final export artifact visible in the workspace detail.",
                systemImage: "checkmark.circle"
            )
            AVAviActionButton(
                title: "Open Projects",
                systemImage: "rectangle.stack",
                action: openProjects
            )
        }
    }
}
