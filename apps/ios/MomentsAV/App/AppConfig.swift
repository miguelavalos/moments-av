import AccountAV
import Foundation

@MainActor
enum AppConfig {
    static var avAccountKey: String {
        Bundle.main.object(forInfoDictionaryKey: "ACCOUNTAV_PUBLISHABLE_KEY") as? String ?? ""
    }

    static var isAVAccountAvailable: Bool {
        !avAccountKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static var momentsConvexURL: String {
        Bundle.main.object(forInfoDictionaryKey: "MOMENTSAV_CONVEX_URL") as? String ?? ""
    }

    static func configureAVAccountIfPossible() {
        AccountAVClerk.configureIfPossible(publishableKey: avAccountKey)
    }
}
