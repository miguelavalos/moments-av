import AVAppShellFoundation
import AVBrandFoundation
import PhotosUI
import SwiftUI
import UIKit

struct MomentsCreateMediaCard: View {
    @Binding var pickerItems: [PhotosPickerItem]
    @State private var showsPhotoPicker = false
    @State private var showsMediaManager = false
    @State private var handledOpenPickerRequest = 0

    let openPickerRequest: Int
    let presentation: MomentsCreateMediaPresentation
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let importLatestPhotos: () -> Void
    let removeMedia: (MomentsSelectedMedia) -> Void
    let moveMedia: (MomentsSelectedMedia, MomentsSelectedMedia) -> Void
    let reorderMedia: ([MomentsSelectedMedia]) -> Void
    let autoPickStrongMoments: () -> Void
    let consumeOpenPickerRequest: () -> Void

    var body: some View {
        Button(action: mediaCardAction) {
            AVAppShellCard {
                VStack(alignment: .leading, spacing: selectedCount == 0 ? 16 : 12) {
                    HStack(spacing: 10) {
                        Text("Media")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary)

                        Spacer(minLength: 0)

                        Text(actionTitle)
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(AVBrandColor.accent)
                    }

                    HStack(alignment: .center, spacing: 16) {
                        mediaVisual

                        VStack(alignment: .leading, spacing: 4) {
                            if selectedCount > 0 {
                                Text("\(selectedCount) \(selectedCount == 1 ? "item" : "items") selected")
                                    .font(.system(size: 15, weight: .black))
                                    .foregroundStyle(AVBrandColor.textPrimary)
                                    .lineLimit(1)
                            }

                            Text(summaryText)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AVBrandColor.textSecondary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    if presentation.summary.selectedCount == 0 {
                        Text("Start by adding the photos or clips you already have. Avi will organize the first version.")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AVBrandColor.textSecondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        Label("Choose photos or clips", systemImage: "photo.badge.plus")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(AVBrandColor.accent.opacity(0.08))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(AVBrandColor.accent.opacity(0.24), lineWidth: 1)
                            }
                            .accessibilityHidden(true)
                    } else if let selectedSummaryDetail {
                        Text("Avi will use these moments for the first preview.")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AVBrandColor.textSecondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(selectedSummaryDetail)
                            .font(.caption)
                            .foregroundStyle(AVBrandColor.textSecondary.opacity(0.82))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: cardMinHeight, alignment: .topLeading)
            }
        }
        .buttonStyle(.plain)
        .photosPicker(
            isPresented: $showsPhotoPicker,
            selection: $pickerItems,
            maxSelectionCount: presentation.remainingSlots,
            matching: .any(of: [.images, .videos])
        )
        .onChange(of: pickerItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            importPickerItems(newItems)
            pickerItems = []
        }
        .navigationDestination(isPresented: $showsMediaManager) {
            MomentsCreateMediaManagerSheet(
                selectedMedia: presentation.summary.selectedMedia,
                canAddMedia: presentation.canAddMedia,
                isImporting: presentation.summary.isImporting,
                removeMedia: removeMedia,
                moveMedia: moveMedia,
                reorderMedia: reorderMedia,
                chooseManually: {
                    showsPhotoPicker = true
                },
                importLatestPhotos: importLatestPhotos,
                smartOrder: autoPickStrongMoments
            )
        }
        .onAppear {
            openPickerIfRequested(openPickerRequest)
        }
        .onChange(of: openPickerRequest) { _, newValue in
            openPickerIfRequested(newValue)
        }
    }

    @ViewBuilder
    private var mediaVisual: some View {
        if presentation.summary.selectedMedia.isEmpty {
            ZStack {
                AVBrandColor.accent.opacity(0.08)
                Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(AVBrandColor.accent)
            }
            .frame(width: 92, height: 92)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            MomentsCreateStackedMediaSummary(selectedMedia: presentation.summary.selectedMedia)
        }
    }

    private func openPickerIfRequested(_ request: Int) {
        guard request > handledOpenPickerRequest,
              presentation.canAddMedia,
              presentation.summary.selectedCount == 0 else { return }
        handledOpenPickerRequest = request
        consumeOpenPickerRequest()
        showsPhotoPicker = true
    }

    private var summaryText: String {
        let count = selectedCount
        if count == 0 {
            return "Choose photos, clips, or an album from your library."
        }

        return "Tap to delete, add, or reorder."
    }

    private var actionTitle: String {
        selectedCount == 0 ? "Choose" : "Edit"
    }

    private func mediaCardAction() {
        if selectedCount == 0 {
            showsPhotoPicker = true
        } else {
            showsMediaManager = true
        }
    }

    private var selectedCount: Int {
        presentation.summary.selectedCount
    }

    private var cardMinHeight: CGFloat {
        selectedCount == 0 ? 232 : 184
    }

    private var selectedSummaryDetail: String? {
        guard selectedCount > 0 else { return nil }
        if presentation.summary.isImporting {
            return "Adding media..."
        }
        return "Ready for preview."
    }
}

private struct MomentsCreateStackedMediaSummary: View {
    let selectedMedia: [MomentsSelectedMedia]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                ForEach(Array(selectedMedia.prefix(4).enumerated()), id: \.element.id) { index, media in
                    thumbnail(media)
                        .frame(width: 76, height: 76)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(.white, lineWidth: 2)
                        }
                        .shadow(color: AVBrandColor.ink.opacity(0.10), radius: 6, x: 0, y: 4)
                        .offset(x: CGFloat(index) * 7, y: CGFloat(index) * -5)
                }
            }
            .frame(width: 112, height: 92, alignment: .center)

            Text("\(selectedMedia.count)")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.opacity(0.56), in: Capsule())
        }
    }

    @ViewBuilder
    private func thumbnail(_ media: MomentsSelectedMedia) -> some View {
        if media.kind == "photo", let image = UIImage(data: media.data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                AVBrandColor.neutral100
                Image(systemName: media.kind == "video" ? "video.fill" : "photo.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(MomentsTheme.highlight)
            }
        }
    }
}

