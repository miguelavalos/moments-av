import SwiftUI

@main
struct MomentsAVApp: App {
    @StateObject private var languageController = AppLanguageController()
    @StateObject private var themeController = AppThemeController()

    init() {
        AppConfig.configureAVAccountIfPossible()
    }

    var body: some Scene {
        WindowGroup {
            MomentsAppBootstrapView()
                .environmentObject(languageController)
                .environmentObject(themeController)
                .environment(\.locale, languageController.locale)
                .avCommonAppExperience(MomentsAppExperience.experience)
                .preferredColorScheme(themeController.currentTheme.preferredColorScheme)
        }
    }
}
