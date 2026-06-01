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
                title: "Story Review",
                detail: "Helps validate pacing and story shape before credits are committed to the final export.",
                systemImage: "text.bubble"
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
            title: "In Progress and Gallery",
            detail: "Use In Progress for drafts, story reviews, render jobs, and downloads that still need action."
        ) {
            AVAviInfoRow(
                title: "In Progress",
                detail: "Check story scenes, story reviews, render jobs, and download-needed videos while a video is moving through the workflow.",
                systemImage: "clock"
            )
            AVAviInfoRow(
                title: "Gallery",
                detail: "Gallery is local-only and shows downloaded final videos generated on this device.",
                systemImage: "checkmark.circle"
            )
            AVAviActionButton(
                title: "Open Gallery",
                systemImage: "play.square.stack",
                action: openProjects
            )
        }
    }
}
