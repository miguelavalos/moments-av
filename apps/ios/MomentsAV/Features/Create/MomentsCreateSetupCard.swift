import AVAviFoundation
import AVAppShellFoundation
import AVBrandFoundation
import SwiftUI

struct MomentsCreateSetupCard: View {
    @Binding var form: MomentSetupForm
    @State private var showsOptions = false
    @State private var showsMomentSheet = false
    @State private var showsMediaSourceSheet = false
    @State private var pendingInitialMediaSource: MomentsCreateInitialMediaSource?
    let selectedStyle: MomentCreationStyle
    let styles: [MomentCreationStyle]
    let selectedMusicPreset: MomentMusicPreset
    let presentation: MomentsCreateSetupPresentation
    let newMomentStep: MomentsCreateNewMomentStep
    let isSignedIn: Bool
    let balance: MomentsCreditBalance
    let canBeginNewMoment: Bool
    let beginNewMoment: () -> Void
    let beginAlbumMoment: () -> Void
    let editStyle: () -> Void
    let selectStyle: (MomentCreationStyle) -> Void
    let selectMusicPreset: (MomentMusicPreset) -> Void
    let createMoment: () -> Void
    let discardMoment: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void

    @ViewBuilder
    var body: some View {
        if presentation.isSetupLocked {
            lockedMomentContent
        } else if newMomentStep == .status {
            VStack(alignment: .leading, spacing: AVBrandSpacing.lg) {
                MomentsCreateNewMomentStatus(
                    isSignedIn: isSignedIn,
                    balance: balance,
                    selectedStyle: selectedStyle,
                    guidance: aviGuidance,
                    canBeginNewMoment: canBeginNewMoment,
                    beginNewMoment: {
                        form.creationMode = .quick
                        form.look = .real
                        form.duration = .auto
                        form.mediaUse = .aviPick
                        showsMediaSourceSheet = true
                    },
                    planMoment: {
                        form.creationMode = .planned
                        showsMomentSheet = true
                        editStyle()
                    },
                    startSignInFlow: startSignInFlow,
                    openCredits: openCredits
                )

                activeMomentAndErrorContent
            }
            .sheet(isPresented: $showsMomentSheet) {
                styleStep
                    .padding(20)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showsMediaSourceSheet) {
                MomentsCreateMediaSourceSheet { source in
                    pendingInitialMediaSource = source
                    showsMediaSourceSheet = false
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .onChange(of: showsMediaSourceSheet) { wasPresented, isPresented in
                guard wasPresented, !isPresented, let pendingInitialMediaSource else { return }
                self.pendingInitialMediaSource = nil
                switch pendingInitialMediaSource {
                case .photos:
                    beginNewMoment()
                case .album:
                    beginAlbumMoment()
                }
            }
        } else {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: 16) {
                    switch newMomentStep {
                    case .status:
                        EmptyView()
                    case .style:
                        styleStep
                    case .summary:
                        styleStep
                    }

                    errorContent
                }
            }
        }
    }

    private var aviGuidance: MomentsCreateAviGuidance {
        MomentsCreateAviGuidanceResolver.make(
            isSignedIn: isSignedIn,
            balance: balance,
            selectedStyle: selectedStyle,
            step: newMomentStep,
            isSetupLocked: presentation.isSetupLocked,
            setupErrorMessage: presentation.setupErrorMessage
        )
    }

    private var lockedMomentContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            MomentsCreateMomentHubHeader(
                guidance: aviGuidance,
                style: selectedStyle,
                selectedMusicPreset: selectedMusicPreset
            )

