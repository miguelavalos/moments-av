import SwiftUI

struct MomentsCreateStorySceneRow: View {
    let index: Int
    let caption: String
    let narration: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Scene \(index + 1)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(caption)
                .font(.subheadline.weight(.medium))
            Text(narration)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
