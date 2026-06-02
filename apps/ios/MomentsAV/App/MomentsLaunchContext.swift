import Foundation

struct MomentsLaunchContext {
    enum Tab: String {
        case home
        case create
        case inProgress
        case avi
    }

    let isUITesting: Bool
    let shouldDisableSplash: Bool
    let preferredTab: Tab?

    static let current = MomentsLaunchContext(environment: ProcessInfo.processInfo.environment)

    init(environment: [String: String]) {
        isUITesting = environment["MOMENTSAV_UI_TESTS"] == "1"
        shouldDisableSplash = isUITesting || environment["MOMENTSAV_DISABLE_SPLASH"] == "1"
        preferredTab = environment["MOMENTSAV_OPEN_TAB"].flatMap(Tab.init(rawValue:))
    }
}

struct MomentsUITestEnvironment {
    let environment: [String: String]

    static let current = MomentsUITestEnvironment(environment: ProcessInfo.processInfo.environment)

    var isEnabled: Bool {
        environment["MOMENTSAV_UI_TESTS"] == "1"
    }

    var accountMode: String? {
        guard isEnabled else { return nil }
        return environment["MOMENTSAV_UI_TESTS_ACCOUNT_MODE"]
    }

    var createFixture: String? {
        guard isEnabled else { return nil }
        return environment["MOMENTSAV_CREATE_FIXTURE"]
    }

    var hasAccountOverride: Bool {
        accountMode != nil
    }

    static let accountUserId = "moments-ui-test-user"
    static let accountUserDisplayName = "Moments UI Test User"
    static let accountUserEmailAddress = "moments-ui-test@example.test"
}
