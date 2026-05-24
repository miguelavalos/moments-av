import AVSettingsFoundation
import PhotosUI
import SwiftUI

struct MomentsCreateMediaCard: View {
    @Binding var pickerItems: [PhotosPickerItem]

    let createdProjectId: String
    let template: MomentTemplate
    let summary: MomentsCreateMediaSummary
    let canAddMedia: Bool
    let availabilityMessage: String?
    let importPickerItems: ([PhotosPickerItem]) -> Void
    let removeMedia: (MomentsSelectedMedia) -> Void
    let autoPickStrongMoments: () -> Void

    private var remainingSlots: Int {
        summary.remainingSlots(template: template)
    }

    var body: some View {
        AVSettingsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Media")
                    .font(.headline)
                Text("Project \(createdProjectId)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                PhotosPicker(
                    selection: $pickerItems,
                    maxSelectionCount: remainingSlots,
                    matching: .any(of: [.images, .videos])
                ) {
                    Label(summary.isImporting ? "Importing media..." : "Add Photos or Clips", systemImage: "photo.badge.plus")
                }
                .disabled(!canAddMedia)
                .onChange(of: pickerItems) { _, newItems in
                    importPickerItems(newItems)
                    pickerItems = []
                }

                if let availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                Text("Selected \(summary.selectedCount)/\(template.mediaRange)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(mediaSelectionMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                newImportSelection
                syncedMedia

                if let mediaStatusMessage = summary.statusMessage {
                    Text(mediaStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var mediaSelectionMessage: String {
        MomentsMediaRules.selectionMessage(
            MomentsMediaRules.availability(template: template, selectedCount: summary.selectedCount),
            tooFewMessage: { "Add \($0) more synced media assets." },
            tooManyMessage: { "Remove \($0) synced media assets." }
        )
    }

    @ViewBuilder
    private var newImportSelection: some View {
        if !summary.selectedMedia.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("New import selection")
                    .font(.subheadline.weight(.semibold))

                ForEach(summary.selectedMedia) { media in
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
        if !summary.syncedMediaAssets.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Synced media")
                    .font(.subheadline.weight(.semibold))

                ForEach(summary.syncedMediaAssets.sorted { $0.sortOrder < $1.sortOrder }) { media in
                    MomentsCreateSyncedMediaRow(media: media)
                }
            }
        }
    }
}

struct MomentsCreateStoryCard: View {
    let summary: MomentsCreateStorySummary
    let canDraftStory: Bool
    let availabilityMessage: String?
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
                    Text(summary.isDrafting ? "Drafting story..." : "Ask Avi for story draft")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canDraftStory || summary.isDrafting)

                if let availabilityMessage {
                    MomentsCreateAvailabilityMessage(message: availabilityMessage)
                }

                if let storyStatusMessage = summary.statusMessage {
                    Text(storyStatusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var storyScenes: some View {
        if !summary.savedScenes.isEmpty {
            ForEach(summary.savedScenes.sorted { $0.sceneIndex < $1.sceneIndex }) { scene in
                MomentsCreateStorySceneRow(
                    index: Int(scene.sceneIndex),
                    caption: scene.caption,
                    narration: scene.narrationText ?? ""
                )
            }
        } else if !summary.generatedScenes.isEmpty {
            ForEach(summary.generatedScenes) { scene in
                MomentsCreateStorySceneRow(
                    index: scene.sceneIndex,
                    caption: scene.caption,
                    narration: scene.narrationText
                )
            }
        } else {
            MomentsCreateEmptySectionRow(
                systemImage: "text.bubble",
                message: canDraftStory
                    ? "Avi can draft the first story from the synced media."
                    : "Add enough synced media before generating a story draft."
            )
        }
    }
}
