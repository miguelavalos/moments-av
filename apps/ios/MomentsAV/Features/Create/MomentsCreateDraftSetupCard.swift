import AVAviFoundation
import AVAppShellFoundation
import AVBrandFoundation
import SwiftUI

struct MomentsCreateDraftSetupCard: View {
    @Binding var form: MomentDraftForm
    let selectedStyle: MomentCreationStyle
    let styles: [MomentCreationStyle]
    let selectedMusicPreset: MomentMusicPreset
    let presentation: MomentsCreateDraftSetupPresentation
    let newProjectStep: MomentsCreateNewProjectStep
    let isSignedIn: Bool
    let balance: MomentsCreditBalance
    let canBeginNewProject: Bool
    let beginNewProject: () -> Void
    let editStyle: () -> Void
    let selectStyle: (MomentCreationStyle) -> Void
    let selectMusicPreset: (MomentMusicPreset) -> Void
    let createDraft: () -> Void
    let startAnotherProject: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void

    @ViewBuilder
    var body: some View {
        if !presentation.isDraftLocked, newProjectStep == .status {
            VStack(alignment: .leading, spacing: AVBrandSpacing.lg) {
                MomentsCreateNewProjectStatus(
                    isSignedIn: isSignedIn,
                    balance: balance,
                    selectedStyle: selectedStyle,
                    guidance: aviGuidance,
                    canBeginNewProject: canBeginNewProject,
                    beginNewProject: beginNewProject,
                    startSignInFlow: startSignInFlow,
                    openCredits: openCredits
                )

                activeDraftAndErrorContent
            }
        } else {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: 16) {
                    if presentation.isDraftLocked {
                        lockedProjectContent
                    } else {
                        switch newProjectStep {
                        case .status:
                            EmptyView()
                        case .style:
                            styleStep
                        case .summary:
                            summaryStep
                        }
                    }

                    activeDraftAndErrorContent
                }
            }
        }
    }

    private var aviGuidance: MomentsCreateAviGuidance {
        MomentsCreateAviGuidanceResolver.make(
            isSignedIn: isSignedIn,
            balance: balance,
            selectedStyle: selectedStyle,
            step: newProjectStep,
            isDraftLocked: presentation.isDraftLocked,
            draftErrorMessage: presentation.draftErrorMessage
        )
    }

    private var lockedProjectContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            AVAppShellContentHeader(
                title: "Project in progress",
                detail: aviGuidance.message
            )

            MomentsCreateStyleSummaryRow(style: selectedStyle, selectedMusicPreset: selectedMusicPreset)
        }
    }

    private var activeDraftAndErrorContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            MomentsCreateActiveDraftSection(
                presentation: presentation,
                minimumMediaCount: form.template.minimumAssets,
                startAnotherProject: startAnotherProject
            )

            if let draftErrorMessage = presentation.draftErrorMessage {
                Text(draftErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var styleStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            MomentsCreateStepHeader(
                stepTitle: "Step 1 of 2",
                title: "Choose a style",
                detail: aviGuidance.message
            )

            MomentsCreateStyleGrid(
                styles: styles,
                selectedStyle: selectedStyle,
                isLocked: presentation.isDraftLocked,
                selectStyle: selectStyle
            )
        }
    }

    private var summaryStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            MomentsCreateStepHeader(
                stepTitle: "Step 2 of 2",
                title: "Review and create",
                detail: aviGuidance.message
            )

            MomentsCreateStyleSummaryRow(
                style: selectedStyle,
                selectedMusicPreset: selectedMusicPreset,
                editStyle: editStyle
            )

            MomentsCreateQuickCustomizeSection(
                form: $form,
                selectedStyle: selectedStyle,
                selectedMusicPreset: selectedMusicPreset,
                selectMusicPreset: selectMusicPreset,
                isLocked: presentation.isDraftLocked
            )

            AVAppShellPrimaryButton(
                presentation.createDraftTitle,
                systemImage: "photo.badge.plus",
                isDisabled: !presentation.canCreateDraft || presentation.isCreatingDraft,
                action: createDraft
            )

            if let availabilityMessage = presentation.availabilityMessage {
                AVAppShellInlineMessage(message: availabilityMessage)
            }
        }
    }
}

