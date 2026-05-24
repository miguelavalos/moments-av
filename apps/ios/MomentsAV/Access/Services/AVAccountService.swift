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
        accountService.isAvailable
    }

    var currentUser: AccountAVUser? {
        accountService.currentUser
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
        guard isAvailable else { return }
        try await accountService.signOut()
    }
}
