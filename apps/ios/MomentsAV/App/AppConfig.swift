import AccountAV
import AVDiagnosticsFoundation
import Foundation

@MainActor
enum AppConfig {
    static var avAccountKey: String {
        Bundle.main.object(forInfoDictionaryKey: "ACCOUNTAV_PUBLISHABLE_KEY") as? String ?? ""
    }

    static var isAVAccountAvailable: Bool {
        !avAccountKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static var diagnosticsConfiguration: AVDiagnosticsConfiguration {
        AVDiagnosticsConfiguration(
            dsn: configuredString(for: "MOMENTSAV_IOS_SENTRY_DSN", fallback: ""),
            environment: diagnosticsEnvironment,
            releaseName: diagnosticsReleaseName,
            tracesSampleRate: 0,
            isEnabled: isDiagnosticsEnabled
        )
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
        configuredSupportURL(
            explicitURL: configuredOptionalURL(for: "SUPPORTAV_BASE_URL"),
            email: configuredOptionalString(for: "SUPPORT_EMAIL_TO") ?? "support@avalsys.com"
        ) ?? URL(string: "https://support-av.avalsys.com/")!
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
        AccountAVClerk.configureIfPossible(
            publishableKey: avAccountKey,
            keychainService: configuredOptionalString(for: "ACCOUNTAV_KEYCHAIN_SERVICE"),
            keychainAccessGroup: configuredOptionalString(for: "ACCOUNTAV_KEYCHAIN_ACCESS_GROUP")
        )
    }

    private static var diagnosticsEnvironment: AVDiagnosticsEnvironment {
        switch configuredString(for: "MOMENTSAV_CONFIG_ENVIRONMENT", fallback: "dev").lowercased() {
        case "prod", "production":
            return .production
        case "staging", "preview":
            return .preview
        case "dev", "debug":
            return .debug
        default:
            return .debug
        }
    }

    private static var diagnosticsReleaseName: String? {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.avalsys.momentsav"
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(bundleIdentifier)@\(version)+\(build)"
    }

    private static var isDiagnosticsEnabled: Bool {
        #if DEBUG
        false
        #else
        !configuredString(for: "MOMENTSAV_IOS_SENTRY_DSN", fallback: "").isEmpty
        #endif
    }

    private static func configuredURL(for key: String, fallback: String) -> URL {
        let trimmedValue = configuredString(for: key, fallback: fallback)
        return URL(string: trimmedValue.isEmpty ? fallback : trimmedValue) ?? URL(string: fallback)!
    }

    private static func configuredOptionalURL(for key: String) -> URL? {
        guard let rawValue = configuredOptionalString(for: key) else {
            return nil
        }
        return URL(string: rawValue)
    }

    private static func configuredString(for key: String, fallback: String) -> String {
        configuredOptionalString(for: key) ?? fallback
    }

    private static func configuredOptionalString(for key: String) -> String? {
        let rawValue = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty || trimmedValue == "$(inherited)" ? nil : trimmedValue
    }

    private static func configuredSupportURL(explicitURL: URL?, email: String?) -> URL? {
        if let explicitURL {
            return explicitURL
        }
        guard let email else { return nil }
        let encodedSubject = "Moments AV Support".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Moments%20AV%20Support"
        return URL(string: "mailto:\(email)?subject=\(encodedSubject)")
    }
}
