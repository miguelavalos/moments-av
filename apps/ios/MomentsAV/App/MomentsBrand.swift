import SwiftUI

enum MomentsBrand {
    enum ColorToken {
        static let ink = Color(red: 0.14, green: 0.19, blue: 0.25)
        static let paper = Color(red: 1.0, green: 0.98, blue: 0.94)
        static let primaryAccent = Color(red: 0.85, green: 0.36, blue: 0.28)
        static let softAccent = Color(red: 0.96, green: 0.79, blue: 0.74)
        static let appBackground = Color(red: 1.0, green: 0.96, blue: 0.89)
        static let panelBackground = Color(red: 1.0, green: 0.98, blue: 0.95)
        static let elevatedSurface = Color(red: 1.0, green: 0.99, blue: 0.96)
        static let mutedText = Color(red: 0.20, green: 0.27, blue: 0.35).opacity(0.78)
    }

    enum Radius {
        static let panel: CGFloat = 8
        static let prominentPanel: CGFloat = 16
    }

    enum Asset {
        static let logo = "MomentsAVLogo"
        static let wordmark = "MomentsAVWordmark"
        static let mark = "MomentsAVMark"
        static let aviThinking = "AviThinking"
    }
}
