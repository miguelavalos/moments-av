import AVAppShellFoundation
import AVBrandFoundation
import AVKit
import SwiftUI

struct MomentsProjectsCard: View {
    let mode: MomentsHubMode
    let presentation: MomentsProjectsPresentation
    let balance: MomentsCreditBalance
    let projectSummary: MomentsProjectListSummary
    let selectedProjectId: String?
    let isLoadingProjectWorkspace: Bool
    let activeWorkspace: MomentProjectWorkspace?
    let isDeletingProject: Bool
    let statusMessage: String?
    let galleryVideos: [MomentsGalleryVideoPresentation]
    let selectProject: (MomentDraftProject) -> Void
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let startProject: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void
    let requestDeleteGalleryVideo: (MomentsGalleryVideoPresentation) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            MomentsHubAviBlock(projectSummary: projectSummary)

            switch presentation.availability {
            case let .signedOut(unavailable):
                MomentsHubSignedOutState(
                    unavailable: unavailable,
                    startSignInFlow: startSignInFlow
                )
            case let .empty(unavailable):
                MomentsHubCreditStatus(balance: balance, openCredits: openCredits)
                MomentsHubEmptyContent(
                    mode: mode,
                    unavailable: unavailable,
                    startProject: startProject
                )
            case .available:
                MomentsHubCreditStatus(balance: balance, openCredits: openCredits)
                switch mode {
                case .gallery:
                    MomentsHubGalleryBlock(
                        videos: galleryVideos,
                        requestDeleteGalleryVideo: requestDeleteGalleryVideo
                    )
                case .inProgress:
                    MomentsHubContinueBlock(
                        projects: continueProjects,
                        galleryVideos: galleryVideos,
                        continueProject: continueProject,
                        requestDeleteProject: requestDeleteProject
                    )
                }
                MomentsProjectsStatusMessage(message: statusMessage)
            }
        }
    }

    private var continueProjects: [MomentDraftProject] {
        let galleryProjectIds = Set(galleryVideos.map(\.record.projectId))
        return (projectSummary.groups.inProgress + projectSummary.groups.finished.filter { project in
            !galleryProjectIds.contains(project.id)
        })
        .sorted { $0.updatedAt > $1.updatedAt }
    }
}

private struct MomentsHubCreditStatus: View {
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
                    Text("\(MomentsCreditCopy.countTitle(balance.spendable)) available")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(balance.spendable > 0 ? "Credits are ready for final video creation." : "Credits are needed before final video creation.")
                        .font(AVBrandTypography.captionStrong)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: 8)

                Button(action: openCredits) {
                    Label(balance.spendable > 0 ? "Manage" : "Get", systemImage: "plus.circle.fill")
                        .font(.system(size: 13, weight: .black))
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private struct MomentsHubSignedOutState: View {
    let unavailable: MomentsProjectsUnavailablePresentation
    let startSignInFlow: () -> Void

    var body: some View {
        MomentsHubEmptyState(
            systemImage: unavailable.systemImage,
            title: unavailable.title,
            message: unavailable.message,
            actionTitle: "Sign in",
            actionSystemImage: "person.crop.circle.fill",
            action: startSignInFlow
        )
    }
}

private struct MomentsHubEmptyContent: View {
    let mode: MomentsHubMode
    let unavailable: MomentsProjectsUnavailablePresentation
    let startProject: () -> Void

    var body: some View {
        switch mode {
        case .gallery:
            MomentsHubEmptyState(
                systemImage: "play.square.stack.fill",
                title: "Gallery is empty",
                message: "Finished videos appear here only after they download to this device.",
                actionTitle: nil,
                actionSystemImage: nil,
                action: nil
            )
        case .inProgress:
            MomentsHubEmptyState(
                systemImage: "photo.badge.plus",
                title: "Nothing in progress",
                message: "Drafts and videos that need action will appear here.",
                actionTitle: "New Moment",
                actionSystemImage: "plus",
                action: startProject
            )
        }
    }
}

enum MomentsHubMode: String, CaseIterable, Identifiable {
    case inProgress = "In Progress"
    case gallery = "Gallery"

    var id: String { rawValue }
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
            return "Moment in progress"
        }
        if projectSummary.finishedCount > 0 {
            return "Gallery starts on this device"
        }
        return "Ready to make a memory"
    }

    private var message: String {
        if let project = projectSummary.latestInProgressProject {
            return "\(project.title) needs the next story, render, or download step."
        }
        if projectSummary.finishedCount > 0 {
            return "Remote finished Moments stay out of Gallery until their final video is downloaded locally."
        }
        return "Start a new moment and choose the media you want to use."
    }
}

