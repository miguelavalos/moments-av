import AccountAV
import Foundation

@MainActor
protocol AVAccountService {
    var isAvailable: Bool { get }
    var currentUser: AccountAVUser? { get }

    func signInWithApple() async throws
    func signInWithGoogle() async throws
    func signOut() async throws
}

enum AVAccountServiceError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "Account sign-in is not configured for this build."
        }
    }
}

struct DefaultAVAccountService: AVAccountService {
    private let accountService = ClerkAccountAVService(
        publishableKeyProvider: { AppConfig.avAccountKey },
        fallbackDisplayName: "Moments AV user",
        loggerSubsystem: "com.avalsys.momentsav"
    )

    var isAvailable: Bool {
        if Self.uiTestAccountUser != nil { return true }
        return accountService.isAvailable
    }

    var currentUser: AccountAVUser? {
        if let uiTestAccountUser = Self.uiTestAccountUser {
            return uiTestAccountUser
        }
        return accountService.currentUser
    }

    func signInWithApple() async throws {
        guard isAvailable else { throw AVAccountServiceError.unavailable }
        try await accountService.signInWithApple()
    }

    func signInWithGoogle() async throws {
        guard isAvailable else { throw AVAccountServiceError.unavailable }
        try await accountService.signInWithGoogle()
    }

    func signOut() async throws {
        if Self.uiTestAccountUser != nil { return }
        guard isAvailable else { return }
        try await accountService.signOut()
    }

    private static var uiTestAccountUser: AccountAVUser? {
        guard MomentsUITestEnvironment.current.hasAccountOverride else { return nil }

        return AccountAVUser(
            id: MomentsUITestEnvironment.accountUserId,
            displayName: MomentsUITestEnvironment.accountUserDisplayName,
            emailAddress: MomentsUITestEnvironment.accountUserEmailAddress
        )
    }
}
