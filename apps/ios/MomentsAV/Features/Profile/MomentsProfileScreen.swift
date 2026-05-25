import AVAppShellFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsProfileScreen: View {
    let mode: AVAppShellChromeItem
    let openSettings: () -> Void
    let openAccount: () -> Void

    @EnvironmentObject private var accountController: AccountController
    @Environment(\.avCommonAppExperience) private var appExperience
    @Environment(\.openURL) private var openURL

    var body: some View {
        AVSettingsProfileScreenScaffold(
            title: screenTitle,
            subtitle: screenSubtitle,
            backgroundStyle: AnyShapeStyle(MomentsTheme.shellBackground),
            showsTopSafeAreaShield: true
        ) {
            AVAppShellConfiguredBrandHeader(
                activeItem: mode,
                openSettings: openSettings,
                openAccount: openAccount
            )
        } content: {
            switch mode {
            case .settings:
                settingsContent
            case .account:
                accountContent
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var screenTitle: String {
        profileCopy.title(for: profileSurface)
    }

    private var screenSubtitle: String {
        profileCopy.subtitle(for: profileSurface)
    }

    private var profileSurface: AVSettingsProfileSurface {
        switch mode {
        case .settings:
            .settings
        case .account:
            .account
        }
    }

    private var profileCopy: AVSettingsProfileCopy {
        AVSettingsProfileCopy(
            identity: appExperience.identity,
            accountDetail: "sign-in, \(appExperience.identity.accountName) identity, credits, and account safety"
        )
    }

    private var accountName: String {
        accountController.user?.displayName ?? accountController.user?.emailAddress ?? "Not signed in"
    }

    private var accountDetail: String {
        accountController.user?.emailAddress
            ?? accountController.user?.id
            ?? "Sign in is required before creating and rendering Moments AV projects."
    }

    private var productItems: [AVSettingsInfoSectionItem] {
        [
            AVSettingsInfoSectionItem(
                id: "product",
                systemImage: "sparkles.tv.fill",
                title: "Product",
                detail: "\(appExperience.identity.shortName) creates private memory videos from draft to final export."
            ),
            AVSettingsInfoSectionItem(
                id: "create",
                systemImage: "plus.app.fill",
                title: "Create flow",
                detail: "Draft setup, media selection, story generation, preview, and final render stay in one guided workflow."
            ),
            AVSettingsInfoSectionItem(
                id: "projects",
                systemImage: "rectangle.stack.fill",
                title: "Projects",
                detail: "Projects are grouped as in progress or finished so active work and final exports stay easy to review."
            )
        ]
    }

    private var creditsItems: [AVSettingsInfoSectionItem] {
        [
            AVSettingsInfoSectionItem(
                id: "monthly",
                systemImage: "creditcard.fill",
                title: "Monthly credits",
                detail: MomentsCreditCopy.countTitle(accountController.creditBalance.proMonthly)
            ),
            AVSettingsInfoSectionItem(
                id: "promotional",
                systemImage: "gift.fill",
                title: "Bonus credits",
                detail: MomentsCreditCopy.countTitle(accountController.creditBalance.promotional)
            ),
            AVSettingsInfoSectionItem(
                id: "paid",
                systemImage: "bolt.circle.fill",
                title: "Standalone credits",
                detail: MomentsCreditCopy.countTitle(accountController.creditBalance.purchased)
            )
        ]
    }

    private var privacyItems: [AVSettingsInfoSectionItem] {
        [
            AVSettingsInfoSectionItem(
                id: "account",
                systemImage: "person.crop.circle.badge.checkmark",
                title: "Account required",
                detail: "Projects, credits, previews, and final renders stay attached to your signed-in \(appExperience.identity.accountName) account."
            ),
            AVSettingsInfoSectionItem(
                id: "privacy",
                systemImage: "lock.shield.fill",
                title: "Private workspace",
                detail: "Moments AV is built around personal media, project artifacts, and account-tied rendering history."
            ),
            AVSettingsInfoSectionItem(
                id: "avi",
                systemImage: "sparkles",
                title: "Avi guidance",
                detail: "Avi gives workflow guidance for story drafts, previews, final renders, and project review."
            )
        ]
    }

    private var accountItems: [AVSettingsInfoSectionItem] {
        [
            AVSettingsInfoSectionItem(
                id: "identity",
                systemImage: "person.crop.circle.fill",
                title: "Identity",
                detail: accountName
            ),
            AVSettingsInfoSectionItem(
                id: "credits",
                systemImage: "bolt.circle.fill",
                title: "Spendable credits",
                detail: MomentsCreditCopy.countTitle(accountController.creditBalance.spendable)
            ),
            AVSettingsInfoSectionItem(
                id: "account-provider",
                systemImage: "person.text.rectangle.fill",
                title: appExperience.identity.accountName,
                detail: accountController.isSignedIn ? "Connected to this device." : "Sign in before creating Moments AV projects."
            )
        ]
    }

    @ViewBuilder
    private var settingsContent: some View {
        AVSettingsConfiguredSettingsContent(
            sections: settingsSections,
            helpLegalContent: helpLegalContent,
            openURL: { url in openURL(url) }
        )
    }

    @ViewBuilder
    private var accountContent: some View {
        AVSettingsConfiguredAccountContent(
            isSignedIn: accountController.isSignedIn,
            signedInTitle: "Moments account connected",
            signedOutTitle: "Moments account required",
            detail: accountDetail,
            overviewItems: accountItems,
            sections: accountSections,
            signOutDetail: "Stop using this \(appExperience.identity.accountName) account on this device.",
            onSignOut: accountController.signOut
        ) {
            SignInActionsView(authenticationController: accountController)
        }
    }

    private var settingsSections: [AVSettingsConfiguredInfoSection] {
        [
            AVSettingsConfiguredInfoSection(
                id: "about",
                title: "About Moments AV",
                subtitle: "Product workflow basics for private memory videos.",
                items: productItems
            ),
            AVSettingsConfiguredInfoSection(
                id: "credits",
                title: "Credits and renders",
                subtitle: "Final exports use monthly subscription credits first, then bonus and standalone credits.",
                items: creditsItems
            ),
            AVSettingsConfiguredInfoSection(
                id: "privacy",
                title: "Privacy and guidance",
                subtitle: "Account, media, and Avi behavior for the Moments workflow.",
                items: privacyItems
            )
        ]
    }

    private var accountSections: [AVSettingsConfiguredInfoSection] {
        [
            AVSettingsConfiguredInfoSection(
                id: "credits",
                title: "Credit balance",
                subtitle: "Spendable balance across subscription, bonus, and standalone credits.",
                items: creditsItems
            )
        ]
    }

    private var helpLegalContent: AVSettingsConfiguredHelpLegalContent {
        AVSettingsConfiguredHelpLegalContent(
            identity: appExperience.identity,
            legalLinks: appExperience.legalLinks,
            privacyDetail: "Review how Moments AV handles account, media, project, and render data.",
            termsDetail: "Review the terms that apply to Moments AV."
        )
    }
}
