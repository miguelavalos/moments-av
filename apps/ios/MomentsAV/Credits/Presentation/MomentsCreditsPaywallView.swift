import AVAppShellFoundation
import AVBrandFoundation
import AVPaywallFoundation
import SwiftUI

struct MomentsCreditsPaywallView: View {
    @Environment(\.openURL) private var openURL

    let balance: MomentsCreditBalance
    let isSignedIn: Bool
    let startSignInFlow: () -> Void
    let claimPromotionCode: (String) -> Void
    let dismiss: () -> Void

    @State private var promoCode = ""
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AVBrandSpacing.md) {
                    header
                    balanceOverview

                    if isSignedIn {
                        primaryOptions
                        promoClaim
                        restoreAndLegal
                    } else {
                        signInRequired
                    }

                    if let statusMessage {
                        AVPaywallStatusRow(systemImage: "info.circle.fill", message: statusMessage)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .background(MomentsTheme.shellBackground.ignoresSafeArea())
            .navigationTitle("Credits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: dismiss)
                }
            }
        }
        .accessibilityIdentifier("moments.credits.paywall")
    }

    private var header: some View {
        AVPaywallHeader(
            eyebrow: "Create videos",
            title: "Credits for memory videos",
            subtitle: isSignedIn
                ? "Pro is the simple plan for regular videos. Packs are there when you need extra credits."
                : "Sign in first so credits and purchases stay attached to your account.",
            titleFontSize: 26,
            subtitleFontSize: 13
        )
    }

    private var balanceOverview: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text(balanceTitle)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                Text("Cost starts at 1 credit")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(AVBrandColor.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            HStack(spacing: AVBrandSpacing.sm) {
                MomentsCreditsBalanceTile(title: "Monthly", value: balance.proMonthly)
                MomentsCreditsBalanceTile(title: "Promo", value: balance.promotional)
                MomentsCreditsBalanceTile(title: "Purchased", value: balance.purchased)
            }
        }
        .padding(AVBrandSpacing.md)
        .background(AVBrandColor.cardSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous))
        .shadow(color: AVBrandColor.softShadow.opacity(0.14), radius: 12, y: 6)
    }

    private var primaryOptions: some View {
        VStack(spacing: AVBrandSpacing.sm) {
            MomentsCreditsCompactProductRow(product: .proMonthly, isProminent: true) {
                startPurchase(.proMonthly)
            }

            HStack(spacing: AVBrandSpacing.sm) {
                MomentsCreditsPackButton(product: .starterPack) {
                    startPurchase(.starterPack)
                }
                MomentsCreditsPackButton(product: .creatorPack) {
                    startPurchase(.creatorPack)
                }
            }
        }
    }

    private var promoClaim: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.sm) {
            HStack(spacing: AVBrandSpacing.sm) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AVBrandColor.accent)

                TextField("Promo code", text: $promoCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(AVBrandTypography.bodyStrong)
                    .padding(.horizontal, AVBrandSpacing.md)
                    .frame(height: 46)
                    .background(AVBrandColor.cardSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.control, style: .continuous))

                Button(action: claimPromo) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(AVBrandColor.textInverse)
                        .frame(width: 46, height: 46)
                        .background(AVBrandColor.accent, in: RoundedRectangle(cornerRadius: AVBrandRadius.control, style: .continuous))
                }
                .disabled(normalizedPromoCode.isEmpty)
                .accessibilityLabel("Claim promotion")
                .accessibilityIdentifier("moments.credits.claimPromo")
            }

            Text("Have a promo code? Claim it here.")
                .font(AVBrandTypography.captionStrong)
                .foregroundStyle(AVBrandColor.textSecondary)
        }
        .padding(AVBrandSpacing.md)
        .background(AVBrandColor.mutedSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous))
    }

    private var restoreAndLegal: some View {
        VStack(spacing: AVBrandSpacing.md) {
            AVPaywallRestoreButton(
                title: "Restore purchases",
                accessibilityIdentifier: "moments.credits.restore"
            ) {
                statusMessage = "RevenueCat restore will be connected after App Store products are configured."
            }

            AVPaywallLegalLinks(
                links: [
                    AVPaywallLegalLink(title: "Terms", accessibilityIdentifier: "moments.credits.terms") {
                        openURL(AppConfig.termsURL)
                    },
                    AVPaywallLegalLink(title: "Privacy", accessibilityIdentifier: "moments.credits.privacy") {
                        openURL(AppConfig.privacyPolicyURL)
                    }
                ]
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var signInRequired: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.md) {
            Text("Sign in first")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(AVBrandColor.textPrimary)

            Text("Credits are account based, so login is required before purchases or promo claims.")
                .font(AVBrandTypography.body)
                .foregroundStyle(AVBrandColor.textSecondary)

            AVAppShellPrimaryButton("Sign in to continue", systemImage: "person.crop.circle.badge.checkmark") {
                dismiss()
                startSignInFlow()
            }
            .accessibilityIdentifier("moments.credits.signIn")
        }
        .padding(AVBrandSpacing.lg)
        .background(AVBrandColor.cardSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous))
    }

    private var balanceTitle: String {
        if balance.spendable == 0 {
            return "No credits available"
        }
        return MomentsCreditCopy.countTitle(balance.spendable) + " available"
    }

    private var balanceDetail: String {
        if balance.spendable == 0 {
            return "A final memory video starts at 1 credit."
        }
        return "Final renders use monthly credits first, then promo, then purchased."
    }

    private var normalizedPromoCode: String {
        promoCode.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func startPurchase(_ product: MomentsCreditPaywallProduct) {
        switch product.kind {
        case .subscription:
            statusMessage = "Ready for RevenueCat product \(product.id)."
        case .consumableCredits:
            statusMessage = "Ready for App Store consumable \(product.id)."
        }
    }

    private func claimPromo() {
        guard !normalizedPromoCode.isEmpty else { return }
        claimPromotionCode(normalizedPromoCode)
        statusMessage = "Promotion claimed locally. Backend validation comes next."
        promoCode = ""
    }
}

