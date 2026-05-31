import AVAppShellFoundation
import AVBrandFoundation
import AVPaywallFoundation
import SwiftUI

struct MomentsCreditsPaywallView: View {
    @Environment(\.openURL) private var openURL

    let balance: MomentsCreditBalance
    let isSignedIn: Bool
    let startSignInFlow: () -> Void
    let claimPromotionCode: (String) async throws -> Int
    let purchaseCatalog: MomentsPurchaseCatalog
    let loadPurchaseProducts: () async -> Void
    let purchaseProduct: (MomentsCreditPaywallProduct) async throws -> MomentsPurchaseResult
    let restorePurchases: () async throws -> MomentsPurchaseResult
    let dismiss: () -> Void

    @State private var promoCode = ""
    @State private var statusMessage: String?
    @State private var promoStatusMessage: String?
    @State private var isClaimingPromo = false
    @State private var purchasingProductID: String?
    @State private var isRestoringPurchases = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AVBrandSpacing.md) {
                    header
                    balanceOverview

                    if isSignedIn {
                        monthlyPlan
                        creditPacks
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
        .task(id: isSignedIn) {
            guard isSignedIn else { return }
            await loadPurchaseProducts()
        }
    }

    private var header: some View {
        AVPaywallHeader(
            eyebrow: "Moments AV",
            title: "Create videos with credits",
            subtitle: isSignedIn
                ? "Choose Pro for the best monthly value, or add one-time credits when you need them."
                : "Sign in first so credits and purchases stay attached to your account.",
            titleFontSize: 26,
            subtitleFontSize: 13
        )
    }

    private var balanceOverview: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("Wallet")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                Text("Final videos start at 1 credit")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(AVBrandColor.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            HStack(spacing: AVBrandSpacing.sm) {
                MomentsCreditsPrimaryBalanceTile(title: "Video Credits", value: balance.spendable, detail: balanceTitle)
                MomentsCreditsPrimaryBalanceTile(title: "Story Reviews", value: balance.reviewAllowanceRemaining, detail: storyReviewsDetail)
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

    private var creditPacks: some View {
        VStack(spacing: AVBrandSpacing.sm) {
            sectionHeader(title: "One-time credits", detail: "Credit packs do not renew and include extra Story Reviews.")

            HStack(spacing: AVBrandSpacing.sm) {
                MomentsCreditsPackButton(
                    product: .starterPack,
                    priceText: priceText(for: .starterPack),
                    isBusy: purchasingProductID == MomentsCreditProductID.starterPackProduct,
                    isDisabled: isPurchaseActionDisabled
                ) {
                    startPurchase(.starterPack)
                }
                MomentsCreditsPackButton(
                    product: .creatorPack,
                    priceText: priceText(for: .creatorPack),
                    isBusy: purchasingProductID == MomentsCreditProductID.creatorPackProduct,
                    isDisabled: isPurchaseActionDisabled
                ) {
                    startPurchase(.creatorPack)
                }
            }
        }
    }

    private var monthlyPlan: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.sm) {
            sectionHeader(title: "Pro monthly", detail: "Better monthly credit value with Pro-only watermark removal. No unlimited generation.")

            MomentsProPlanCard(
                product: .proMonthly,
                priceText: monthlyPriceText(for: .proMonthly),
                isBusy: purchasingProductID == MomentsCreditProductID.proMonthlyProduct,
                isDisabled: isPurchaseActionDisabled
            ) {
                startPurchase(.proMonthly)
            }
        }
    }

    private var promoClaim: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.sm) {
            sectionHeader(title: "Promo code", detail: "Enter a code from support, testing, or a private campaign.")

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
                    ZStack {
                        if isClaimingPromo {
                            ProgressView()
                                .tint(AVBrandColor.textInverse)
                        } else {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 17, weight: .black))
                                .foregroundStyle(AVBrandColor.textInverse)
                        }
                    }
                    .frame(width: 46, height: 46)
                    .background(AVBrandColor.accent, in: RoundedRectangle(cornerRadius: AVBrandRadius.control, style: .continuous))
                }
                .disabled(normalizedPromoCode.isEmpty || isClaimingPromo)
                .accessibilityLabel("Claim promotion")
                .accessibilityIdentifier("moments.credits.claimPromo")
            }

            Text("Promo codes are shared by support or campaign invitations.")
                .font(AVBrandTypography.captionStrong)
                .foregroundStyle(AVBrandColor.textSecondary)

            if let promoStatusMessage {
                HStack(alignment: .firstTextBaseline, spacing: AVBrandSpacing.xs) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AVBrandColor.textSecondary)

                    Text(promoStatusMessage)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 2)
            }
        }
        .padding(AVBrandSpacing.md)
        .background(AVBrandColor.mutedSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous))
    }

    private var restoreAndLegal: some View {
        VStack(spacing: AVBrandSpacing.md) {
            Text("Pro renews monthly until canceled. Manage or cancel in App Store settings. One-time credit packs do not renew.")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(AVBrandColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                restorePreviousPurchases()
            } label: {
                HStack(spacing: AVBrandSpacing.xs) {
                    if isRestoringPurchases {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(AVBrandColor.textSecondary)
                    }

                    Text("Restore purchases")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AVBrandColor.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .disabled(isRestoringPurchases || purchasingProductID != nil)
            .accessibilityIdentifier("moments.credits.restore")

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

    private func sectionHeader(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(AVBrandColor.textPrimary)

            Text(detail)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AVBrandColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            return "No credits"
        }
        return MomentsCreditCopy.countTitle(balance.spendable)
    }

    private var storyReviewsDetail: String {
        if balance.reviewAllowanceRemaining == 0 {
            return "No reviews"
        }
        return "\(balance.reviewAllowanceRemaining) available"
    }

    private var normalizedPromoCode: String {
        promoCode.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isPurchaseActionDisabled: Bool {
        purchasingProductID != nil || isRestoringPurchases
    }

    private func priceText(for product: MomentsCreditPaywallProduct) -> String {
        purchaseCatalog.localizedPrice(for: product) ?? product.buttonTitle
    }

    private func monthlyPriceText(for product: MomentsCreditPaywallProduct) -> String {
        guard let price = purchaseCatalog.localizedPrice(for: product) else {
            return product.buttonTitle
        }
        return "\(price)/month"
    }

    private func startPurchase(_ product: MomentsCreditPaywallProduct) {
        guard !isPurchaseActionDisabled else { return }
        purchasingProductID = product.id
        statusMessage = nil

        Task {
            do {
                let result = try await purchaseProduct(product)
                switch result.status {
                case .purchased:
                    statusMessage = "\(product.title) purchased. Credits may take a moment to appear."
                case .restored:
                    statusMessage = "Purchases restored. Credits may take a moment to appear."
                case .cancelled:
                    statusMessage = "Purchase cancelled."
                }
            } catch {
                statusMessage = error.localizedDescription
            }
            purchasingProductID = nil
        }
    }

    private func restorePreviousPurchases() {
        guard !isRestoringPurchases, purchasingProductID == nil else { return }
        isRestoringPurchases = true
        statusMessage = nil

        Task {
            do {
                let result = try await restorePurchases()
                switch result.status {
                case .restored:
                    statusMessage = "Purchases restored. Credits may take a moment to appear."
                case .purchased:
                    statusMessage = "Purchase restored. Credits may take a moment to appear."
                case .cancelled:
                    statusMessage = "Restore cancelled."
                }
            } catch {
                statusMessage = error.localizedDescription
            }
            isRestoringPurchases = false
        }
    }

    private func claimPromo() {
        guard !normalizedPromoCode.isEmpty else { return }
        let code = normalizedPromoCode
        isClaimingPromo = true
        promoStatusMessage = nil

        Task {
            do {
                let creditsGranted = try await claimPromotionCode(code)
                promoStatusMessage = "\(creditsGranted) promo \(creditsGranted == 1 ? "credit" : "credits") added."
                promoCode = ""
            } catch {
                promoStatusMessage = error.localizedDescription
            }
            isClaimingPromo = false
        }
    }
}

private struct MomentsProPlanCard: View {
    let product: MomentsCreditPaywallProduct
    let priceText: String
    let isBusy: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AVBrandSpacing.md) {
                HStack(alignment: .top, spacing: AVBrandSpacing.md) {
                    Image(systemName: product.systemImage)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(AVBrandColor.textInverse)
                        .frame(width: 44, height: 44)
                        .background(AVBrandColor.accent, in: RoundedRectangle(cornerRadius: AVBrandRadius.control, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: AVBrandSpacing.xs) {
                            Text(product.eyebrow)
                                .font(AVBrandTypography.eyebrow)
                                .foregroundStyle(AVBrandColor.accent)
                                .textCase(.uppercase)

                            Text("No watermark")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(AVBrandColor.textInverse)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(AVBrandColor.accent, in: Capsule())
                        }

                        Text(product.title)
                            .font(.system(size: 23, weight: .black, design: .rounded))
                            .foregroundStyle(AVBrandColor.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text(priceText)
                            .font(.system(size: 19, weight: .black, design: .rounded))
                            .foregroundStyle(AVBrandColor.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(product.detail)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: AVBrandSpacing.xs) {
                    MomentsProBenefitRow(systemImage: "video.fill", text: "6 Video Credits each month")
                    MomentsProBenefitRow(systemImage: "wand.and.stars", text: "15 Story Reviews each month")
                    MomentsProBenefitRow(systemImage: "checkmark.seal.fill", text: "Final videos without the Moments AV watermark")
                }

                HStack(spacing: AVBrandSpacing.sm) {
                    Text(callToActionTitle)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(AVBrandColor.textInverse)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Spacer()

                    if isBusy {
                        ProgressView()
                            .controlSize(.small)
                            .tint(AVBrandColor.textInverse)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(AVBrandColor.textInverse)
                    }
                }
                .padding(.horizontal, AVBrandSpacing.md)
                .frame(height: 48)
                .background(AVBrandColor.accent, in: RoundedRectangle(cornerRadius: AVBrandRadius.control, style: .continuous))
            }
            .padding(AVBrandSpacing.lg)
            .background(AVBrandColor.cardSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
                    .stroke(AVBrandColor.accent.opacity(0.28), lineWidth: 1)
            }
            .shadow(color: AVBrandColor.softShadow.opacity(0.18), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityIdentifier("moments.credits.purchase.\(product.id)")
    }

    private var callToActionTitle: String {
        priceText == product.buttonTitle ? product.buttonTitle : "\(product.buttonTitle) - \(priceText)"
    }
}

private struct MomentsProBenefitRow: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: AVBrandSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(AVBrandColor.accent)
                .frame(width: 18)

            Text(text)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(AVBrandColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct MomentsCreditsPackButton: View {
    let product: MomentsCreditPaywallProduct
    let priceText: String
    let isBusy: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AVBrandSpacing.xs) {
                HStack(alignment: .top) {
                    Image(systemName: product.systemImage)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(AVBrandColor.accent)

                    Spacer(minLength: AVBrandSpacing.xs)

                    Text(priceText)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AVBrandColor.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Text(product.title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(product.detail)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: AVBrandSpacing.xs)

                HStack(spacing: AVBrandSpacing.xs) {
                    Text(product.buttonTitle)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AVBrandColor.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    if isBusy {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(AVBrandColor.accent)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(AVBrandColor.accent)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 128, alignment: .topLeading)
            .padding(AVBrandSpacing.md)
            .background(AVBrandColor.cardSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
                    .stroke(AVBrandColor.borderSubtle.opacity(0.5), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityIdentifier("moments.credits.purchase.\(product.id)")
    }
}

private struct MomentsCreditsPrimaryBalanceTile: View {
    let title: String
    let value: Int
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(AVBrandColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text("\(value)")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(AVBrandColor.textPrimary)
                .monospacedDigit()

            Text(detail)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(AVBrandColor.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AVBrandSpacing.md)
        .background(AVBrandColor.mutedSurface, in: RoundedRectangle(cornerRadius: AVBrandRadius.md, style: .continuous))
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
