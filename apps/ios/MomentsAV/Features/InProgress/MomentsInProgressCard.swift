import AVAppShellFoundation
import AVBrandFoundation
import AVKit
import SwiftUI

struct MomentsInProgressCard: View {
    let presentation: MomentsInProgressPresentation
    let balance: MomentsCreditBalance
    let momentsSummary: InProgressMomentsSummary
    let selectedMomentId: String?
    let isLoadingMomentWorkspace: Bool
    let activeWorkspace: MomentWorkspace?
    let isDeletingMoment: Bool
    let statusMessage: String?
    let selectProject: (InProgressMoment) -> Void
    let continueMoment: (MomentsContinuationRequest) -> Void
    let startMoment: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void
    let requestDeleteMoment: (InProgressMoment) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MomentsInProgressAviBlock(momentsSummary: momentsSummary)

            switch presentation.availability {
            case let .signedOut(unavailable):
                MomentsInProgressSignedOutState(
                    unavailable: unavailable,
                    startSignInFlow: startSignInFlow
                )
            case let .empty(unavailable):
                MomentsInProgressCreditStatus(balance: balance, openCredits: openCredits)
                MomentsInProgressEmptyContent(
                    unavailable: unavailable,
                    startMoment: startMoment
                )
            case .available:
                MomentsInProgressCreditStatus(balance: balance, openCredits: openCredits)
                MomentsInProgressContinueBlock(
                    moments: continueMoments,
                    continueMoment: continueMoment,
                    requestDeleteMoment: requestDeleteMoment
                )
                MomentsInProgressStatusMessage(message: statusMessage)
            }
        }
    }

    private var continueMoments: [InProgressMoment] {
        momentsSummary.groups.inProgress.sorted { $0.updatedAt > $1.updatedAt }
    }
}

private struct MomentsInProgressCreditStatus: View {
    let balance: MomentsCreditBalance
    let openCredits: () -> Void

    var body: some View {
        AVAppShellCard {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: balance.spendable > 0 ? "creditcard.fill" : "exclamationmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(balance.spendable > 0 ? AVBrandColor.accent : AVBrandColor.textSecondary)
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.string("credits.available.detail", MomentsCreditCopy.countTitle(balance.spendable)))
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(balance.spendable > 0 ? L10n.string("inProgress.credits.ready") : L10n.string("inProgress.credits.needed"))
                        .font(AVBrandTypography.captionStrong)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: 8)

