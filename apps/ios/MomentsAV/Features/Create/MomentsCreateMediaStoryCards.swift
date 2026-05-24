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
                Text("Project \(presentation.createdProjectId)")
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

                newImportSelection
                syncedMedia

                if let mediaStatusMessage = presentation.summary.statusMessage {
                    Text(mediaStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var newImportSelection: some View {
        if !presentation.summary.selectedMedia.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("New import selection")
                    .font(.subheadline.weight(.semibold))

                ForEach(presentation.summary.selectedMedia) { media in
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

    @ViewBuilder
    private var syncedMedia: some View {
        if !presentation.syncedMediaAssets.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Synced media")
                    .font(.subheadline.weight(.semibold))

                ForEach(presentation.syncedMediaAssets) { media in
                    MomentsCreateSyncedMediaRow(media: media)
                }
            }
        }
    }
}

struct MomentsCreateStoryCard: View {
    let presentation: MomentsCreateStoryPresentation
    let generateStoryDraft: () -> Void

    var body: some View {
        AVSettingsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Story")
                    .font(.headline)
                Text("Generate the first Avi story draft from the media already attached to the project.")
                    .foregroundStyle(.secondary)

                storyScenes

                Button(action: generateStoryDraft) {
                    Text(presentation.draftButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!presentation.canDraftStory || presentation.summary.isDrafting)

                if let availabilityMessage = presentation.availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                if let storyStatusMessage = presentation.summary.statusMessage {
                    Text(storyStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var storyScenes: some View {
        if !presentation.savedScenes.isEmpty {
            ForEach(presentation.savedScenes) { scene in
                MomentsCreateStorySceneRow(
                    index: Int(scene.sceneIndex),
                    caption: scene.caption,
                    narration: scene.narrationText ?? ""
                )
            }
        } else if !presentation.summary.generatedScenes.isEmpty {
            ForEach(presentation.summary.generatedScenes) { scene in
                MomentsCreateStorySceneRow(
                    index: scene.sceneIndex,
                    caption: scene.caption,
                    narration: scene.narrationText
                )
            }
        } else {
            MomentsCreateEmptySectionRow(
                systemImage: "text.bubble",
                message: presentation.emptyMessage
            )
        }
    }
}