private struct MomentsCreateNewProjectStatus: View {
    let isSignedIn: Bool
    let balance: MomentsCreditBalance
    let selectedStyle: MomentCreationStyle
    let guidance: MomentsCreateAviGuidance
    let canBeginNewProject: Bool
    let beginNewProject: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AVBrandSpacing.lg) {
            MomentsCreateAviInlineGuide(guidance: guidance)
                .padding(AVBrandSpacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MomentsCreateTuneStyleSurface())

            MomentsCreateNewProjectActionBlock(
                isSignedIn: isSignedIn,
                balance: balance,
                selectedStyle: selectedStyle,
                canBeginNewProject: canBeginNewProject,
                beginNewProject: beginNewProject,
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
        .accessibilityLabel("Avi says \(guidance.message)")
    }
}

private struct MomentsCreateNewProjectActionBlock: View {
    let isSignedIn: Bool
    let balance: MomentsCreditBalance
    let selectedStyle: MomentCreationStyle
    let canBeginNewProject: Bool
    let beginNewProject: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MomentsCreateEconomyPanel(balance: balance, selectedStyle: selectedStyle, isSignedIn: isSignedIn)

            if isSignedIn {
                if balance.spendable > 0 {
                    AVAppShellPrimaryButton(
                        "Start new project",
                        systemImage: "plus.app.fill",
                        isDisabled: !canBeginNewProject,
                        action: beginNewProject
                    )
                } else {
                    AVAppShellPrimaryButton(
                        "Get credits",
                        systemImage: "creditcard.fill",
                        isDisabled: false,
                        action: openCredits
                    )
                    AVAppShellInlineMessage(message: "Choose Pro, buy credits, or claim a promotion to start this video.")
                }
            } else {
                AVAppShellPrimaryButton(
                    "Sign in to continue",
                    systemImage: "person.crop.circle.badge.checkmark",
                    isDisabled: false,
                    action: startSignInFlow
                )
            }
        }
        .padding(AVBrandSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MomentsCreateTuneStyleSurface())
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
            return "Get credits"
        case .happy, .celebrate:
            return "Start new project"
        case .focused:
            return "Review project"
        case .curious:
            return "Sign in first"
        case .thinking:
            return "Prepare project"
        }
    }

    var title: String {
        switch emotion {
        case .warning:
            return "You need 1 credit"
        case .happy, .celebrate:
            return "Ready to start"
        case .focused:
            return "Project is moving"
        case .curious:
            return "Sign in to create"
        case .thinking:
            return "Preparing your project"
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
    let balance: MomentsCreditBalance
    let selectedStyle: MomentCreationStyle
    let isSignedIn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSignedIn ? "Available credits" : "Account status")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .textCase(.uppercase)

                    Text(isSignedIn ? "\(balance.spendable)" : "Sign in")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Project cost")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .textCase(.uppercase)

                    Text("\(selectedStyle.creditCost) credit")
                        .font(AVBrandTypography.bodyStrong)
                        .foregroundStyle(AVBrandColor.textPrimary)
                }
            }

            HStack(spacing: 8) {
                MomentsCreateCreditChip(title: "Monthly", value: balance.proMonthly)
                MomentsCreateCreditChip(title: "Promo", value: balance.promotional)
                MomentsCreateCreditChip(title: "Purchased", value: balance.purchased)
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

                Text("\(style.durationSeconds)s · \(style.creditCost) credit · \(selectedMusicPreset.title)")
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
                .accessibilityLabel("Edit style")
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
        .accessibilityHint(style.isEnabled ? style.subtitle : "Coming soon")
    }
}

private struct MomentsCreateQuickCustomizeSection: View {
    @Binding var form: MomentDraftForm
    let selectedStyle: MomentCreationStyle
    let selectedMusicPreset: MomentMusicPreset
    let selectMusicPreset: (MomentMusicPreset) -> Void
    let isLocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ready fast")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .textCase(.uppercase)

                    Text("\(selectedStyle.durationSeconds)s · \(selectedStyle.creditCost) credit · 3-12 photos recommended")
                        .font(AVBrandTypography.bodyStrong)
                        .foregroundStyle(AVBrandColor.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                AVStatusPill(title: "Min 1", isUppercased: false)
            }

            MomentsCreateMultilineFieldRow(
                title: "Añade una nota",
                placeholder: "Cumple de Ana, viaje a Lisboa, para mamá...",
                systemImage: "text.bubble.fill",
                text: $form.details,
                isDisabled: isLocked
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Music mood")
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