                Button(action: openCredits) {
                    Label(balance.spendable > 0 ? L10n.string("common.manage") : L10n.string("common.get"), systemImage: "plus.circle.fill")
                        .font(.system(size: 13, weight: .black))
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private struct MomentsInProgressSignedOutState: View {
    let unavailable: MomentsInProgressUnavailablePresentation
    let startSignInFlow: () -> Void

    var body: some View {
        MomentsInProgressInlineEmptyState(
            systemImage: unavailable.systemImage,
            title: unavailable.title,
            message: unavailable.message,
            actionTitle: L10n.string("common.signIn"),
            actionSystemImage: "person.crop.circle.fill",
            action: startSignInFlow
        )
    }
}

private struct MomentsInProgressEmptyContent: View {
    let unavailable: MomentsInProgressUnavailablePresentation
    let startMoment: () -> Void

    var body: some View {
        MomentsInProgressInlineEmptyState(
            systemImage: "photo.badge.plus",
            title: L10n.string("inProgress.empty.inProgress.title"),
            message: L10n.string("inProgress.empty.inProgress.detail"),
            actionTitle: L10n.string("inProgress.newMoment"),
            actionSystemImage: "plus",
            action: startMoment
        )
    }
}

private struct MomentsInProgressAviBlock: View {
    let momentsSummary: InProgressMomentsSummary

    var body: some View {
        HStack(spacing: 16) {
            Image("AviFullBody")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .padding(6)
                .background(Circle().fill(AVBrandColor.accent.opacity(0.10)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .lineLimit(2)

                Text(message)
                    .font(AVBrandTypography.captionStrong)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
                .fill(AVBrandColor.elevatedSurface)
        )
    }

    private var title: String {
        if momentsSummary.latestInProgressMoment != nil {
            return L10n.string("inProgress.avi.momentInProgress.title")
        }
        if momentsSummary.finishedCount > 0 {
            return L10n.string("inProgress.avi.galleryStarts.title")
        }
        return L10n.string("inProgress.avi.ready.title")
    }

    private var message: String {
        if let moment = momentsSummary.latestInProgressMoment {
            return L10n.string("inProgress.avi.momentInProgress.message", moment.title)
        }
        if momentsSummary.finishedCount > 0 {
            return L10n.string("inProgress.avi.galleryStarts.message")
        }
        return L10n.string("inProgress.avi.ready.message")
    }
}

private struct MomentsInProgressContinueBlock: View {
    let moments: [InProgressMoment]
    let continueMoment: (MomentsContinuationRequest) -> Void
    let requestDeleteMoment: (InProgressMoment) -> Void

    var body: some View {
        if moments.isEmpty {
            MomentsInProgressInlineEmptyState(
                systemImage: "photo.badge.plus",
                title: L10n.string("inProgress.empty.inProgress.title"),
                message: L10n.string("inProgress.empty.inProgress.fullDetail"),
                actionTitle: nil,
                actionSystemImage: nil,
                action: nil
            )
        } else {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: 12) {
                    AVAppShellSectionHeader(title: L10n.string("inProgress.title"))

                    ForEach(moments) { moment in
                        VStack(spacing: 10) {
                            Button {
                                continueMoment(MomentsContinuationRequest(moment: moment))
                            } label: {
                                HStack(alignment: .center, spacing: 12) {
                                    Image(systemName: iconName(for: moment))
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(AVBrandColor.accent)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(moment.title)
                                            .font(.system(size: 17, weight: .black))
                                            .foregroundStyle(AVBrandColor.textPrimary)
                                            .lineLimit(2)

                                        Text("\(MomentStatusRules.displayTitle(for: moment.status)) · \(Self.creditTitle(moment.creditCost))")
                                            .font(AVBrandTypography.captionStrong)
                                            .foregroundStyle(AVBrandColor.textSecondary)
                                    }

                                    Spacer(minLength: 0)

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .black))
                                        .foregroundStyle(AVBrandColor.textSecondary)
                                }
                            }
                            .buttonStyle(.plain)

                            Button(role: .destructive) {
                                requestDeleteMoment(moment)
                            } label: {
                                Label(L10n.string("common.discard"), systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        if moment.id != moments.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private func iconName(for moment: InProgressMoment) -> String {
        switch moment.status {
        case "final_render_pending", "final_render_running":
            "gearshape.2.fill"
        case "export_ready", "completed":
            "arrow.down.circle.fill"
        case "preview_ready":
            "text.bubble.fill"
        default:
            "sparkles.rectangle.stack.fill"
        }
    }

    private static func creditTitle(_ creditCost: Double) -> String {
        let count = Int(creditCost.rounded())
        return MomentsCreditCopy.countTitle(count)
    }
}

private struct MomentsInProgressInlineEmptyState: View {
    let systemImage: String
    let title: String
    let message: String
    let actionTitle: String?
    let actionSystemImage: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(AVBrandColor.accent.opacity(0.10))
                    .frame(width: 70, height: 70)
                Image(systemName: systemImage)
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(AVBrandColor.accent)
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(AVBrandTypography.captionStrong)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Label(actionTitle, systemImage: actionSystemImage ?? "plus")
                        .font(.system(size: 15, weight: .black))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AVBrandColor.textInverse)
                .background(
                    Capsule(style: .continuous)
                        .fill(AVBrandColor.accent)
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
                .fill(AVBrandColor.elevatedSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AVBrandRadius.card, style: .continuous)
                .stroke(AVBrandColor.borderSubtle.opacity(0.55), lineWidth: 1)
        )
    }
}

private struct MomentsInProgressGalleryEmptyState: View {
    var body: some View {
        MomentsInProgressInlineEmptyState(
            systemImage: "play.square.stack.fill",
            title: L10n.string("gallery.empty.shortTitle"),
            message: L10n.string("gallery.empty.downloadDetail"),
            actionTitle: nil,
            actionSystemImage: nil,
            action: nil
        )
    }
}

private struct MomentsInProgressDraftEmptyState: View {
    let startMoment: (() -> Void)?

    var body: some View {
        MomentsInProgressInlineEmptyState(
            systemImage: "photo.badge.plus",
            title: L10n.string("inProgress.empty.inProgress.title"),
            message: L10n.string("inProgress.empty.inProgress.detail"),
            actionTitle: startMoment == nil ? nil : L10n.string("inProgress.newMoment"),
            actionSystemImage: "plus",
            action: startMoment
        )
    }
}
