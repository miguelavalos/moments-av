import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class MediaUploadWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var selectedMedia: [MomentsSelectedMedia] = []
    @Published private(set) var isImporting = false
    @Published private(set) var statusMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let mediaAssetSaver: any MomentsMediaAssetSaving
    private let uploadClient: MomentsUploadClient
    private var resetGeneration = 0

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        mediaAssetSaver: any MomentsMediaAssetSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        uploadClient: MomentsUploadClient
    ) {
        self.currentUserProvider = currentUserProvider
        self.mediaAssetSaver = mediaAssetSaver
        self.uploadClient = uploadClient
        super.init(workspaceObserver: workspaceObserver)
    }

    var isConfigured: Bool {
        mediaAssetSaver.isConfigured && uploadClient.isConfigured
    }

    func importPickerItems(
        _ items: [PhotosPickerItem],
        template: MomentTemplate,
        projectId: String
    ) async {
        guard !items.isEmpty else { return }
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = "Sign in before adding media."
            return
        }
        guard isConfigured else {
            statusMessage = "Media upload is not configured for this build."
            return
        }
        let remainingSlots = MomentsMediaRules.remainingSlots(
            template: template,
            selectedCount: selectedMediaCount
        )
        guard remainingSlots > 0 else {
            statusMessage = "Remove media before adding more to this template."
            return
        }

        let generation = resetGeneration
        isImporting = true
        statusMessage = nil

        do {
            let imported = try await MediaPickerImport.load(
                items: items,
                limit: remainingSlots,
                startingSortOrder: selectedMedia.count,
                uploadClient: uploadClient
            )

            guard isCurrent(generation) else { return }
            selectedMedia.append(contentsOf: imported)
            normalizeOrder()

            let persistenceResult = try await MediaUploadPersistence.save(
                imported: imported,
                ownerUserId: ownerUserId,
                projectId: projectId,
                uploadClient: uploadClient,
                mediaAssetSaver: mediaAssetSaver,
                shouldContinue: { isCurrent(generation) }
            )

            workspaceObserver.observeWorkspace(ownerUserId: ownerUserId, projectId: projectId)
            statusMessage = persistenceResult.statusMessage
        } catch {
            guard isCurrent(generation) else { return }
            statusMessage = error.localizedDescription
        }

        guard isCurrent(generation) else { return }
        isImporting = false
    }

    func remove(_ media: MomentsSelectedMedia) {
        selectedMedia.removeAll { $0.id == media.id }
        normalizeOrder()
    }

    func autoPickStrongMoments() {
        selectedMedia = selectedMedia.sorted { left, right in
            if left.kind != right.kind {
                return left.kind == "video"
            }
            return left.byteSize > right.byteSize
        }
        normalizeOrder()
    }

    func reset(force: Bool = false) {
        guard force || !isImporting else { return }
        resetGeneration += 1
        isImporting = false
        selectedMedia = []
        statusMessage = nil
        clearActiveWorkspace()
    }

    private func normalizeOrder() {
        for index in selectedMedia.indices {
            selectedMedia[index].sortOrder = index
        }
    }

    private var selectedMediaCount: Int {
        MomentsMediaRules.selectedCount(
            localMedia: selectedMedia,
            syncedMedia: activeWorkspace?.mediaAssets ?? []
        )
    }

    private func isCurrent(_ generation: Int) -> Bool {
        generation == resetGeneration
    }
}
