import AVAppShellFoundation
import AVBrandFoundation
import SwiftUI

struct MomentsCreateIntroCard: View {
    let isSignedIn: Bool

    var body: some View {
        AVAppShellCard {
            AVAppShellContentHeader(
                title: "Create",
                detail: "Build a private memory video from draft setup through media, story, preview, and final export."
            )
            AVStatusPill(title: isSignedIn ? "Ready" : "Login required", isUppercased: false)
        }
    }
}

struct MomentsCreateActiveProjectCard: View {
    let activeProject: MomentDraftProject?

    var body: some View {
        if let activeProject {
            AVAppShellCard {
                AVAppShellInfoRow(
                    title: activeProject.title,
                    detail: MomentsProjectFormatting.updatedAt(activeProject),
                    systemImage: "rectangle.stack",
                    eyebrow: MomentsProjectFormatting.statusTitle(activeProject)
                )
            }
        }
    }
}

struct MomentsCreateContinuationHintCard: View {
    let focus: MomentsProjectContinuationFocus?
    let dismiss: () -> Void

    var body: some View {
        if let focus {
            AVAppShellCard {
                AVAppShellInfoRow(
                    title: focus.title,
                    detail: focus.message,
                    systemImage: focus.systemImage
                ) {
                    Button(action: dismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Dismiss continuation hint")
                }
            }
        }
    }
}

struct MomentsCreateCreditsCard: View {
    let balance: MomentsCreditBalance

    var body: some View {
        AVAppShellCard {
            AVAppShellContentHeader(
                title: "Spendable credits",
                detail: "Credits available for previews and final exports."
            )
            AVAppShellInfoRow(
                title: "\(balance.spendable) credits",
                detail: "Monthly: \(balance.proMonthly) · Promo: \(balance.promotional) · Purchased: \(balance.purchased)",
                systemImage: "creditcard"
            )
        }
    }
}

struct MomentsCurrentCreationCard: View {
    let selectedCount: Int
    let continueCreation: () -> Void

    var body: some View {
        Button(action: continueCreation) {
            AVAppShellCard {
                HStack(spacing: 12) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AVBrandColor.accent)
                        .frame(width: 38, height: 38)
                        .background(AVBrandColor.accent.opacity(0.10), in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Continue current Moment")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary)
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(AVBrandColor.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AVBrandColor.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var detail: String {
        selectedCount == 0
            ? "Local creation. Add media before preview."
            : "Local creation · \(selectedCount) \(selectedCount == 1 ? "item" : "items") selected."
    }
}

private extension MomentsProjectContinuationFocus {
    var title: String {
        switch self {
        case .review:
            "Review project"
        case .media:
            "Continue with media"
        case .story:
            "Continue with story"
        case .preview:
            "Continue with preview"
        case .finalRender:
            "Continue with final export"
        }
    }

    var message: String {
        switch self {
        case .review:
            "Check the active project details before continuing the workflow."
        case .media:
            "Add photos or clips for this project, then continue to story generation."
        case .story:
            "Generate the story scenes from the selected media."
        case .preview:
            "Generate or refresh the preview before spending credits on the final export."
        case .finalRender:
            "Render or refresh the final export for the finished video."
        }
    }

    var systemImage: String {
        switch self {
        case .review:
            "rectangle.stack"
        case .media:
            "photo.badge.plus"
        case .story:
            "text.bubble"
        case .preview:
            "play.rectangle"
        case .finalRender:
            "square.and.arrow.up"
        }
    }
}
