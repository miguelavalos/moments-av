import Foundation
import SwiftUI

enum MomentsAppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case catalan = "ca"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: MomentsL10n.string("language.english")
        case .spanish: MomentsL10n.string("language.spanish")
        case .french: MomentsL10n.string("language.french")
        case .german: MomentsL10n.string("language.german")
        case .catalan: MomentsL10n.string("language.catalan")
        }
    }

    var autonym: String {
        switch self {
        case .english: "English"
        case .spanish: "Español"
        case .french: "Français"
        case .german: "Deutsch"
        case .catalan: "Català"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    static func resolved(from rawValue: String?) -> MomentsAppLanguage {
        guard let rawValue else { return .english }
        if let exactMatch = MomentsAppLanguage(rawValue: rawValue) {
            return exactMatch
        }

        let normalized = rawValue.lowercased()
        if normalized.hasPrefix("es") { return .spanish }
        if normalized.hasPrefix("fr") { return .french }
        if normalized.hasPrefix("de") { return .german }
        if normalized.hasPrefix("ca") { return .catalan }
        return .english
    }
}

final class MomentsAppLanguageController: ObservableObject {
    @Published private(set) var currentLanguage: MomentsAppLanguage

    var locale: Locale {
        currentLanguage.locale
    }

    private let userDefaults: UserDefaults
    private let userDefaultsKey = "momentsav.appLanguage"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let launchLanguage = ProcessInfo.processInfo.environment["MOMENTSAV_APP_LANGUAGE"] {
            let resolvedLanguage = MomentsAppLanguage.resolved(from: launchLanguage)
            currentLanguage = resolvedLanguage
            userDefaults.set(resolvedLanguage.rawValue, forKey: userDefaultsKey)
            return
        }

        currentLanguage = MomentsAppLanguage.resolved(
            from: userDefaults.string(forKey: userDefaultsKey) ?? Locale.preferredLanguages.first
        )
    }

    func select(_ language: MomentsAppLanguage) {
        userDefaults.set(language.rawValue, forKey: userDefaultsKey)
        guard currentLanguage != language else { return }
        currentLanguage = language
    }
}

enum MomentsL10n {
    private static let userDefaultsKey = "momentsav.appLanguage"

    static var locale: Locale {
        MomentsAppLanguage.resolved(
            from: UserDefaults.standard.string(forKey: userDefaultsKey) ?? Locale.preferredLanguages.first
        ).locale
    }

    static func string(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
    }

    static func string(_ key: String, _ arguments: CVarArg...) -> String {
        let format = string(key)
        guard !arguments.isEmpty else { return format }
        return String(format: format, locale: locale, arguments: arguments)
    }

    private static var bundle: Bundle {
        let selectedLanguage = MomentsAppLanguage.resolved(
            from: UserDefaults.standard.string(forKey: userDefaultsKey) ?? Locale.preferredLanguages.first
        )

        guard let path = Bundle.main.path(forResource: selectedLanguage.rawValue, ofType: "lproj"),
              let localizedBundle = Bundle(path: path) else {
            return .main
        }

        return localizedBundle
    }
}

enum MomentsAppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

final class MomentsAppThemeController: ObservableObject {
    @Published private(set) var currentTheme: MomentsAppTheme

    private let userDefaults: UserDefaults
    private let userDefaultsKey = "momentsav.appTheme"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        currentTheme = MomentsAppTheme(rawValue: userDefaults.string(forKey: userDefaultsKey) ?? "") ?? .system
    }

    func select(_ theme: MomentsAppTheme) {
        guard currentTheme != theme else { return }
        currentTheme = theme
        userDefaults.set(theme.rawValue, forKey: userDefaultsKey)
    }
}
