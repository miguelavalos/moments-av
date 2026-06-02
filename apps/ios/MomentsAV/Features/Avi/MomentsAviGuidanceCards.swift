import AVAviFoundation
import SwiftUI

struct MomentsAviHelpCard: View {
    var body: some View {
        AVAviGuidanceCard(
            title: L10n.string("avi.help.title"),
            detail: L10n.string("avi.help.detail")
        ) {
            AVAviInfoRow(
                title: L10n.string("avi.help.choose.title"),
                detail: L10n.string("avi.help.choose.detail"),
                systemImage: "photo.on.rectangle"
            )
            AVAviInfoRow(
                title: L10n.string("avi.help.review.title"),
                detail: L10n.string("avi.help.review.detail"),
                systemImage: "text.bubble"
            )
            AVAviInfoRow(
                title: L10n.string("avi.help.create.title"),
                detail: L10n.string("avi.help.create.detail"),
                systemImage: "video.fill"
            )
        }
    }
}

struct MomentsAviProjectGuidanceCard: View {
    let openProjects: () -> Void

    var body: some View {
        AVAviGuidanceCard(
            title: L10n.string("projects.inProgressAndGallery.title"),
            detail: L10n.string("avi.projects.detail")
        ) {
            AVAviInfoRow(
                title: L10n.string("projects.inProgress.title"),
                detail: L10n.string("avi.projects.inProgress.detail"),
                systemImage: "clock"
            )
            AVAviInfoRow(
                title: L10n.string("gallery.title"),
                detail: L10n.string("avi.projects.gallery.detail"),
                systemImage: "checkmark.circle"
            )
            AVAviActionButton(
                title: L10n.string("gallery.open"),
                systemImage: "play.square.stack",
                action: openProjects
            )
        }
    }
}