private struct MomentsHubContinueBlock: View {
    let projects: [MomentDraftProject]
    let galleryVideos: [MomentsGalleryVideoPresentation]
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        if projects.isEmpty {
            MomentsHubEmptyState(
                systemImage: "photo.badge.plus",
                title: "Nothing in progress",
                message: "Drafts, story reviews, renders, and videos waiting for download will appear here.",
                actionTitle: nil,
                actionSystemImage: nil,
                action: nil
            )
        } else {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: 12) {
                    AVAppShellSectionHeader(title: "In Progress")

                    ForEach(projects) { project in
                        VStack(spacing: 10) {
                            Button {
                                continueProject(MomentsProjectContinuationRequest(project: project))
                            } label: {
                                HStack(alignment: .center, spacing: 12) {
                                    Image(systemName: iconName(for: project))
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(AVBrandColor.accent)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(project.title)
                                            .font(.system(size: 17, weight: .black))
                                            .foregroundStyle(AVBrandColor.textPrimary)
                                            .lineLimit(2)

                                        Text("\(Self.statusTitle(for: project, galleryVideos: galleryVideos)) · \(Self.creditTitle(project.creditCost))")
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
                        if project.id != projects.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private func iconName(for project: MomentDraftProject) -> String {
        switch project.status {
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

    private static func statusTitle(
        for project: MomentDraftProject,
        galleryVideos: [MomentsGalleryVideoPresentation]
    ) -> String {
        if MomentsProjectStatusRules.isFinished(project),
           !galleryVideos.contains(where: { $0.record.projectId == project.id }) {
            return "Video Ready - Download Needed"
        }
        return MomentsProjectStatusRules.displayTitle(for: project.status)
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
            systemImage: "play.square.stack.fill",
            title: "Gallery is empty",
            message: "Finished videos appear here only after they download to this device.",
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
            title: "Nothing in progress",
            message: "Drafts and videos that need action will appear here.",
            actionTitle: startProject == nil ? nil : "New Moment",
            actionSystemImage: "plus",
            action: startProject
        )
    }
}

private struct MomentsHubGalleryBlock: View {
    let videos: [MomentsGalleryVideoPresentation]
    let requestDeleteGalleryVideo: (MomentsGalleryVideoPresentation) -> Void
    @State private var selectedVideo: MomentsGalleryVideoPlayerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AVAppShellSectionHeader(title: "Gallery")
            if videos.isEmpty {
                MomentsHubProjectsEmptyState()
            } else {
                AVAppShellCard {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(videos) { video in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .center, spacing: 12) {
                                    Image(systemName: video.isLocalFileAvailable ? "play.square.fill" : "exclamationmark.triangle.fill")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(video.isLocalFileAvailable ? AVBrandColor.accent : AVBrandColor.textSecondary)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(video.title)
                                            .font(.system(size: 17, weight: .black))
                                            .foregroundStyle(AVBrandColor.textPrimary)
                                            .lineLimit(2)

                                        Text(video.availabilityTitle)
                                            .font(AVBrandTypography.captionStrong)
                                            .foregroundStyle(AVBrandColor.textSecondary)
                                    }

                                    Spacer(minLength: 0)
                                }

                                HStack(spacing: 10) {
                                    Button {
                                        selectedVideo = MomentsGalleryVideoPlayerItem(video: video)
                                    } label: {
                                        Label("Open", systemImage: "play.fill")
                                    }
                                    .disabled(!video.isLocalFileAvailable)

                                    if video.isLocalFileAvailable {
                                        ShareLink(item: video.localFileURL) {
                                            Label("Share", systemImage: "square.and.arrow.up")
                                        }
                                    }

                                    Button(role: .destructive) {
                                        requestDeleteGalleryVideo(video)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .font(.system(size: 13, weight: .bold))
                                .buttonStyle(.bordered)
                            }
                            if video.id != videos.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedVideo) { item in
            MomentsGalleryVideoPlayerSheet(item: item)
        }
    }
}

private struct MomentsGalleryVideoPlayerItem: Identifiable {
    let id: String
    let title: String
    let url: URL

    init(video: MomentsGalleryVideoPresentation) {
        id = video.id
        title = video.title
        url = video.localFileURL
    }
}

private struct MomentsGalleryVideoPlayerSheet: View {
    let item: MomentsGalleryVideoPlayerItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VideoPlayer(player: AVPlayer(url: item.url))
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(item.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