private struct MomentsCreateMediaManagerSheet: View {
    let selectedMedia: [MomentsSelectedMedia]
    let canAddMedia: Bool
    let isImporting: Bool
    let removeMedia: (MomentsSelectedMedia) -> Void
    let moveMedia: (MomentsSelectedMedia, MomentsSelectedMedia) -> Void
    let reorderMedia: ([MomentsSelectedMedia]) -> Void
    let chooseManually: () -> Void
    let importLatestPhotos: () -> Void
    let smartOrder: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var workingMedia: [MomentsSelectedMedia] = []
    @State private var isReordering = false
    @State private var orderBeforeAviSuggestion: [MomentsSelectedMedia]?
    @State private var zoomedMedia: MomentsSelectedMedia?

    private let columns = [
        GridItem(.adaptive(minimum: 106, maximum: 106), spacing: 16)
    ]

    var body: some View {
        Group {
            if isReordering {
                reorderList
            } else {
                gridView
            }
        }
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            workingMedia = selectedMedia
        }
        .onChange(of: selectedMedia) { _, newMedia in
            workingMedia = newMedia
        }
    }

    private var gridView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                editHeader

                MomentsCreateEditorAviPanel(
                    selectedCount: workingMedia.count,
                    isReordering: false,
                    canAddMedia: canAddMedia,
                    isImporting: isImporting,
                    addMedia: chooseManually,
                    reorder: startManualReorder,
                    suggestOrder: suggestAviOrder,
                    undoAviOrder: undoAviOrder,
                    hasUndoAviOrder: orderBeforeAviSuggestion != nil
                )

                if workingMedia.isEmpty {
                    MomentsCreateMediaEmptyState(
                        canAddMedia: canAddMedia,
                        isImporting: isImporting,
                        addMedia: chooseManually
                    )
                } else {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                        ForEach(Array(workingMedia.enumerated()), id: \.element.id) { index, media in
                            MomentsCreateManageableMediaTile(
                                media: media,
                                index: index,
                                zoom: {
                                    zoomedMedia = media
                                },
                                remove: {
                                    removeMedia(media)
                                }
                            )
                        }
                    }
                }
            }
            .padding(20)
            .padding(.top, 8)
            .safeAreaPadding(.bottom, 96)
        }
        .scrollBounceBehavior(.basedOnSize)
        .fullScreenCover(item: $zoomedMedia) { media in
            MomentsCreateMediaZoomView(media: media) {
                zoomedMedia = nil
            }
        }
    }

    private var reorderList: some View {
        VStack(spacing: 0) {
            reorderHeader
                .padding(.horizontal, 20)
                .padding(.top, 20)

            List {
                ForEach(Array(workingMedia.enumerated()), id: \.element.id) { index, media in
                    MomentsCreateMediaReorderRow(media: media, index: index)
                }
                .onMove(perform: moveRows)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant(.active))
        }
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .safeAreaPadding(.bottom, 96)
    }

    private var editHeader: some View {
        MomentsCreateEditorPageHeader(
            title: isReordering ? "Reorder media" : "Edit media",
            dismiss: { dismiss() }
        )
    }

    private var reorderHeader: some View {
        HStack(spacing: 12) {
            Spacer(minLength: 44)

            Text("Reorder media")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(AVBrandColor.textPrimary)
                .frame(maxWidth: .infinity)

            Button {
                isReordering = false
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(AVBrandColor.textInverse)
                    .frame(width: 44, height: 44)
                    .background(AVBrandColor.accent, in: Circle())
            }
            .accessibilityLabel("Done reordering")
        }
    }

    private func moveRows(from source: IndexSet, to destination: Int) {
        orderBeforeAviSuggestion = nil
        workingMedia.move(fromOffsets: source, toOffset: destination)
        reorderMedia(workingMedia)
    }

    private func startManualReorder() {
        orderBeforeAviSuggestion = nil
        isReordering = true
    }

    private func suggestAviOrder() {
        orderBeforeAviSuggestion = workingMedia
        smartOrder()
    }

    private func undoAviOrder() {
        guard let previousOrder = orderBeforeAviSuggestion else { return }
        workingMedia = previousOrder
        reorderMedia(previousOrder)
        orderBeforeAviSuggestion = nil
    }
}

