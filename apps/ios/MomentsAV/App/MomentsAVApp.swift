import SwiftUI

@main
struct MomentsAVApp: App {
    init() {
        AppConfig.configureAVAccountIfPossible()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
