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

    static var revenueCatPublicAPIKey: String {
        configuredString(for: "MOMENTSAV_REVENUECAT_PUBLIC_API_KEY", fallback: "")
    }

    static var revenueCatOfferingID: String {
        configuredString(for: "MOMENTSAV_REVENUECAT_OFFERING_ID", fallback: "moments_credits")
    }

    static var revenueCatMonthlyPackageID: String {
        configuredString(for: "MOMENTSAV_REVENUECAT_MONTHLY_PACKAGE_ID", fallback: "$rc_monthly")
    }

    static var momentsConvexURL: String {
        Bundle.main.object(forInfoDictionaryKey: "MOMENTSAV_CONVEX_URL") as? String ?? ""
    }

    static var momentsAPIBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "ACCOUNTAV_API_BASE_URL") as? String ?? ""
    }

    static var supportURL: URL {
        configuredURL(for: "MOMENTSAV_SUPPORT_URL", fallback: "https://moments-av.avalsys.com/support")
    }

    static var privacyPolicyURL: URL {
        configuredURL(for: "MOMENTSAV_PRIVACY_URL", fallback: "https://moments-av.avalsys.com/privacy")
    }

    static var termsURL: URL {
        configuredURL(for: "MOMENTSAV_TERMS_URL", fallback: "https://moments-av.avalsys.com/terms")
    }

    static var accountDeletionURL: URL {
        configuredURL(for: "ACCOUNTAV_DELETE_ACCOUNT_URL", fallback: "https://account.avalsys.com/account/delete")
    }

    static var openSourceURL: URL {
        configuredURL(for: "MOMENTSAV_OPEN_SOURCE_URL", fallback: "https://github.com/avalsys/moments-av")
    }

    static func configureAVAccountIfPossible() {
        AccountAVClerk.configureIfPossible(publishableKey: avAccountKey)
    }

    private static func configuredURL(for key: String, fallback: String) -> URL {
        let trimmedValue = configuredString(for: key, fallback: fallback)
        return URL(string: trimmedValue.isEmpty ? fallback : trimmedValue) ?? URL(string: fallback)!
    }

    private static func configuredString(for key: String, fallback: String) -> String {
        let rawValue = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty || trimmedValue == "$(inherited)" ? fallback : trimmedValue
    }
}