private struct MomentsCreateMediaEmptyState: View {
    let canAddMedia: Bool
    let isImporting: Bool
    let addMedia: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AVBrandColor.accent.opacity(0.08))
                        .frame(width: 104, height: 82)
                        .rotationEffect(.degrees(-4))

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .frame(width: 104, height: 82)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(AVBrandColor.borderSubtle.opacity(0.7), lineWidth: 1)
                        }
                        .shadow(color: AVBrandColor.ink.opacity(0.07), radius: 8, x: 0, y: 4)

                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(AVBrandColor.accent)
                }
                .padding(.top, 4)
                .accessibilityHidden(true)

                VStack(spacing: 4) {
                    Text("No media yet")
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text("Choose photos or clips to start this Moment.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button(action: addMedia) {
                    Label("Add media", systemImage: "plus")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 21, style: .continuous)
                                .fill(AVBrandColor.accent.opacity(0.08))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 21, style: .continuous)
                                .stroke(AVBrandColor.accent.opacity(0.24), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .disabled(!canAddMedia || isImporting)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
}

private struct MomentsCreateManageableMediaTile: View {
    let media: MomentsSelectedMedia
    let index: Int
    let zoom: () -> Void
    let remove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: zoom) {
                VStack(spacing: 6) {
                    ZStack(alignment: .bottomLeading) {
                        thumbnail
                    }
                    .frame(width: 96, height: mediaFrame.height)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

                    HStack {
                        Text("\(index + 1)")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(AVBrandColor.textPrimary.opacity(0.72))
                        Spacer(minLength: 0)
                        Image(systemName: media.kind == "video" ? "video.fill" : "photo.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AVBrandColor.textSecondary.opacity(0.55))
                    }
                    .padding(.horizontal, 4)
                }
                .frame(width: 106, height: 116, alignment: .top)
                .padding(.top, 5)
                .padding(.horizontal, 5)
                .padding(.bottom, 7)
                .background(cardBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AVBrandColor.borderSubtle.opacity(0.46), lineWidth: 1)
                }
                .shadow(color: AVBrandColor.ink.opacity(0.08), radius: 5, x: 0, y: 2)
                .rotationEffect(.degrees(rotationDegrees))
                .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(role: .destructive, action: remove) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(.black.opacity(0.62), in: Circle())
            }
            .padding(1)
            .accessibilityLabel("Remove media")
        }
        .accessibilityLabel("\(media.kind.capitalized) \(index + 1)")
    }

    private var mediaAspectRatio: CGFloat {
        media.kind == "video" ? 16.0 / 9.0 : 1.0
    }

    private var mediaFrame: CGSize {
        media.kind == "video"
            ? CGSize(width: 96, height: 54)
            : CGSize(width: 96, height: 86)
    }

    private var cardBackground: Color {
        media.kind == "video" ? AVBrandColor.ink.opacity(0.08) : .white
    }

    private var rotationDegrees: Double {
        [-1.0, 0.6, -0.4, 0.9][index % 4]
    }

    @ViewBuilder
    private var thumbnail: some View {
        if media.kind == "photo", let image = UIImage(data: media.data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: mediaFrame.width, height: mediaFrame.height)
                .clipped()
        } else {
            ZStack {
                AVBrandColor.ink.opacity(0.12)
                Image(systemName: media.kind == "video" ? "video.fill" : "photo.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(MomentsTheme.highlight)
            }
            .frame(width: mediaFrame.width, height: mediaFrame.height)
        }
    }
}

