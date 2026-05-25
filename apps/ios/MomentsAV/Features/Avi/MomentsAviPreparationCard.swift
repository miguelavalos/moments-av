import AVSettingsFoundation
import SwiftUI

struct MomentsAviPreparationCard: View {
    let openCreate: () -> Void

    var body: some View {
        AVSettingsCard {
            Text("Before creating")
                .font(.headline)
            MomentsAviInfoRow(
                title: "Choose a focused occasion",
                detail: "Birthdays, trips, milestones, and recaps work best when the draft has one clear purpose.",
                systemImage: "sparkles"
            )
            MomentsAviInfoRow(
                title: "Use a tight media set",
                detail: "Pick the strongest clips and photos first. The create flow can keep the order clean for the story draft.",
                systemImage: "photo.on.rectangle"
            )
            MomentsAviInfoRow(
                title: "Preview before final export",
                detail: "Previews are for checking pacing and story. Final render is the credit-committing step.",
                systemImage: "play.rectangle"
            )
            MomentsAviActionRow(
                title: "Prepare a new video",
                detail: "Open the create flow when the occasion and media set are ready.",
                systemImage: "plus.app",
                buttonTitle: "Open Create",
                action: openCreate
            )
        }
    }
}
