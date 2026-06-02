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
                    Text(L10n.string("credits.available.detail", MomentsCreditCopy.countTitle(balance.spendable)))
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(balance.spendable > 0 ? L10n.string("projects.credits.ready") : L10n.string("projects.credits.needed"))
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

private struct MomentsHubSignedOutState: View {
    let unavailable: MomentsProjectsUnavailablePresentation
    let startSignInFlow: () -> Void

    var body: some View {
        MomentsHubEmptyState(
            systemImage: unavailable.systemImage,
            title: unavailable.title,
            message: unavailable.message,
            actionTitle: L10n.string("common.signIn"),
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
                title: L10n.string("gallery.empty.shortTitle"),
                message: L10n.string("gallery.empty.downloadDetail"),
                actionTitle: nil,
                actionSystemImage: nil,
                action: nil
            )
        case .inProgress:
            MomentsHubEmptyState(
                systemImage: "photo.badge.plus",
                title: L10n.string("projects.empty.inProgress.title"),
                message: L10n.string("projects.empty.inProgress.detail"),
                actionTitle: L10n.string("projects.newMoment"),
                actionSystemImage: "plus",
                action: startProject
            )
        }
    }
}

enum MomentsHubMode: String, CaseIterable, Identifiable {
    case inProgress
    case gallery

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inProgress:
            return L10n.string("projects.mode.inProgress")
        case .gallery:
            return L10n.string("projects.mode.gallery")
        }
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
            return L10n.string("projects.avi.momentInProgress.title")
        }
        if projectSummary.finishedCount > 0 {
            return L10n.string("projects.avi.galleryStarts.title")
        }
        return L10n.string("projects.avi.ready.title")
    }

    private var message: String {
        if let project = projectSummary.latestInProgressProject {
            return L10n.string("projects.avi.momentInProgress.message", project.title)
        }
        if projectSummary.finishedCount > 0 {
            return L10n.string("projects.avi.galleryStarts.message")
        }
        return L10n.string("projects.avi.ready.message")
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
                title: L10n.string("projects.empty.inProgress.title"),
                message: L10n.string("projects.empty.inProgress.fullDetail"),
                actionTitle: nil,
                actionSystemImage: nil,
                action: nil
            )
        } else {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: 12) {
                    AVAppShellSectionHeader(title: L10n.string("projects.inProgress.title"))

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
                                Label(L10n.string("common.discard"), systemImage: "trash")
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
            return L10n.string("project.status.videoReadyDownloadNeeded")
        }
        return MomentsProjectStatusRules.displayTitle(for: project.status)
    }

    private static func creditTitle(_ creditCost: Double) -> String {
        let count = Int(creditCost.rounded())
        return MomentsCreditCopy.countTitle(count)
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
            title: L10n.string("gallery.empty.shortTitle"),
            message: L10n.string("gallery.empty.downloadDetail"),
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
            title: L10n.string("projects.empty.inProgress.title"),
            message: L10n.string("projects.empty.inProgress.detail"),
            actionTitle: startProject == nil ? nil : L10n.string("projects.newMoment"),
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
            AVAppShellSectionHeader(title: L10n.string("gallery.title"))
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
                                        Label(L10n.string("common.open"), systemImage: "play.fill")
                                    }
                                    .disabled(!video.isLocalFileAvailable)

                                    if video.isLocalFileAvailable {
                                        ShareLink(item: video.localFileURL) {
                                            Label(L10n.string("common.share"), systemImage: "square.and.arrow.up")
                                        }
                                    }

                                    Button(role: .destructive) {
                                        requestDeleteGalleryVideo(video)
                                    } label: {
                                        Label(L10n.string("common.delete"), systemImage: "trash")
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
                        Button(L10n.string("common.done")) {
                            dismiss()
                        }
                    }
                }
        }
    }
}
