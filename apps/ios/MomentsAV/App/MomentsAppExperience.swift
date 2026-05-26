import AVBrandFoundation
import AVSettingsFoundation
import Foundation

enum MomentsAppExperience {
    private static let appIdentity = AVAppIdentity(
        displayName: "Moments AV",
        assistantName: "Avi",
        accountName: "Account AV"
    )

    @MainActor
    static var experience: AVCommonAppExperience {
        AVCommonAppExperience(
            identity: appIdentity,
            legalLinks: legalLinks,
            brandPalette: MomentsTheme.brandPalette,
            visualAssets: visualAssets,
            splashTagline: "Private memory films",
            splashStatus: "Preparing your studio",
            onboardingTitle: "Make memory films",
            onboardingSubtitle: "Turn selected media into private story drafts, previews, and renders.",
            onboardingPrimaryTitle: "SIGN IN",
            onboardingSecondaryTitle: "SKIP FOR NOW",
            onboardingBackgroundStart: .init(red: 0.97, green: 0.94, blue: 0.86),
            onboardingBackgroundMid: AVBrandColor.neutral50,
            onboardingBackgroundEnd: .init(red: 0.9, green: 0.93, blue: 0.89)
        )
    }

    static var identity: AVAppIdentity {
        appIdentity
    }

    static var visualAssets: AVCommonAppVisualAssets {
        AVCommonAppVisualAssets(
            headerLogoName: "MomentsHeaderWordmark",
            splashLogoName: "MomentsAVLogo",
            splashHeroName: "MomentsSplashHero",
            onboardingBrandName: "MomentsAVLogo",
            onboardingHeroName: "MomentsOnboardingHero",
            onboardingCTACompanionName: "AviOnboardingCTA",
            onboardingAuthPanelCompanionName: "AviLoginSheetPeek",
            footerAssistantName: "AviFooterIcon"
        )
    }

    @MainActor
    static var legalLinks: AVAppLegalLinks {
        AVAppLegalLinks(
            supportURL: AppConfig.supportURL,
            privacyURL: AppConfig.privacyPolicyURL,
            termsURL: AppConfig.termsURL,
            accountDeletionURL: AppConfig.accountDeletionURL
        )
    }

    static var settingsSubtitle: String {
        "Manage \(identity.shortName), credits, project privacy, and support links."
    }

    static var accountSubtitle: String {
        "Manage sign-in, \(identity.accountName) identity, credits, and account safety."
    }
}
