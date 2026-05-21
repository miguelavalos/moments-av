import SwiftUI

enum AviCompanionState: Equatable {
    case onboarding
    case creditExplanation
    case storyDraft
    case previewProgress
    case finalRender
    case recovery

    var title: String {
        switch self {
        case .onboarding: "Avi gets the project ready"
        case .creditExplanation: "Avi keeps costs visible"
        case .storyDraft: "Avi helps shape the story"
        case .previewProgress: "Avi prepares the preview"
        case .finalRender: "Avi prepares the final export"
        case .recovery: "Avi can help recover"
        }
    }

}

struct AviCompanionView: View {
    let state: AviCompanionState
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(MomentsBrand.Asset.aviThinking)
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
                .background(
                    Circle()
                        .fill(MomentsBrand.ColorToken.softAccent.opacity(0.36))
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(state.title)
                    .font(.headline)
                    .foregroundStyle(MomentsBrand.ColorToken.ink)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(MomentsBrand.ColorToken.mutedText)
            }
        }
        .padding(16)
        .background(MomentsBrand.ColorToken.panelBackground, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.prominentPanel))
        .overlay {
            RoundedRectangle(cornerRadius: MomentsBrand.Radius.prominentPanel)
                .stroke(MomentsBrand.ColorToken.ink.opacity(0.08))
        }
    }
}

struct AviStatusMessage: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "bubble.left.and.text.bubble.right")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
