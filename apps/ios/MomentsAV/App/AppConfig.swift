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

    static var momentsAPIBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "ACCOUNTAV_API_BASE_URL") as? String ?? ""
    }

    static var supportURL: URL {
        URL(string: "https://moments-av.avalsys.com/support")!
    }

    static var privacyPolicyURL: URL {
        URL(string: "https://moments-av.avalsys.com/privacy")!
    }

    static var termsURL: URL {
        URL(string: "https://moments-av.avalsys.com/terms")!
    }

    static var accountDeletionURL: URL {
        URL(string: "https://account.avalsys.com/account/delete")!
    }

    static func configureAVAccountIfPossible() {
        AccountAVClerk.configureIfPossible(publishableKey: avAccountKey)
    }
}
