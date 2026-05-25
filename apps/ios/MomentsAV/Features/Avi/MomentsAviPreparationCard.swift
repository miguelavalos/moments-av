import AVAviFoundation
import SwiftUI

struct MomentsAviPreparationCard: View {
    let openCreate: () -> Void

    var body: some View {
        AVAviGuidanceCard(
            title: "Before creating",
            detail: "A little structure keeps story drafts, previews, and final renders cleaner."
        ) {
            AVAviInfoRow(
                title: "Choose a focused occasion",
                detail: "Birthdays, trips, milestones, and recaps work best when the draft has one clear purpose.",
                systemImage: "sparkles"
            )
            AVAviInfoRow(
                title: "Use a tight media set",
                detail: "Pick the strongest clips and photos first. The create flow can keep the order clean for the story draft.",
                systemImage: "photo.on.rectangle"
            )
            AVAviInfoRow(
                title: "Preview before final export",
                detail: "Previews are for checking pacing and story. Final render is the credit-committing step.",
                systemImage: "play.rectangle"
            )
            AVAviActionInfoRow(
                title: "Prepare a new video",
                detail: "Open the create flow when the occasion and media set are ready.",
                systemImage: "plus.app",
                buttonTitle: "Open Create",
                action: openCreate
            )
        }
    }
}
