import AVAppShellFoundation
import AVBrandFoundation
import AVSettingsFoundation
import SwiftUI

struct MomentsProfileScreen: View {
    let mode: AVAppShellChromeItem
    let openSettings: () -> Void
    let openAccount: () -> Void
    let openCredits: () -> Void
    let startSignInFlow: () -> Void

    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var languageController: MomentsAppLanguageController
    @EnvironmentObject private var themeController: MomentsAppThemeController
    @Environment(\.avCommonAppExperience) private var appExperience
    @Environment(\.openURL) private var openURL
    @State private var showsCreditDetails = false

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
        switch mode {
        case .settings:
            localized("profile.settingsScreen.title")
        case .account:
            localized("profile.accountScreen.title")
        }
    }

    private var screenSubtitle: String {
        switch mode {
        case .settings:
            localized("profile.settingsScreen.subtitle")
        case .account:
            localized("profile.accountScreen.subtitle")
        }
    }

    @ViewBuilder
    private var settingsContent: some View {
        appPreferencesCard
        onThisDeviceCard
        helpAndLegalCard
    }

    @ViewBuilder
    private var accountContent: some View {
        accountCard
        if accountController.isSignedIn {
            creditsCard
        }
        momentsProCard
        if accountController.isSignedIn {
            accountSafetyCard
        }
    }

    private var appPreferencesCard: some View {
        AVSettingsSectionCard(
            title: localized("profile.preferences.title"),
            subtitle: localized("profile.preferences.subtitle")
        ) {
            AVSettingsInfoRow(
                systemImage: "globe",
                title: localized("profile.preferences.language.title"),
                detail: localized("profile.preferences.language.detail")
            )

            languageSelector

            AVSettingsInfoRow(
                systemImage: "circle.lefthalf.filled",
                title: localized("profile.preferences.theme.title"),
                detail: localized("profile.preferences.theme.detail")
            )

            themeSelector
        }
    }

    private var onThisDeviceCard: some View {
        AVSettingsSectionCard(
            title: localized("profile.local.title"),
            subtitle: localized("profile.local.subtitle")
        ) {
            VStack(alignment: .leading, spacing: 12) {
                AVSettingsInfoRow(
                    systemImage: "folder",
                    title: localized("profile.local.projects.title"),
                    detail: localized("profile.local.projects.detail")
                )
                AVSettingsInfoRow(
                    systemImage: "photo.on.rectangle.angled",
                    title: localized("profile.local.media.title"),
                    detail: localized("profile.local.media.detail")
                )
                AVSettingsInfoRow(
                    systemImage: "sparkles.rectangle.stack",
                    title: localized("profile.local.artifacts.title"),
                    detail: localized("profile.local.artifacts.detail")
                )
            }
        }
    }

    private var helpAndLegalCard: some View {
        AVSettingsHelpLegalSection(
            title: localized("profile.help.title"),
            subtitle: localized("profile.help.subtitle"),
            openSourceTitle: localized("profile.help.opensource.title"),
            openSourceDetail: localized("profile.help.opensource.detail"),
            sourceCodeURL: AppConfig.openSourceURL,
            sourceCodeTitle: localized("profile.help.sourceCode.title"),
            sourceCodeDetail: localized("profile.help.sourceCode.detail"),
            legalLinks: settingsLegalLinks,
            supportTitle: localized("profile.help.support.title"),
            supportDetail: localized("profile.help.support.detail"),
            privacyTitle: localized("profile.help.privacy.title"),
            privacyDetail: localized("profile.help.privacy.detail"),
            termsTitle: localized("profile.help.terms.title"),
            termsDetail: localized("profile.help.terms.detail"),
            accountDeletionTitle: "",
            accountDeletionDetail: "",
            openURL: { url in openURL(url) }
        )
    }

    private var accountCard: some View {
        AVSettingsSectionCard(
            title: localized("profile.account.title"),
            subtitle: accountIdentityDetail
        ) {
            Divider()
                .overlay(AVBrandColor.borderSubtle)

            VStack(alignment: .leading, spacing: 12) {
                AVSettingsInfoRow(
                    systemImage: "person.crop.circle",
                    title: localized("profile.summary.account.title"),
                    detail: sessionDetail
                )
                if accountController.isSignedIn, let emailAddress = accountController.user?.emailAddress {
                    AVSettingsInfoRow(
                        systemImage: "envelope",
                        title: localized("profile.account.email.title"),
                        detail: emailAddress
                    )
                }
                AVSettingsInfoRow(
                    systemImage: "sparkles.rectangle.stack",
                    title: localized("profile.summary.plan.title"),
                    detail: accessDetail
                )
            }

            accountActionButton
        }
    }

    private var creditsCard: some View {
        AVSettingsSectionCard(
            title: "Credits",
            subtitle: MomentsCreditCopy.availableDetail(accountController.creditBalance)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                AVSettingsInfoRow(
                    systemImage: "creditcard",
                    title: "Available credits",
                    detail: MomentsCreditCopy.availableDetail(accountController.creditBalance)
                )

                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        showsCreditDetails.toggle()
                    }
                } label: {
                    Label(showsCreditDetails ? "Hide details" : "View details", systemImage: showsCreditDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .buttonStyle(.plain)

                if showsCreditDetails {
                    ForEach(MomentsCreditCopy.detailRows(for: accountController.creditBalance)) { row in
                        AVSettingsInfoRow(
                            systemImage: row.systemImage,
                            title: row.title,
                            detail: row.detail
                        )
                    }
                }
            }

            AVSettingsButton(
                title: "Get more credits",
                style: .primary,
                action: openCredits
            )
            .accessibilityIdentifier("profile.credits.open")
        }
    }

    private var momentsProCard: some View {
        AVSettingsSectionCard(
            title: localized("profile.pro.title"),
            subtitle: momentsProSubtitle
        ) {
            VStack(alignment: .leading, spacing: 12) {
                AVSettingsInfoRow(
                    systemImage: "film.stack",
                    title: localized("profile.pro.library.title"),
                    detail: localized("profile.pro.library.detail")
                )
                AVSettingsInfoRow(
                    systemImage: "checkmark.seal.fill",
                    title: localized("profile.pro.sync.title"),
                    detail: localized("profile.pro.sync.detail")
                )
                AVSettingsInfoRow(
                    systemImage: "wand.and.stars",
                    title: localized("profile.pro.avi.title"),
                    detail: localized("profile.pro.avi.detail")
                )
            }

            if accountController.isSignedIn {
                AVSettingsButton(
                    title: localized("profile.pro.manage"),
                    style: .secondary,
                    action: { openURL(URL(string: "https://apps.apple.com/account/subscriptions")!) }
                )
            }
        }
        .accessibilityIdentifier("profile.pro.card")
    }

    private var accountSafetyCard: some View {
        AVSettingsSectionCard(
            title: localized("profile.safety.title"),
            subtitle: localized("profile.safety.subtitle"),
            spacing: 12
        ) {
            AVSettingsActionRow(
                systemImage: "exclamationmark.shield",
                title: localized("profile.safety.delete.title"),
                detail: localized("profile.safety.delete.detail"),
                action: { openURL(appExperience.legalLinks.accountDeletionURL ?? AppConfig.accountDeletionURL) }
            )
            .accessibilityIdentifier("profile.safety.delete")
        }
    }

    @ViewBuilder
    private var accountActionButton: some View {
        if accountController.isSignedIn {
            AVSettingsButton(
                title: localized("profile.actions.signOut"),
                style: .secondary,
                action: accountController.signOut
            )
            .accessibilityIdentifier("profile.account.signOut")
        } else {
            AVSettingsButton(
                title: accountController.isAccountAvailable
                    ? localized("profile.account.connect")
                    : localized("profile.account.connectUnavailable"),
                style: .primary,
                action: startSignInFlow
            )
            .disabled(!accountController.isAccountAvailable)
            .accessibilityIdentifier("profile.account.signIn")
        }
    }

    private var languageSelector: some View {
        Menu {
            ForEach(MomentsAppLanguage.allCases) { language in
                Button {
                    languageController.select(language)
                } label: {
                    if languageController.currentLanguage == language {
                        Label {
                            Text("\(language.displayName) (\(language.autonym))")
                        } icon: {
                            Image(systemName: "checkmark")
                        }
                    } else {
                        Text("\(language.displayName) (\(language.autonym))")
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(languageController.currentLanguage.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(languageController.currentLanguage.autonym)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AVBrandColor.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MomentsTheme.highlight)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AVBrandColor.mutedSurface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AVBrandColor.borderSubtle, lineWidth: 1)
            }
        }
    }

    private var themeSelector: some View {
        HStack(spacing: 10) {
            ForEach(MomentsAppTheme.allCases) { theme in
                AVSettingsOptionButton(
                    title: themeLabel(for: theme),
                    systemImage: themeSymbol(for: theme),
                    isSelected: themeController.currentTheme == theme,
                    action: { themeController.select(theme) }
                )
            }
        }
    }

    private var accountIdentityDetail: String {
        if accountController.isSignedIn {
            return accountController.user?.emailAddress
                ?? accountController.user?.id
                ?? "Connected to \(appExperience.identity.accountName)."
        }
        return localized("profile.account.identity.guest")
    }

    private var sessionDetail: String {
        if accountController.isSignedIn {
            return accountController.user?.displayName
                ?? accountController.user?.emailAddress
                ?? "Signed in on this device."
        }
        return localized("profile.summary.account.detail.guest")
    }

    private var accessDetail: String {
        if accountController.isSignedIn {
            return MomentsCreditCopy.availableDetail(accountController.creditBalance)
        }
        return localized("profile.summary.plan.detail.guest")
    }

    private var momentsProSubtitle: String {
        if accountController.isSignedIn {
            return localized("profile.pro.subtitle.free")
        }
        return localized("profile.pro.subtitle.guest")
    }

    private var settingsLegalLinks: AVAppLegalLinks {
        AVAppLegalLinks(
            supportURL: appExperience.legalLinks.supportURL,
            privacyURL: appExperience.legalLinks.privacyURL,
            termsURL: appExperience.legalLinks.termsURL
        )
    }

    private func themeLabel(for theme: MomentsAppTheme) -> String {
        switch theme {
        case .system: localized("profile.preferences.theme.system")
        case .light: localized("profile.preferences.theme.light")
        case .dark: localized("profile.preferences.theme.dark")
        }
    }

    private func themeSymbol(for theme: MomentsAppTheme) -> String {
        switch theme {
        case .system: "iphone"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    private func localized(_ key: String) -> String {
        MomentsL10n.string(key)
    }
}