private struct MomentsCreateMediaZoomView: View {
    let media: MomentsSelectedMedia
    let dismiss: () -> Void

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            zoomContent
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(pinchGesture)
                .simultaneousGesture(dragGesture)
                .onTapGesture(count: 2, perform: toggleZoom)

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.18), in: Circle())
                    .contentShape(Circle())
            }
            .padding(.top, 18)
            .padding(.trailing, 18)
            .accessibilityLabel("Close preview")
        }
    }

    @ViewBuilder
    private var zoomContent: some View {
        if media.kind == "photo", let image = UIImage(data: media.data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            VStack(spacing: 12) {
                Image(systemName: media.kind == "video" ? "video.fill" : "photo.fill")
                    .font(.system(size: 44, weight: .semibold))
                Text(media.kind == "video" ? "Video preview" : "Media preview")
                    .font(.system(size: 17, weight: .black))
            }
            .foregroundStyle(.white.opacity(0.82))
        }
    }

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(lastScale * value, 1), 4)
                if scale <= 1.01 {
                    offset = .zero
                    lastOffset = .zero
                }
            }
            .onEnded { _ in
                if scale <= 1.01 {
                    resetZoom()
                } else {
                    lastScale = scale
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                guard scale > 1 else { return }
                lastOffset = offset
            }
    }

    private func toggleZoom() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            if scale > 1 {
                resetZoom()
            } else {
                scale = 2
                lastScale = 2
            }
        }
    }

    private func resetZoom() {
        scale = 1
        lastScale = 1
        offset = .zero
        lastOffset = .zero
    }
}

private struct MomentsCreateEditorAviPanel: View {
    let selectedCount: Int
    let isReordering: Bool
    let canAddMedia: Bool
    let isImporting: Bool
    let addMedia: () -> Void
    let reorder: () -> Void
    let suggestOrder: () -> Void
    let undoAviOrder: () -> Void
    let hasUndoAviOrder: Bool

