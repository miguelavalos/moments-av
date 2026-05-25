import SwiftUI

@main
struct MomentsAVApp: App {
    @StateObject private var languageController = MomentsAppLanguageController()
    @StateObject private var themeController = MomentsAppThemeController()

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
