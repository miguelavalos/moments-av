import AVAppShellFoundation
import SwiftUI

struct MomentsCreateStorySceneRow: View {
    let index: Int
    let caption: String
    let narration: String

    var body: some View {
        AVAppShellInfoRow(
            title: caption,
            detail: narration,
            systemImage: "rectangle.stack.fill",
            eyebrow: "Scene \(index + 1)"
        )
    }
}
