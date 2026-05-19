import SwiftUI

enum MomentsBrand {
    enum ColorToken {
        // Provisional values until canonical Moments AV assets are exported.
        static let primaryAccent = Color(red: 0.85, green: 0.36, blue: 0.28)
        static let suiteAccent = Color(red: 0.43, green: 0.75, blue: 0.27)
        static let appBackground = Color(red: 0.97, green: 0.94, blue: 0.91)
        static let panelBackground = Color(red: 1.0, green: 0.98, blue: 0.95)
        static let elevatedSurface = Color(uiColor: .systemBackground)
    }

    enum Radius {
        static let panel: CGFloat = 8
    }
}
