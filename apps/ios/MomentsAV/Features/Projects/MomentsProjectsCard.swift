import AVAppShellFoundation
import AVBrandFoundation
import SwiftUI

struct MomentsProjectsCard: View {
    @State private var selectedMode: MomentsHubMode = .draft

    let presentation: MomentsProjectsPresentation
    let projectSummary: MomentsProjectListSummary
    let selectedProjectId: String?
    let isLoadingProjectWorkspace: Bool
    let activeWorkspace: MomentProjectWorkspace?
    let isDeletingProject: Bool
    let statusMessage: String?
    let selectProject: (MomentDraftProject) -> Void
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let startProject: () -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MomentsHubAviBlock(projectSummary: projectSummary)
            MomentsHubModePicker(selectedMode: $selectedMode)

            switch presentation.availability {
            case let .signedOut(unavailable):
                AVAppShellCard {
                    MomentsProjectsUnavailableState(presentation: unavailable)
                }
            case let .empty(unavailable):
                MomentsHubEmptyContent(
                    selectedMode: selectedMode,
                    unavailable: unavailable
                )
            case .available:
                switch selectedMode {
                case .projects:
                    MomentsHubFinishedBlock(
                        projects: projectSummary.groups.finished,
                        selectProject: selectProject
                    )
                case .draft:
                    MomentsHubDraftBlock(
                        project: projectSummary.latestInProgressProject,
                        continueProject: continueProject,
                        requestDeleteProject: requestDeleteProject
                    )
                }
                MomentsProjectsStatusMessage(message: statusMessage)
            }
        }
    }
}

private struct MomentsHubEmptyContent: View {
    let selectedMode: MomentsHubMode
    let unavailable: MomentsProjectsUnavailablePresentation

    var body: some View {
        switch selectedMode {
        case .projects:
            MomentsHubEmptyState(
                systemImage: "play.rectangle.fill",
                title: "No finished videos",
                message: "Finished videos will appear here. Start with a new moment when you are ready.",
                actionTitle: nil,
                actionSystemImage: nil,
                action: nil
            )
        case .draft:
            MomentsHubEmptyState(
                systemImage: "photo.badge.plus",
                title: "No draft in progress",
                message: "Start a new moment. It stays local until you prepare the story.",
                actionTitle: nil,
                actionSystemImage: nil,
                action: nil
            )
        }
    }
}

private enum MomentsHubMode: String, CaseIterable, Identifiable {
    case projects = "Projects"
    case draft = "Draft"

    var id: String { rawValue }
}

private struct MomentsHubModePicker: View {
    @Binding var selectedMode: MomentsHubMode

    var body: some View {
        Picker("Moments view", selection: $selectedMode) {
            ForEach(MomentsHubMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct MomentsHubAviBlock: View {
    let projectSummary: MomentsProjectListSummary

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
        if projectSummary.latestInProgressProject != nil {
            return "Your draft is waiting"
        }
        return "Ready to make a memory"
    }

    private var message: String {
        if let project = projectSummary.latestInProgressProject {
            return "\(project.title) has a starting point ready."
        }
        return "Start a new moment and choose the media you want to use."
    }
}

private struct MomentsHubDraftBlock: View {
    let project: MomentDraftProject?
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        if let project {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: 12) {
                    AVAppShellSectionHeader(title: "Current draft")

                    Button {
                        continueProject(MomentsProjectContinuationRequest(project: project))
                    } label: {
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: "sparkles.rectangle.stack.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(AVBrandColor.accent)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 5) {
                                Text(project.title)
                                    .font(.system(size: 17, weight: .black))
                                    .foregroundStyle(AVBrandColor.textPrimary)
                                    .lineLimit(2)

                                Text("\(MomentsProjectStatusRules.displayTitle(for: project.status)) · \(Self.creditTitle(project.creditCost))")
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
                        requestDeleteProject(project)
                    } label: {
                        Label("Discard", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        } else {
            MomentsHubEmptyState(
                systemImage: "photo.badge.plus",
                title: "No draft in progress",
                message: "Start a new moment. It stays local until you prepare the story.",
                actionTitle: nil,
                actionSystemImage: nil,
                action: nil
            )
        }
    }

    private static func creditTitle(_ creditCost: Double) -> String {
        let count = Int(creditCost.rounded())
        return "\(count) \(count == 1 ? "credit" : "credits")"
    }
}

private struct MomentsHubEmptyState: View {
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

private struct MomentsHubProjectsEmptyState: View {
    var body: some View {
        MomentsHubEmptyState(
            systemImage: "play.rectangle.fill",
            title: "No finished videos",
            message: "Finished videos will appear here. Start with a new moment when you are ready.",
            actionTitle: nil,
            actionSystemImage: nil,
            action: nil
        )
    }
}

private struct MomentsHubDraftEmptyState: View {
    let startProject: (() -> Void)?

    var body: some View {
        MomentsHubEmptyState(
            systemImage: "photo.badge.plus",
            title: "No draft in progress",
            message: "Start a new moment. It stays local until you prepare the story.",
            actionTitle: startProject == nil ? nil : "New Moment",
            actionSystemImage: "plus",
            action: startProject
        )
    }
}

private struct MomentsHubFinishedBlock: View {
    let projects: [MomentDraftProject]
    let selectProject: (MomentDraftProject) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AVAppShellSectionHeader(title: "Finished memories")

            if projects.isEmpty {
                MomentsHubProjectsEmptyState()
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 140), spacing: 12)],
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(projects) { project in
                        Button {
                            selectProject(project)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "play.rectangle.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(AVBrandColor.accent)

                                Text(project.title)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(AVBrandColor.textPrimary)
                                    .lineLimit(2)

                                Text("Final video")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AVBrandColor.textSecondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(AVBrandColor.elevatedSurface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
