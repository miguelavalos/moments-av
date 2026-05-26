import AVAppShellFoundation
import PhotosUI
import SwiftUI

struct MomentsCreateMediaCard: View {
    @Binding var pickerItems: [PhotosPickerItem]
    @State private var detailMedia: MomentsSelectedMedia?
    @State private var showsAddMediaSheet = false
    @State private var handledOpenPickerRequest = 0

    let openPickerRequest: Int
    let presentation: MomentsCreateMediaPresentation
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let removeMedia: (MomentsSelectedMedia) -> Void
    let autoPickStrongMoments: () -> Void

    var body: some View {
        AVAppShellCard {
            VStack(alignment: .leading, spacing: 14) {
                AVAppShellContentHeader(
                    title: "Add photos or clips",
                    detail: "Pick the moments for this video."
                )

                Button {
                    showsAddMediaSheet = true
                } label: {
                    Label(presentation.pickerTitle, systemImage: "photo.badge.plus")
                        .font(.system(size: 16, weight: .black))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                }
                .disabled(!presentation.canAddMedia)
                .buttonStyle(.borderedProminent)

                if let availabilityMessage = presentation.availabilityMessage {
                    AVAppShellInlineMessage(message: availabilityMessage)
                }

                Text(presentation.selectionMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                MomentsCreateNewImportSelection(
                    selectedMedia: presentation.summary.selectedMedia,
                    openDetails: { detailMedia = $0 },
                    autoPickStrongMoments: autoPickStrongMoments
                )
                MomentsCreateSyncedMediaSection(mediaAssets: presentation.syncedMediaAssets)

                if let mediaStatusMessage = presentation.summary.statusMessage {
                    Text(mediaStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(item: $detailMedia) { media in
            MomentsCreateMediaDetailSheet(media: media) {
                removeMedia(media)
                detailMedia = nil
            }
        }
        .sheet(isPresented: $showsAddMediaSheet) {
            MomentsCreateAddMediaSheet(
                pickerItems: $pickerItems,
                presentation: presentation,
                importPickerItems: importPickerItems,
                dismiss: { showsAddMediaSheet = false }
            )
        }
        .onAppear {
            openPickerIfRequested(openPickerRequest)
        }
        .onChange(of: openPickerRequest) { _, newValue in
            openPickerIfRequested(newValue)
        }
    }

    private func openPickerIfRequested(_ request: Int) {
        guard request > handledOpenPickerRequest, presentation.canAddMedia else { return }
        handledOpenPickerRequest = request
        showsAddMediaSheet = true
    }
}

private struct MomentsCreateAddMediaSheet: View {
    @Binding var pickerItems: [PhotosPickerItem]
    let presentation: MomentsCreateMediaPresentation
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            AVAppShellContentHeader(
                title: "Add media",
                detail: "Choose photos or clips. They stay local until you create a preview."
            )

            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: presentation.remainingSlots,
                matching: .any(of: [.images, .videos])
            ) {
                Label(presentation.pickerTitle, systemImage: "photo.badge.plus")
                    .font(.system(size: 16, weight: .black))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .onChange(of: pickerItems) { _, newItems in
                importPickerItems(newItems)
                pickerItems = []
                dismiss()
            }

            Button("Cancel", action: dismiss)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .padding(20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

private struct MomentsCreateNewImportSelection: View {
    let selectedMedia: [MomentsSelectedMedia]
    let openDetails: (MomentsSelectedMedia) -> Void
    let autoPickStrongMoments: () -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 72), spacing: 8)
    ]

    @ViewBuilder
    var body: some View {
        if !selectedMedia.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                AVAppShellSectionHeader(title: "Selected media")

                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(Array(selectedMedia.enumerated()), id: \.element.id) { index, media in
                        MomentsCreateMediaThumbnailTile(media: media, index: index) {
                            openDetails(media)
                        }
                    }
                }

                Button(action: autoPickStrongMoments) {
                    Label("Avi suggests order", systemImage: "sparkles")
                }
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
