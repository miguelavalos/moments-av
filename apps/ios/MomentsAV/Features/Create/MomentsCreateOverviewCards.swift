import AVSettingsFoundation
import SwiftUI

struct MomentsCreateIntroCard: View {
    let isSignedIn: Bool

    var body: some View {
        AVSettingsCard {
            Text("Create")
                .font(.headline)
            Text("Build a private memory video from draft setup through media, story, preview, and final export.")
                .foregroundStyle(.secondary)
            Text(isSignedIn ? "Ready to create projects." : "Login is required before creating projects.")
                .font(.subheadline.weight(.semibold))
        }
    }
}

struct MomentsCreateActiveProjectCard: View {
    let activeProject: MomentDraftProject?

    var body: some View {
        if let activeProject {
            AVSettingsCard {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "rectangle.stack")
                        .font(.title3)
                        .foregroundStyle(MomentsTheme.brandPalette.accent)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(activeProject.title)
                            .font(.headline)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(MomentsProjectFormatting.statusTitle(activeProject))
                            .font(.subheadline.weight(.semibold))
                        Text(MomentsProjectFormatting.updatedAt(activeProject))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }
}

struct MomentsCreateContinuationHintCard: View {
    let focus: MomentsProjectContinuationFocus?
    let dismiss: () -> Void

    var body: some View {
        if let focus {
            AVSettingsCard {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: focus.systemImage)
                        .font(.title3)
                        .foregroundStyle(MomentsTheme.brandPalette.accent)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(focus.title)
                            .font(.headline)
                        Text(focus.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

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
        AVSettingsCard {
            Text("Spendable credits")
                .font(.headline)
            Text("\(balance.spendable)")
                .font(.title2.weight(.semibold))
            Text("Monthly: \(balance.proMonthly) · Promo: \(balance.promotional) · Purchased: \(balance.purchased)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
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
