import AVAppShellFoundation
import AVBrandFoundation
import SwiftUI

struct MomentsCreateStoryCard: View {
    let presentation: MomentsCreateStoryPresentation
    let generateStoryPlan: () -> Void
    let buyReviewBundle: () -> Void
    let openCredits: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 14) {
                AVAppShellContentHeader(
                    title: L10n.string("create.story.plan.title"),
                    detail: L10n.string("create.story.plan.detail")
                )

                MomentsCreateStoryScenesSection(presentation: presentation)

                MomentsCreateStoryReviewAllowancePanel(
                    presentation: presentation,
                    buyReviewBundle: buyReviewBundle,
                    openCredits: openCredits
                )

                AVAppShellPrimaryButton(
                    presentation.planButtonTitle,
                    systemImage: "text.bubble.fill",
                    isDisabled: !presentation.canPlanStory || presentation.summary.isPlanning || presentation.isBuyingReviewBundle,
                    action: generateStoryPlan
                )

                if let availabilityMessage = presentation.availabilityMessage {
                    AVAppShellInlineMessage(message: availabilityMessage)
                }

                if let storyStatusMessage = presentation.summary.statusMessage {
                    Text(storyStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct MomentsCreateStoryReviewAllowancePanel: View {
    let presentation: MomentsCreateStoryPresentation
    let buyReviewBundle: () -> Void
    let openCredits: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                MomentsCreateStoryAllowanceMetric(
                    title: "\(presentation.balance.reviewAllowanceRemaining)",
                    subtitle: L10n.string("create.story.reviewsLeft"),
                    systemImage: "list.bullet.clipboard.fill"
                )
                MomentsCreateStoryAllowanceMetric(
                    title: "\(presentation.balance.reviewBundleReviewCount)",
                    subtitle: L10n.string("create.story.perBundle"),
                    systemImage: "plus.circle.fill"
                )
                MomentsCreateStoryAllowanceMetric(
                    title: MomentsCreditCopy.countTitle(presentation.balance.reviewBundleCreditCost),
                    subtitle: L10n.string("create.story.bundleCost"),
                    systemImage: "creditcard.fill"
                )
            }

            if presentation.balance.reviewAllowanceRemaining == 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.string("create.story.reviewsUsedUp"))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if presentation.balance.canBuyReviewBundle {
                        Button(action: buyReviewBundle) {
                            Label(presentation.reviewBundleButtonTitle, systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MomentsCreateNeutralInlineButtonStyle())
                        .disabled(!presentation.canBuyReviewBundle)
                    } else {
                        Button(action: openCredits) {
                            Label(L10n.string("credits.get.title"), systemImage: "creditcard.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(MomentsCreateNeutralInlineButtonStyle())
                    }
                }
            }
        }
        .padding(12)
        .background(AVBrandColor.neutral100.opacity(0.70), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct MomentsCreateStoryAllowanceMetric: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(AVBrandColor.accent)
                .frame(width: 28, height: 28)
                .background(AVBrandColor.accent.opacity(0.10), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(subtitle)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MomentsCreateStoryScenesSection: View {
    let presentation: MomentsCreateStoryPresentation

    var body: some View {
        if !presentation.savedScenes.isEmpty {
            ForEach(presentation.savedScenes) { scene in
                MomentsCreateStorySceneRow(
                    index: Int(scene.sceneIndex),
                    caption: scene.caption,
                    narration: scene.narrationText ?? ""
                )
            }
        } else if !presentation.summary.generatedScenes.isEmpty {
            ForEach(presentation.summary.generatedScenes) { scene in
                MomentsCreateStorySceneRow(
                    index: scene.sceneIndex,
                    caption: scene.caption,
                    narration: scene.narrationText
                )
            }
        } else {
            MomentsCreateEmptySectionRow(
                systemImage: "text.bubble",
                message: presentation.emptyMessage
            )
        }
    }
}