            Button {
                showsOptions = true
            } label: {
                HStack(spacing: 10) {
                    Label(L10n.string("create.options.title"), systemImage: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .black))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .black))
                }
                .foregroundStyle(AVBrandColor.textPrimary)
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showsOptions) {
                MomentsCreateQuickCustomizeSection(
                    form: $form,
                    selectedStyle: selectedStyle,
                    selectedMusicPreset: selectedMusicPreset,
                    selectMusicPreset: selectMusicPreset,
                    isLocked: false
                )
                .padding(20)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var activeMomentAndErrorContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if presentation.showsActiveMoment {
                HStack {
                    Spacer(minLength: 0)

                    Button(action: discardMoment) {
                        Label(L10n.string("create.discard.current"), systemImage: "trash")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .buttonStyle(MomentsCreateNeutralInlineButtonStyle())
                    .disabled(!presentation.canStartAnotherMoment)
                }
            }

            if let setupErrorMessage = presentation.setupErrorMessage {
                Text(setupErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var errorContent: some View {
        Group {
            if let setupErrorMessage = presentation.setupErrorMessage {
                Text(setupErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var styleStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            MomentsCreateStepHeader(
                stepTitle: L10n.string("create.selector.theme.title"),
                title: L10n.string("create.style.pickFeeling"),
                detail: aviGuidance.message
            )

            MomentsCreateStyleGrid(
                styles: styles,
                selectedStyle: selectedStyle,
                isLocked: presentation.isSetupLocked,
                selectStyle: {
                    selectStyle($0)
                    showsMomentSheet = false
                }
            )
        }
    }

}

private struct MomentsCreateNewMomentStatus: View {
    let isSignedIn: Bool
    let balance: MomentsCreditBalance
    let selectedStyle: MomentCreationStyle
    let guidance: MomentsCreateAviGuidance
    let canBeginNewMoment: Bool
    let beginNewMoment: () -> Void
    let planMoment: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.lg) {
            MomentsCreateAviInlineGuide(guidance: guidance)
                .padding(AVBrandSpacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MomentsCreateTuneStyleSurface())

            MomentsCreateNewMomentActionBlock(
                isSignedIn: isSignedIn,
                balance: balance,
                selectedStyle: selectedStyle,
                canBeginNewMoment: canBeginNewMoment,
                beginNewMoment: beginNewMoment,
                planMoment: planMoment,
                startSignInFlow: startSignInFlow,
                openCredits: openCredits
            )
        }
    }
}

private struct MomentsCreateAviInlineGuide: View {
    let guidance: MomentsCreateAviGuidance
    @State private var reactionTrigger = 0

    var body: some View {
        HStack(alignment: .center, spacing: AVBrandSpacing.lg) {
            MomentsCreateAviFullBodyGuideImage(guidance: guidance)
                .avAviActionReaction(guidance.reaction, trigger: reactionTrigger)

            VStack(alignment: .leading, spacing: 5) {
                Text(guidance.eyebrow)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(guidance.accentColor)
                    .textCase(.uppercase)

                Text(guidance.title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(guidance.message)
                    .font(AVBrandTypography.captionStrong)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AVBrandSpacing.xs)
        }
        .onAppear {
            reactionTrigger += 1
        }
        .onChange(of: guidance) { _, _ in
            reactionTrigger += 1
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.string("create.setup.aviSays", guidance.message))
    }
}

private struct MomentsCreateNewMomentActionBlock: View {
    let isSignedIn: Bool
    let balance: MomentsCreditBalance
    let selectedStyle: MomentCreationStyle
    let canBeginNewMoment: Bool
    let beginNewMoment: () -> Void
    let planMoment: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MomentsCreateEconomyPanel(balance: balance, selectedStyle: selectedStyle, isSignedIn: isSignedIn)

            AVAppShellPrimaryButton(
                L10n.string("create.media.choose"),
                systemImage: "photo.badge.plus",
                isDisabled: !canBeginNewMoment,
                action: beginNewMoment
            )

            Button(action: planMoment) {
                Label(L10n.string("create.planFirst"), systemImage: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .black))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!canBeginNewMoment)

            if !isSignedIn {
                AVAppShellInlineMessage(message: L10n.string("create.signInLater.detail"))
            } else if balance.spendable == 0 {
                AVAppShellInlineMessage(message: L10n.string("create.credits.setupNow"))
            }
        }
        .padding(AVBrandSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MomentsCreateTuneStyleSurface())
    }
}

private enum MomentsCreateInitialMediaSource {
    case photos
    case album
}

private struct MomentsCreateMediaSourceSheet: View {
    let selectSource: (MomentsCreateInitialMediaSource) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.string("create.media.source.title"))
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(L10n.string("create.media.source.detail"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 10) {
                    sourceButton(
                        title: L10n.string("create.media.source.photos"),
                        detail: L10n.string("create.media.source.photosDetail"),
                        systemImage: "photo.badge.plus",
                        source: .photos
                    )

                    sourceButton(
                        title: L10n.string("create.media.source.album"),
                        detail: L10n.string("create.media.source.albumDetail"),
                        systemImage: "rectangle.stack.badge.plus",
                        source: .album
                    )
                }

                Spacer(minLength: 0)
            }
            .padding(20)
            .background(MomentsTheme.shellBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.string("common.cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sourceButton(
        title: String,
        detail: String,
        systemImage: String,
        source: MomentsCreateInitialMediaSource
    ) -> some View {
        Button {
            selectSource(source)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(AVBrandColor.accent, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(detail)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AVBrandColor.textSecondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AVBrandColor.elevatedSurface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AVBrandColor.borderSubtle.opacity(0.7), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct MomentsCreateTuneStyleSurface: View {
    var body: some View {
        RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
            .fill(AVBrandColor.elevatedSurface)
    }
}

private struct MomentsCreateAviFullBodyGuideImage: View {
    let guidance: MomentsCreateAviGuidance

    var body: some View {
        Image("AviFullBody")
            .resizable()
            .scaledToFit()
            .frame(width: 64, height: 64)
            .padding(6)
            .background(
                Circle()
                    .fill(guidance.avatarBackgroundColor)
            )
            .accessibilityHidden(true)
    }
}

private extension MomentsCreateAviGuidance {
    var eyebrow: String {
        switch emotion {
        case .warning:
            return L10n.string("create.guidance.eyebrow.warning")
        case .happy, .celebrate:
            return L10n.string("moment.nextAction.createVideo.title")
        case .focused:
            return L10n.string("create.guidance.eyebrow.keepGoing")
        case .curious:
            return L10n.string("paywall.signIn.title")
        case .thinking:
            return L10n.string("create.guidance.eyebrow.prepare")
        }
    }

    var title: String {
        switch emotion {
        case .warning:
            return L10n.string("create.setup.guidance.checkStep")
        case .happy, .celebrate:
            return L10n.string("create.setup.guidance.readyStart")
        case .focused:
            return L10n.string("create.setup.guidance.momentMoving")
        case .curious:
            return L10n.string("create.setup.guidance.signIn")
        case .thinking:
            return L10n.string("create.setup.guidance.preparing")
        }
    }

    var accentColor: Color {
        switch emotion {
        case .warning:
            return Color(red: 0.74, green: 0.48, blue: 0.04)
        case .happy, .celebrate, .focused, .curious, .thinking:
            return AVBrandColor.accent
        }
    }

    var avatarBackgroundColor: Color {
        switch emotion {
        case .warning:
            return Color(red: 1.0, green: 0.96, blue: 0.88)
        case .happy, .celebrate:
            return AVBrandColor.accent.opacity(0.14)
        case .curious, .focused, .thinking:
            return AVBrandColor.accent.opacity(0.10)
        }
    }

}

private struct MomentsCreateEconomyPanel: View {
    @State private var showsDetails = false
    let balance: MomentsCreditBalance
    let selectedStyle: MomentCreationStyle
    let isSignedIn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSignedIn ? L10n.string("credits.available.title") : L10n.string("profile.summary.account.title"))
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .textCase(.uppercase)

                    Text(isSignedIn ? "\(balance.spendable)" : L10n.string("common.signIn"))
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 4) {
                    Text(L10n.string("moment.artifact.final.title"))
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .textCase(.uppercase)

                    Text(MomentsCreditCopy.countTitle(selectedStyle.creditCost))
                        .font(AVBrandTypography.bodyStrong)
                        .foregroundStyle(AVBrandColor.textPrimary)
                }
            }

            Text(L10n.string("create.credits.onlyFinal"))
                .font(AVBrandTypography.captionStrong)
                .foregroundStyle(AVBrandColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if isSignedIn {
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        showsDetails.toggle()
                    }
                } label: {
                    Label(
                        showsDetails ? L10n.string("create.setup.hideDetails") : L10n.string("create.setup.viewDetails"),
                        systemImage: showsDetails ? "chevron.up" : "chevron.down"
                    )
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(AVBrandColor.textSecondary)
                }
                .buttonStyle(.plain)

                if showsDetails {
                    HStack(spacing: 8) {
                        ForEach(MomentsCreditCopy.detailRows(for: balance)) { row in
                            MomentsCreateCreditChip(title: row.title, value: row.value)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AVBrandColor.neutral100)
        )
    }
}

private struct MomentsCreateCreditChip: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(AVBrandColor.textPrimary)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AVBrandColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.white.opacity(0.72))
        )
    }
}