private struct MomentsCreditsCompactProductRow: View {
    let product: MomentsCreditPaywallProduct
    let isProminent: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AVBrandSpacing.md) {
                Image(systemName: product.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(AVBrandColor.accent)
                    .frame(width: 40, height: 40)
                    .background(AVBrandColor.accent.opacity(0.1), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: AVBrandSpacing.xs) {
                        Text(product.eyebrow)
                            .font(AVBrandTypography.eyebrow)
                            .foregroundStyle(AVBrandColor.accent)
                            .textCase(.uppercase)

                        Text("Best start")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(AVBrandColor.textInverse)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(AVBrandColor.accent, in: Capsule())
                    }

                    Text(product.title)
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(AVBrandColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(product.detail)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.78)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
            }
            .padding(AVBrandSpacing.md)
            .background(AVBrandColor.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
                    .stroke(AVBrandColor.accent.opacity(0.24), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("moments.credits.purchase.\(product.id)")
    }
}

private struct MomentsCreditsPackButton: View {
    let product: MomentsCreditPaywallProduct
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 5) {
                Image(systemName: product.systemImage)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AVBrandColor.accent)

                Text(product.title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text("Add credits")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AVBrandColor.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AVBrandSpacing.md)
            .background(AVBrandColor.cardSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
                    .stroke(AVBrandColor.borderSubtle.opacity(0.5), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("moments.credits.purchase.\(product.id)")
    }
}

private struct MomentsCreditsBalanceTile: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.xxs) {
            Text("\(value)")
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundStyle(AVBrandColor.textPrimary)

            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(AVBrandColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AVBrandSpacing.sm)
        .background(AVBrandColor.mutedSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.md, style: .continuous))
    }
}

private struct MomentsCreditsProductRow: View {
    let product: MomentsCreditPaywallProduct
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.md) {
            HStack(alignment: .top, spacing: AVBrandSpacing.md) {
                Image(systemName: product.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(AVBrandColor.accent)
                    .frame(width: 42, height: 42)
                    .background(AVBrandColor.accent.opacity(0.1), in: Circle())

                VStack(alignment: .leading, spacing: AVBrandSpacing.xxs) {
                    HStack(spacing: AVBrandSpacing.xs) {
                        Text(product.eyebrow)
                            .font(AVBrandTypography.eyebrow)
                            .foregroundStyle(AVBrandColor.accent)
                            .textCase(.uppercase)

                        if product.isRecommended {
                            Text("Best start")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(AVBrandColor.textInverse)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AVBrandColor.accent, in: Capsule())
                        }
                    }

                    Text(product.title)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(AVBrandColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(product.detail)
                        .font(AVBrandTypography.captionStrong)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            AVPaywallPrimaryButton(
                title: product.buttonTitle,
                accessibilityIdentifier: "moments.credits.purchase.\(product.id)",
                action: action
            )
        }
        .padding(AVBrandSpacing.lg)
        .background(
            product.isRecommended ? AVBrandColor.accent.opacity(0.08) : AVBrandColor.cardSurface,
            in: RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
                .stroke(product.isRecommended ? AVBrandColor.accent.opacity(0.28) : AVBrandColor.borderSubtle.opacity(0.5), lineWidth: 1)
        }
    }
}
