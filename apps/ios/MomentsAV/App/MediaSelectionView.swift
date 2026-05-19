import PhotosUI
import SwiftUI

struct MediaSelectionView: View {
    let template: MomentTemplate
    let projectId: String

    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var projectStore: MomentsProjectStore
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var selectedMedia: [MomentsSelectedMedia] = []
    @State private var isImporting = false
    @State private var statusMessage: String?
    private var uploadClient: MomentsUploadClient {
        MomentsUploadClient(baseURLString: AppConfig.momentsAPIBaseURL)
    }

    private var selectedCount: Int {
        selectedMedia.filter(\.selected).count
    }

    private var isReady: Bool {
        MomentsMediaRules.canStartPreview(template: template, selectedCount: selectedCount)
    }

    var body: some View {
        Section("Media") {
            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: template.maximumAssets,
                matching: .any(of: [.images, .videos])
            ) {
                Label("Add Photos or Clips", systemImage: "photo.badge.plus")
            }
            .disabled(isImporting)
            .onChange(of: pickerItems) { _, newItems in
                Task { await importPickerItems(newItems) }
            }

            LabeledContent("Selected", value: "\(selectedCount)/\(template.mediaRange)")
            Text(MomentsMediaRules.message(template: template, selectedCount: selectedCount))
                .font(.caption)
                .foregroundStyle(isReady ? MomentsBrand.ColorToken.primaryAccent : .secondary)

            if !selectedMedia.isEmpty {
                ForEach(selectedMedia) { media in
                    MediaAssetRow(media: media) {
                        remove(media)
                    }
                }
                .onMove(perform: move)

                Button {
                    autoPickStrongMoments()
                } label: {
                    Label("Avi Suggests Order", systemImage: "sparkles")
                }
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func importPickerItems(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }

        isImporting = true
        statusMessage = nil

        do {
            var imported: [MomentsSelectedMedia] = []
            for (offset, item) in items.prefix(template.maximumAssets).enumerated() {
                let media = try await uploadClient.loadMedia(
                    from: item,
                    sortOrder: selectedMedia.count + offset
                )
                imported.append(media)
            }

            selectedMedia.append(contentsOf: imported)
            normalizeOrder()
            await prepareUploadAndSave(imported)
        } catch {
            statusMessage = error.localizedDescription
        }

        pickerItems = []
        isImporting = false
    }

    private func prepareUploadAndSave(_ imported: [MomentsSelectedMedia]) async {
        guard let ownerUserId = accountController.user?.id else { return }
        guard uploadClient.isConfigured else {
            statusMessage = "Media upload preparation is not configured for this build."
            return
        }

        var savedCount = 0
        var storageBlocked = false

        for media in imported {
            do {
                let prepared = try await uploadClient.prepareUpload(
                    projectId: projectId,
                    ownerUserId: ownerUserId,
                    media: media
                )

                do {
                    try await uploadClient.upload(media: media, preparedUpload: prepared)
                } catch MomentsUploadError.signedUploadUnavailable {
                    storageBlocked = true
                }

                if await projectStore.saveMediaAsset(
                    ownerUserId: ownerUserId,
                    projectId: projectId,
                    media: media,
                    preparedUpload: prepared
                ) {
                    savedCount += 1
                }
            } catch {
                statusMessage = error.localizedDescription
                return
            }
        }

        statusMessage = storageBlocked
            ? "Saved \(savedCount) media records. Signed storage upload is not enabled for this build."
            : "Saved \(savedCount) media records."
    }

    private func remove(_ media: MomentsSelectedMedia) {
        selectedMedia.removeAll { $0.id == media.id }
        normalizeOrder()
    }

    private func move(from source: IndexSet, to destination: Int) {
        selectedMedia.move(fromOffsets: source, toOffset: destination)
        normalizeOrder()
    }

    private func autoPickStrongMoments() {
        selectedMedia = selectedMedia
            .sorted { left, right in
                if left.kind != right.kind {
                    return left.kind == "video"
                }
                return left.byteSize > right.byteSize
            }
        normalizeOrder()
    }

    private func normalizeOrder() {
        for index in selectedMedia.indices {
            selectedMedia[index].sortOrder = index
        }
    }
}

struct MediaAssetRow: View {
    let media: MomentsSelectedMedia
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: media.kind == "video" ? "video" : "photo")
                .foregroundStyle(MomentsBrand.ColorToken.primaryAccent)
            VStack(alignment: .leading, spacing: 3) {
                Text(media.originalFilename)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text("\(media.kind.capitalized) · \(media.displaySize)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "minus.circle")
            }
        }
    }
}
