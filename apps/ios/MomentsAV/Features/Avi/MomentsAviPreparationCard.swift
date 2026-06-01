import AVAviFoundation
import SwiftUI

struct MomentsAviPreparationCard: View {
    let openCreate: () -> Void

    var body: some View {
        AVAviGuidanceCard(
            title: MomentsL10n.string("avi.prepare.title"),
            detail: MomentsL10n.string("avi.prepare.detail")
        ) {
            AVAviInfoRow(
                title: MomentsL10n.string("avi.prepare.occasion.title"),
                detail: MomentsL10n.string("avi.prepare.occasion.detail"),
                systemImage: "sparkles"
            )
            AVAviInfoRow(
                title: MomentsL10n.string("avi.prepare.media.title"),
                detail: MomentsL10n.string("avi.prepare.media.detail"),
                systemImage: "photo.on.rectangle"
            )
            AVAviInfoRow(
                title: MomentsL10n.string("avi.prepare.review.title"),
                detail: MomentsL10n.string("avi.prepare.review.detail"),
                systemImage: "text.bubble"
            )
            AVAviActionInfoRow(
                title: MomentsL10n.string("avi.prepare.action.title"),
                detail: MomentsL10n.string("avi.prepare.action.detail"),
                systemImage: "plus.app",
                buttonTitle: MomentsL10n.string("avi.prepare.action.button"),
                action: openCreate
            )
        }
    }
}