    var body: some View {
        AVAppShellCard {
            HStack(spacing: 12) {
                Image("AviFullBody")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .padding(4)
                    .background(AVBrandColor.accent.opacity(0.10), in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(panelTitle)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)

                    Text(panelMessage)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AVBrandColor.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Menu {
                    Section("Your edits") {
                        if canAddMedia && !isReordering {
                            Button(action: addMedia) {
                                Label("Add media", systemImage: "photo.badge.plus")
                            }
                            .disabled(isImporting)
                        }

                        Button(action: reorder) {
                            Label(isReordering ? "Finish reorder" : "Reorder manually", systemImage: isReordering ? "checkmark" : "line.3.horizontal")
                        }
                    }

                    if !isReordering {
                        Section("Avi automatic") {
                            if hasUndoAviOrder {
                                Button(action: undoAviOrder) {
                                    Label("Undo Avi order", systemImage: "arrow.uturn.backward")
                                }
                            } else {
                                Button(action: suggestOrder) {
                                Label("Suggest order", systemImage: "sparkles")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(AVBrandColor.textPrimary)
                        .frame(width: 38, height: 38)
                        .background(AVBrandColor.neutral100, in: Circle())
                }
                .accessibilityLabel("Avi media actions")
            }
        }
    }

    private var panelTitle: String {
        if isReordering {
            return "Order the story"
        }
        if selectedCount == 0 {
            return "Start with media"
        }
        return "\(selectedCount) selected"
    }

    private var panelMessage: String {
        if isReordering {
            return "Drag moments into the order Avi should follow."
        }
        if selectedCount == 0 {
            return "Add photos or clips and Avi will build the first version."
        }
        return "Review the media, add more, or let Avi suggest an order."
    }
}

private struct MomentsCreateMediaReorderRow: View {
    let media: MomentsSelectedMedia
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("Moment \(index + 1)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                Text(detailText)
                    .font(.caption)
                    .foregroundStyle(AVBrandColor.textSecondary)
                    .lineLimit(1)
            }
        }
        .listRowBackground(Color.clear)
    }

    private var detailText: String {
        var parts: [String] = []

        if let capturedAt = media.capturedAt {
            parts.append(capturedAt.formatted(date: .abbreviated, time: .shortened))
        } else {
            parts.append("No date")
        }

        parts.append(media.kind == "video" ? "Video" : "Photo")
        parts.append(media.displaySize)

        return parts.joined(separator: " · ")
    }

    @ViewBuilder
    private var thumbnail: some View {
        if media.kind == "photo", let image = UIImage(data: media.data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                AVBrandColor.neutral100
                Image(systemName: media.kind == "video" ? "video.fill" : "photo.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(MomentsTheme.highlight)
            }
        }
    }
}

private struct MomentsCreateSyncedMediaSection: View {
    let mediaAssets: [MomentMediaAsset]

    private let columns = [
        GridItem(.adaptive(minimum: 72), spacing: 8)
    ]

    @ViewBuilder
    var body: some View {
        if !mediaAssets.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                AVAppShellSectionHeader(title: "Added media")

                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(Array(mediaAssets.enumerated()), id: \.element.id) { index, media in
                        MomentsCreateSyncedMediaThumbnailTile(media: media, index: index)
                    }
                }
            }
        }
    }
}

struct MomentsCreateSoftActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? AVBrandColor.textPrimary : AVBrandColor.textSecondary.opacity(0.55))
            .padding(.horizontal, AVBrandSpacing.md)
            .background(background(configuration: configuration), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(
                        isEnabled ? AVBrandColor.accent.opacity(0.22) : AVBrandColor.borderSubtle.opacity(0.45),
                        lineWidth: 1
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }

    private func background(configuration: Configuration) -> Color {
        if !isEnabled {
            return AVBrandColor.mutedSurface.opacity(0.7)
        }

        return configuration.isPressed ? AVBrandColor.accent.opacity(0.14) : AVBrandColor.accent.opacity(0.08)
    }
}

struct MomentsCreateSubtleInlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? AVBrandColor.accent : AVBrandColor.textSecondary.opacity(0.55))
            .padding(.horizontal, AVBrandSpacing.sm)
            .padding(.vertical, 6)
            .background(
                isEnabled ? AVBrandColor.accent.opacity(configuration.isPressed ? 0.14 : 0.08) : AVBrandColor.mutedSurface.opacity(0.7),
                in: Capsule()
            )
    }
}

struct MomentsCreateEditorPageHeader: View {
    let title: String
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: dismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(AVBrandColor.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.92), in: Circle())
                    .shadow(color: AVBrandColor.ink.opacity(0.08), radius: 10, x: 0, y: 4)
            }
            .accessibilityLabel("Back to dashboard")

            Text(title)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(AVBrandColor.textPrimary)
                .frame(maxWidth: .infinity)

            Color.clear
                .frame(width: 44, height: 44)
        }
    }
}

private struct MomentsCreateToolbarPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(AVBrandColor.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(configuration.isPressed ? 0.78 : 0.92), in: Capsule())
            .shadow(color: AVBrandColor.ink.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}