private struct MomentsCreateStepHeader: View {
    let stepTitle: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AVStatusPill(title: stepTitle, isUppercased: false)
            AVAppShellContentHeader(title: title, detail: detail)
        }
    }
}

private struct MomentsCreateMomentHubHeader: View {
    let guidance: MomentsCreateAviGuidance
    let style: MomentCreationStyle
    let selectedMusicPreset: MomentMusicPreset

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            MomentsCreateAviFullBodyGuideImage(guidance: guidance)
                .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.string("create.setup.nextAddMedia"))
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(AVBrandColor.accent)
                    .textCase(.uppercase)

                Text(guidance.message)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.string("create.setup.styleSummary", style.title, style.durationSeconds, MomentsCreditCopy.countTitle(style.creditCost), selectedMusicPreset.title))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MomentsCreateStyleSummaryRow: View {
    let style: MomentCreationStyle
    let selectedMusicPreset: MomentMusicPreset
    var editStyle: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(style.assetName)
                .resizable()
                .scaledToFill()
                .frame(width: 74, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(style.title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(2)

                Text(style.subtitle)
                    .font(AVBrandTypography.caption)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(2)

                Text(L10n.string("create.setup.compactStyleSummary", style.durationSeconds, MomentsCreditCopy.countTitle(style.creditCost), selectedMusicPreset.title))
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
            }

            Spacer(minLength: 8)

            if let editStyle {
                Button(action: editStyle) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AVBrandColor.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.string("create.setup.editStyle"))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AVBrandColor.neutral100)
        )
    }
}

