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

    var systemImage: String {
        switch self {
        case .onboarding: "sparkles"
        case .creditExplanation: "creditcard"
        case .storyDraft: "text.bubble"
        case .previewProgress: "play.rectangle"
        case .finalRender: "film"
        case .recovery: "exclamationmark.triangle"
        }
    }
}

struct AviCompanionView: View {
    let state: AviCompanionState
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: state.systemImage)
                .font(.title3)
                .foregroundStyle(MomentsBrand.ColorToken.primaryAccent)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 6) {
                Text(state.title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(MomentsBrand.ColorToken.panelBackground, in: RoundedRectangle(cornerRadius: MomentsBrand.Radius.panel))
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
