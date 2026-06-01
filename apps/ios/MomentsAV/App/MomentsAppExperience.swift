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
            splashTagline: MomentsL10n.string("app.splash.tagline"),
            splashStatus: MomentsL10n.string("app.splash.status"),
            onboardingTitle: MomentsL10n.string("app.onboarding.title"),
            onboardingSubtitle: MomentsL10n.string("app.onboarding.subtitle"),
            onboardingPrimaryTitle: MomentsL10n.string("app.onboarding.signIn"),
            onboardingSecondaryTitle: MomentsL10n.string("app.onboarding.skip"),
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
        MomentsL10n.string("app.settings.subtitle", identity.shortName)
    }

    static var accountSubtitle: String {
        MomentsL10n.string("app.account.subtitle", identity.accountName)
    }
}