private struct MomentsCreateStyleGrid: View {
    let styles: [MomentCreationStyle]
    let selectedStyle: MomentCreationStyle
    let isLocked: Bool
    let selectStyle: (MomentCreationStyle) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(styles) { style in
                MomentsCreateStyleTile(
                    style: style,
                    isSelected: selectedStyle.id == style.id,
                    isLocked: isLocked,
                    selectStyle: selectStyle
                )
            }
        }
    }
}

private struct MomentsCreateStyleTile: View {
    let style: MomentCreationStyle
    let isSelected: Bool
    let isLocked: Bool
    let selectStyle: (MomentCreationStyle) -> Void

    var body: some View {
        Button {
            selectStyle(style)
        } label: {
            ZStack(alignment: .bottomLeading) {
                Image(style.assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190)
                    .frame(maxWidth: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [
                        .black.opacity(0.02),
                        .black.opacity(0.68)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(style.title)
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)

                        if !style.isEnabled {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white.opacity(0.82))
                        }
                    }

                    Text(style.subtitle)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? AVBrandColor.accent : .white.opacity(0.18), lineWidth: isSelected ? 2 : 1)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white, AVBrandColor.accent)
                        .padding(10)
                }
            }
            .opacity(style.isEnabled ? 1 : 0.52)
        }
        .buttonStyle(.plain)
        .disabled(isLocked || !style.isEnabled)
        .accessibilityLabel(style.title)
        .accessibilityHint(style.isEnabled ? style.subtitle : L10n.string("create.setup.comingSoon"))
    }
}

private struct MomentsCreateQuickCustomizeSection: View {
    @Binding var form: MomentSetupForm
    let selectedStyle: MomentCreationStyle
    let selectedMusicPreset: MomentMusicPreset
    let selectMusicPreset: (MomentMusicPreset) -> Void
    let isLocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.string("create.optionalDetails"))
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .textCase(.uppercase)

                    Text(L10n.string("create.optionalDetails.summary", selectedStyle.durationSeconds, selectedStyle.creditCost))
                        .font(AVBrandTypography.bodyStrong)
                        .foregroundStyle(AVBrandColor.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                AVStatusPill(title: L10n.string("create.minOne"), isUppercased: false)
            }

            MomentsCreateMultilineFieldRow(
                title: L10n.string("create.noteForAvi"),
                placeholder: L10n.string("create.setup.notePlaceholder"),
                systemImage: "text.bubble.fill",
                text: $form.details,
                isDisabled: isLocked
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.string("create.musicMood"))
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .textCase(.uppercase)

                HStack(spacing: 8) {
                    ForEach(selectedStyle.allowedMusic) { preset in
                        Button {
                            selectMusicPreset(preset)
                        } label: {
                            Text(preset.title)
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(selectedMusicPreset == preset ? AVBrandColor.textInverse : AVBrandColor.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(selectedMusicPreset == preset ? AVBrandColor.ink : AVBrandColor.neutral100)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLocked)
                    }
                }
            }
        }
    }
}
