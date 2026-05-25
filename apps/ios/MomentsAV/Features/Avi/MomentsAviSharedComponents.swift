import AVAviFoundation
import SwiftUI

struct MomentsAviInfoRow: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        AVAviInfoRow(
            title: title,
            detail: detail,
            systemImage: systemImage,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }

    private var accessibilityIdentifier: String {
        "moments.avi.\(title.lowercased().replacingOccurrences(of: " ", with: "."))"
    }
}

struct MomentsAviActionRow: View {
    let title: String
    let detail: String
    let systemImage: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MomentsAviInfoRow(title: title, detail: detail, systemImage: systemImage)
            Button(action: action) {
                Label(buttonTitle, systemImage: systemImage)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(MomentsTheme.brandPalette.accent)
        }
    }
}
