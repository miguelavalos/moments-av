import AVSettingsFoundation
import PhotosUI
import SwiftUI

struct MomentsCreateMediaCard: View {
    @Binding var pickerItems: [PhotosPickerItem]

    let presentation: MomentsCreateMediaPresentation
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let removeMedia: (MomentsSelectedMedia) -> Void
    let autoPickStrongMoments: () -> Void

    var body: some View {
        AVSettingsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Media")
                    .font(.headline)
                Text("Project \(presentation.activeProjectId)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                PhotosPicker(
                    selection: $pickerItems,
                    maxSelectionCount: presentation.remainingSlots,
                    matching: .any(of: [.images, .videos])
                ) {
                    Label(presentation.pickerTitle, systemImage: "photo.badge.plus")
                }
                .disabled(!presentation.canAddMedia)
                .onChange(of: pickerItems) { _, newItems in
                    importPickerItems(newItems)
                    pickerItems = []
                }

                if let availabilityMessage = presentation.availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                Text(presentation.selectedCountTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(presentation.selectionMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                MomentsCreateNewImportSelection(
                    selectedMedia: presentation.summary.selectedMedia,
                    removeMedia: removeMedia,
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
    }
}

private struct MomentsCreateNewImportSelection: View {
    let selectedMedia: [MomentsSelectedMedia]
    let removeMedia: (MomentsSelectedMedia) -> Void
    let autoPickStrongMoments: () -> Void

    @ViewBuilder
    var body: some View {
        if !selectedMedia.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("New import selection")
                    .font(.subheadline.weight(.semibold))

                ForEach(selectedMedia) { media in
                    MomentsCreateMediaRow(media: media) {
                        removeMedia(media)
                    }
                }

                Button(action: autoPickStrongMoments) {
                    Label("Avi Suggests Order", systemImage: "sparkles")
                }
            }
        }
    }
}

private struct MomentsCreateSyncedMediaSection: View {
    let mediaAssets: [MomentMediaAsset]

    @ViewBuilder
    var body: some View {
        if !mediaAssets.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Synced media")
                    .font(.subheadline.weight(.semibold))

                ForEach(mediaAssets) { media in
                    MomentsCreateSyncedMediaRow(media: media)
                }
            }
        }
    }
}
