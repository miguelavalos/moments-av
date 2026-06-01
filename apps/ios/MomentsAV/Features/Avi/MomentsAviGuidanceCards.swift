import AVAviFoundation
import SwiftUI

struct MomentsAviHelpCard: View {
    var body: some View {
        AVAviGuidanceCard(
            title: MomentsL10n.string("avi.help.title"),
            detail: MomentsL10n.string("avi.help.detail")
        ) {
            AVAviInfoRow(
                title: MomentsL10n.string("avi.help.choose.title"),
                detail: MomentsL10n.string("avi.help.choose.detail"),
                systemImage: "photo.on.rectangle"
            )
            AVAviInfoRow(
                title: MomentsL10n.string("avi.help.review.title"),
                detail: MomentsL10n.string("avi.help.review.detail"),
                systemImage: "text.bubble"
            )
            AVAviInfoRow(
                title: MomentsL10n.string("avi.help.create.title"),
                detail: MomentsL10n.string("avi.help.create.detail"),
                systemImage: "video.fill"
            )
        }
    }
}

struct MomentsAviProjectGuidanceCard: View {
    let openProjects: () -> Void

    var body: some View {
        AVAviGuidanceCard(
            title: MomentsL10n.string("projects.inProgressAndGallery.title"),
            detail: MomentsL10n.string("avi.projects.detail")
        ) {
            AVAviInfoRow(
                title: MomentsL10n.string("projects.inProgress.title"),
                detail: MomentsL10n.string("avi.projects.inProgress.detail"),
                systemImage: "clock"
            )
            AVAviInfoRow(
                title: MomentsL10n.string("gallery.title"),
                detail: MomentsL10n.string("avi.projects.gallery.detail"),
                systemImage: "checkmark.circle"
            )
            AVAviActionButton(
                title: MomentsL10n.string("gallery.open"),
                systemImage: "play.square.stack",
                action: openProjects
            )
        }
    }
}
