import AVAppShellFoundation
import AVBrandFoundation
import AVKit
import SwiftUI

struct MomentsGalleryScreen: View {
    @EnvironmentObject private var viewModel: MomentsGalleryViewModel
    @State private var videoPendingDeletion: MomentsGalleryVideoPresentation?
    @State private var selectedVideo: MomentsGalleryVideoPlayerItem?

    var body: some View {
        AVAppShellScrollableScreenScaffold {
            MomentsTheme.shellBackground
        } content: {
            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.string("gallery.title"))
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                Text(L10n.string("gallery.subtitle"))
                    .font(AVBrandTypography.body)
                    .foregroundStyle(AVBrandColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.videos.isEmpty {
                MomentsGalleryEmptyState()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.videos) { video in
                        MomentsGalleryVideoRow(
                            video: video,
                            openVideo: {
                                selectedVideo = MomentsGalleryVideoPlayerItem(video: video)
                            },
                            deleteVideo: {
                                videoPendingDeletion = video
                            }
                        )
                    }
                }
            }
        }
        .confirmationDialog(
            L10n.string("gallery.delete.title"),
            isPresented: deletionConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(L10n.string("gallery.delete.button"), role: .destructive) {
                confirmDeletion()
            }
            Button(L10n.string("common.cancel"), role: .cancel) {
                videoPendingDeletion = nil
            }
        } message: {
            Text(L10n.string("gallery.delete.message"))
        }
        .sheet(item: $selectedVideo) { item in
            MomentsGalleryVideoPlayerSheet(item: item)
        }
    }

    private var deletionConfirmationPresented: Binding<Bool> {
        Binding(
            get: { videoPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    videoPendingDeletion = nil
                }
            }
        )
    }

    private func confirmDeletion() {
        if let videoPendingDeletion {
            viewModel.deleteVideo(videoPendingDeletion)
        }
        videoPendingDeletion = nil
    }
}

private struct MomentsGalleryEmptyState: View {
    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            Image(systemName: "play.square.stack.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(AVBrandColor.accent)
                .frame(width: 74, height: 74)
                .background(Circle().fill(AVBrandColor.accent.opacity(0.10)))

            VStack(spacing: 6) {
                Text(L10n.string("gallery.empty.title"))
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)

                Text(L10n.string("gallery.empty.detail"))
                    .font(AVBrandTypography.body)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
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

private struct MomentsGalleryVideoRow: View {
    let video: MomentsGalleryVideoPresentation
    let openVideo: () -> Void
    let deleteVideo: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: openVideo) {
                    HStack(alignment: .center, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(AVBrandColor.accent.opacity(0.12))
                                .frame(width: 74, height: 54)

                            Image(systemName: video.isLocalFileAvailable ? "play.fill" : "exclamationmark.triangle.fill")
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(video.isLocalFileAvailable ? AVBrandColor.accent : AVBrandColor.textSecondary)
                        }

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
                }
                .buttonStyle(.plain)
                .disabled(!video.isLocalFileAvailable)

                HStack(spacing: 10) {
                    Button(action: openVideo) {
                        Label(L10n.string("common.open"), systemImage: "play.fill")
                    }
                    .disabled(!video.isLocalFileAvailable)

                    if video.isLocalFileAvailable {
                        ShareLink(item: video.localFileURL) {
                            Label(L10n.string("common.share"), systemImage: "square.and.arrow.up")
                        }
                    }

                    Button(role: .destructive, action: deleteVideo) {
                        Label(video.isLocalFileAvailable ? L10n.string("common.delete") : L10n.string("common.remove"), systemImage: "trash")
                    }
                }
                .font(.system(size: 13, weight: .bold))
                .buttonStyle(.bordered)
            }
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
