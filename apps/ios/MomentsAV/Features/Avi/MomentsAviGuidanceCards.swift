import AVSettingsFoundation
import SwiftUI

struct MomentsAviHelpCard: View {
    var body: some View {
        AVSettingsCard {
            Text("How Avi helps")
                .font(.headline)
            MomentsAviInfoRow(
                title: "Draft",
                detail: "Turns the occasion, tone, template, and selected media into a scene outline.",
                systemImage: "text.quote"
            )
            MomentsAviInfoRow(
                title: "Preview",
                detail: "Helps validate pacing and story shape before credits are committed to the final export.",
                systemImage: "rectangle.inset.filled.and.person.filled"
            )
            MomentsAviInfoRow(
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
        AVSettingsCard {
            Text("Project guidance")
                .font(.headline)
            MomentsAviInfoRow(
                title: "In progress",
                detail: "Use Projects to check story scenes, preview artifacts, and render jobs while a video is moving through the workflow.",
                systemImage: "clock"
            )
            MomentsAviInfoRow(
                title: "Finished",
                detail: "Completed projects keep the final export artifact visible in the workspace detail.",
                systemImage: "checkmark.circle"
            )
            Button(action: openProjects) {
                Label("Open Projects", systemImage: "rectangle.stack")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}
