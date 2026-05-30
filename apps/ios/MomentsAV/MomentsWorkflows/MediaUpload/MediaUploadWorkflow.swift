import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class MediaUploadWorkflow: WorkspaceObservingWorkflow {
    @Published private(set) var selectedMedia: [MomentsSelectedMedia] = []
    @Published private(set) var isImporting = false
    @Published private(set) var importProgress: MomentsMediaImportProgress?
    @Published private(set) var statusMessage: String?

    private let currentUserProvider: any MomentsCurrentUserProviding
    private let authTokenProvider: any MomentsAuthTokenProviding
    private let mediaAssetSaver: any MomentsMediaAssetSaving
    private let uploadClient: MomentsUploadClient
    private var restoredWorkspaceProjectId: String?

    init(
        currentUserProvider: any MomentsCurrentUserProviding,
        authTokenProvider: any MomentsAuthTokenProviding,
        mediaAssetSaver: any MomentsMediaAssetSaving,
        workspaceObserver: any MomentsActiveWorkspaceObserving,
        uploadClient: MomentsUploadClient
    ) {
        self.currentUserProvider = currentUserProvider
        self.authTokenProvider = authTokenProvider
        self.mediaAssetSaver = mediaAssetSaver
        self.uploadClient = uploadClient
        super.init(workspaceObserver: workspaceObserver)
    }

    var isConfigured: Bool {
        true
    }

    func importPickerItems(
        _ items: [PhotosPickerItem],
        template: MomentTemplate,
        projectId: String?
    ) async {
        guard !items.isEmpty else { return }
        guard currentUserProvider.currentUserId != nil else {
            statusMessage = "Sign in before adding media."
            return
        }
        let remainingSlots = MomentsMediaRules.remainingSlots(
            template: template,
            selectedCount: selectedMediaCount
        )
        guard remainingSlots > 0 else {
            statusMessage = "Avi has enough media for this video."
            return
        }

        let generation = beginWorkflowGeneration()
        beginImport(totalCount: min(items.count, remainingSlots))

        do {
            let imported = try await MediaPickerImport.load(
                items: items,
                limit: remainingSlots,
                startingSortOrder: selectedMedia.count,
                progress: { [weak self] completedCount, totalCount in
                    self?.updateImportProgress(completedCount: completedCount, totalCount: totalCount)
                }
            )

            guard isCurrentWorkflowGeneration(generation) else { return }
            let uniqueImported = MomentsMediaDeduplicator.uniqueNewMedia(
                existing: selectedMedia,
                imported: imported
            )
            selectedMedia.append(contentsOf: uniqueImported)
            sortChronologically()
            statusMessage = importStatusMessage(
                importedCount: uniqueImported.count,
                skippedDuplicateCount: imported.count - uniqueImported.count,
                emptyMessage: "No new media added."
            )
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = MomentsRecoveryCopy.mediaImportFailure()
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        endImport()
    }

    func importLatestPhotos(
        template: MomentTemplate,
        projectId: String?
    ) async {
        let remainingSlots = MomentsMediaRules.remainingSlots(
            template: template,
            selectedCount: selectedMediaCount
        )
        guard remainingSlots > 0 else {
            statusMessage = "Avi has enough media for this video."
            return
        }

        let generation = beginWorkflowGeneration()
        beginImport(totalCount: remainingSlots)

        do {
            let imported = try await MediaPickerImport.loadLatestPhotos(
                limit: remainingSlots,
                startingSortOrder: selectedMedia.count,
                progress: { [weak self] completedCount, totalCount in
                    self?.updateImportProgress(completedCount: completedCount, totalCount: totalCount)
                }
            )

            guard isCurrentWorkflowGeneration(generation) else { return }
            let uniqueImported = MomentsMediaDeduplicator.uniqueNewMedia(
                existing: selectedMedia,
                imported: imported
            )
            selectedMedia.append(contentsOf: uniqueImported)
            sortChronologically()
            statusMessage = importStatusMessage(
                importedCount: uniqueImported.count,
                skippedDuplicateCount: imported.count - uniqueImported.count,
                emptyMessage: "No recent photos found."
            )
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = MomentsRecoveryCopy.mediaImportFailure()
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        endImport()
    }

    func importPhotoAlbum(
        id albumId: String,
        template: MomentTemplate,
        projectId: String?
    ) async {
        guard currentUserProvider.currentUserId != nil else {
            statusMessage = "Sign in before adding media."
            return
        }
        let remainingSlots = MomentsMediaRules.remainingSlots(
            template: template,
            selectedCount: selectedMediaCount
        )
        guard remainingSlots > 0 else {
            statusMessage = "Avi has enough media for this video."
            return
        }

        let generation = beginWorkflowGeneration()
        beginImport(totalCount: remainingSlots)

        do {
            let imported = try await MediaPickerImport.loadPhotoAlbum(
                id: albumId,
                limit: remainingSlots,
                startingSortOrder: selectedMedia.count,
                progress: { [weak self] completedCount, totalCount in
                    self?.updateImportProgress(completedCount: completedCount, totalCount: totalCount)
                }
            )

            guard isCurrentWorkflowGeneration(generation) else { return }
            let uniqueImported = MomentsMediaDeduplicator.uniqueNewMedia(
                existing: selectedMedia,
                imported: imported
            )
            selectedMedia.append(contentsOf: uniqueImported)
            sortChronologically()
            statusMessage = importStatusMessage(
                importedCount: uniqueImported.count,
                skippedDuplicateCount: imported.count - uniqueImported.count,
                emptyMessage: "No photos found in that album."
            )
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = MomentsRecoveryCopy.mediaImportFailure()
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        endImport()
    }

    func remove(_ media: MomentsSelectedMedia) {
        selectedMedia.removeAll { $0.id == media.id }
        normalizeOrder()
    }

    func move(_ media: MomentsSelectedMedia, before target: MomentsSelectedMedia) {
        guard media.id != target.id,
              let sourceIndex = selectedMedia.firstIndex(where: { $0.id == media.id }),
              let targetIndex = selectedMedia.firstIndex(where: { $0.id == target.id }) else { return }

        let movedMedia = selectedMedia.remove(at: sourceIndex)
        let adjustedTargetIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        selectedMedia.insert(movedMedia, at: adjustedTargetIndex)
        normalizeOrder()
    }

    func reorder(_ media: [MomentsSelectedMedia]) {
        let mediaById = Dictionary(uniqueKeysWithValues: selectedMedia.map { ($0.id, $0) })
        selectedMedia = media.compactMap { mediaById[$0.id] }
        normalizeOrder()
    }

    func autoPickStrongMoments() {
        sortChronologically()
    }

    override func workspaceDidChange(_ workspace: MomentProjectWorkspace?) {
        guard selectedMedia.isEmpty,
              let workspace,
              restoredWorkspaceProjectId != workspace.project.id,
              !workspace.mediaAssets.isEmpty else { return }

        Task { [weak self] in
            await self?.restoreLocalMedia(from: workspace)
        }
    }

    func restoreLocalMediaForEditing() {
        guard selectedMedia.isEmpty,
              let activeWorkspace,
              restoredWorkspaceProjectId != activeWorkspace.project.id,
              !activeWorkspace.mediaAssets.isEmpty else { return }

        Task { [weak self, activeWorkspace] in
            await self?.restoreLocalMedia(from: activeWorkspace)
        }
    }

    func persistSelectedMedia(projectId: String) async -> [MomentsStoryDraftMedia]? {
        guard let ownerUserId = currentUserProvider.currentUserId else {
            statusMessage = "Sign in before preparing the story."
            return nil
        }
        guard let bearerToken = try? await authTokenProvider.currentBearerToken() else {
            statusMessage = "Sign in again before preparing the story."
            return nil
        }
        let mediaToSave = selectedMedia
            .filter(\.selected)
            .sorted { $0.sortOrder < $1.sortOrder }
        if mediaToSave.isEmpty {
            return activeWorkspaceStoryMedia
        }
        let syncedMediaBySourceIdentifier = (activeWorkspace?.mediaAssets ?? []).reduce(into: [String: MomentMediaAsset]()) {
            guard let sourceIdentifier = $1.platformMediaAssetId else { return }
            $0[sourceIdentifier] = $1
        }
        let alreadySyncedMedia = mediaToSave.compactMap { media -> MomentsStoryDraftMedia? in
            guard let synced = syncedMediaBySourceIdentifier[media.sourceLocalIdentifier] else { return nil }
            return MomentsStoryDraftMedia(
                mediaAssetId: synced.id,
                mediaKind: synced.kind,
                sortOrder: media.sortOrder,
                selected: media.selected,
                moderationStatus: synced.moderationStatus
            )
        }
        let pendingMediaToSave = mediaToSave.filter {
            syncedMediaBySourceIdentifier[$0.sourceLocalIdentifier] == nil
        }
        if pendingMediaToSave.isEmpty {
            statusMessage = "Media ready. Avi can prepare the story."
            return alreadySyncedMedia.sorted { $0.sortOrder < $1.sortOrder }
        }

        let generation = beginWorkflowGeneration()
        isImporting = true
        importProgress = MomentsMediaImportProgress(completedCount: 0, totalCount: pendingMediaToSave.count)
        statusMessage = "Uploading media for video creation."

        do {
            let result = try await MediaUploadPersistence.save(
                imported: pendingMediaToSave,
                ownerUserId: ownerUserId,
                bearerToken: bearerToken,
                projectId: projectId,
                uploadClient: uploadClient,
                mediaAssetSaver: mediaAssetSaver,
                progress: { [weak self] completedCount, totalCount in
                    self?.updateImportProgress(completedCount: completedCount, totalCount: totalCount)
                    self?.statusMessage = "Uploading media \(completedCount) of \(totalCount)."
                },
                shouldContinue: { isCurrentWorkflowGeneration(generation) }
            )
            guard isCurrentWorkflowGeneration(generation) else { return nil }
            statusMessage = result.statusMessage
            isImporting = false
            importProgress = nil
            return (alreadySyncedMedia + result.savedMedia).sorted { $0.sortOrder < $1.sortOrder }
        } catch MomentsUploadError.signedUploadUnavailable {
            guard isCurrentWorkflowGeneration(generation) else { return nil }
            statusMessage = "Media upload is not ready yet. Please try again in a moment."
            isImporting = false
            importProgress = nil
            return nil
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return nil }
            statusMessage = "Couldn’t save media for the story. Please try again."
            isImporting = false
            importProgress = nil
            return nil
        }
    }

    func reset(force: Bool = false) {
        guard force || !isImporting else { return }
        advanceWorkflowGeneration()
        isImporting = false
        importProgress = nil
        selectedMedia = []
        statusMessage = nil
        restoredWorkspaceProjectId = nil
        clearActiveWorkspace()
    }

    private func restoreLocalMedia(from workspace: MomentProjectWorkspace) async {
        let selectedAssetCount = workspace.mediaAssets.filter(\.selected).count
        let expectedSelectedCount = selectedAssetCount > 0 ? selectedAssetCount : workspace.mediaAssets.count
        do {
            let restoredMedia = try await MediaPickerImport.loadLocalMediaAssets(workspace.mediaAssets)
            guard activeWorkspace?.project.id == workspace.project.id, selectedMedia.isEmpty else { return }
            if restoredMedia.count == expectedSelectedCount {
                restoredWorkspaceProjectId = workspace.project.id
                selectedMedia = restoredMedia
                statusMessage = "Local media ready for editing."
            } else if restoredMedia.isEmpty, expectedSelectedCount > 0 {
                statusMessage = "Saved media is ready for review and video creation."
            } else if expectedSelectedCount > 0 {
                statusMessage = "Saved media is ready. Some local thumbnails may refresh in the background."
            }
        } catch MomentsUploadError.photoLibraryAccessDenied {
            guard activeWorkspace?.project.id == workspace.project.id else { return }
            statusMessage = "Saved media is ready for review and video creation."
        } catch {
            guard activeWorkspace?.project.id == workspace.project.id else { return }
            statusMessage = "Saved media is ready for review and video creation."
        }
    }

    private func beginImport(totalCount: Int) {
        isImporting = true
        importProgress = MomentsMediaImportProgress(completedCount: 0, totalCount: max(totalCount, 0))
        statusMessage = nil
    }

    private func updateImportProgress(completedCount: Int, totalCount: Int) {
        importProgress = MomentsMediaImportProgress(
            completedCount: max(completedCount, 0),
            totalCount: max(totalCount, completedCount)
        )
    }

    private func endImport() {
        isImporting = false
        importProgress = nil
    }

    private func normalizeOrder() {
        for index in selectedMedia.indices {
            selectedMedia[index].sortOrder = index
        }
    }

    private func sortChronologically() {
        if selectedMedia.contains(where: { $0.capturedAt != nil }) {
            selectedMedia = selectedMedia.sorted { left, right in
                switch (left.capturedAt, right.capturedAt) {
                case (.some(let leftDate), .some(let rightDate)):
                    if leftDate != rightDate {
                        return leftDate < rightDate
                    }
                    return left.sortOrder < right.sortOrder
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return sortByFilenameOrderOrSelection(left: left, right: right)
                }
            }
            normalizeOrder()
            return
        }

        if selectedMedia.allSatisfy({ $0.filenameOrderIndex != nil }) {
            selectedMedia = selectedMedia.sorted {
                sortByFilenameOrderOrSelection(left: $0, right: $1)
            }
            normalizeOrder()
            return
        }

        selectedMedia = selectedMedia.sorted { $0.sortOrder < $1.sortOrder }
        normalizeOrder()
    }

    private func sortByFilenameOrderOrSelection(left: MomentsSelectedMedia, right: MomentsSelectedMedia) -> Bool {
        guard let leftIndex = left.filenameOrderIndex,
              let rightIndex = right.filenameOrderIndex else {
            return left.sortOrder < right.sortOrder
        }

        if left.filenameOrderPrefix == right.filenameOrderPrefix, leftIndex != rightIndex {
            return leftIndex < rightIndex
        }

        return left.sortOrder < right.sortOrder
    }

    private func importStatusMessage(
        importedCount: Int,
        skippedDuplicateCount: Int,
        emptyMessage: String
    ) -> String {
        if importedCount == 0 {
            return skippedDuplicateCount > 0
                ? "Those moments were already selected."
                : emptyMessage
        }

        if skippedDuplicateCount > 0 {
            return "Added \(importedCount) \(importedCount == 1 ? "moment" : "moments"). Skipped \(skippedDuplicateCount) already selected."
        }

        return "Media ready. Avi can prepare the story."
    }

    private var selectedMediaCount: Int {
        MomentsMediaRules.selectedCount(
            localMedia: selectedMedia,
            syncedMedia: activeWorkspace?.mediaAssets ?? []
        )
    }

    private var activeWorkspaceStoryMedia: [MomentsStoryDraftMedia] {
        let mediaAssets = activeWorkspace?.mediaAssets ?? []
        let selectedAssets = mediaAssets.filter(\.selected)
        return (selectedAssets.isEmpty ? mediaAssets : selectedAssets)
            .sorted { $0.sortOrder < $1.sortOrder }
            .map {
                MomentsStoryDraftMedia(
                    mediaAssetId: $0.id,
                    mediaKind: $0.kind,
                    sortOrder: Int($0.sortOrder),
                    selected: $0.selected,
                    moderationStatus: $0.moderationStatus
                )
            }
    }
}

enum MomentsMediaDeduplicator {
    static func uniqueNewMedia(
        existing: [MomentsSelectedMedia],
        imported: [MomentsSelectedMedia]
    ) -> [MomentsSelectedMedia] {
        var seenSourceIdentifiers = Set(existing.map(\.sourceLocalIdentifier))
        var seenHashes = Set(existing.map(\.sha256))
        var unique: [MomentsSelectedMedia] = []

        for media in imported {
            let sourceIsDuplicate = seenSourceIdentifiers.contains(media.sourceLocalIdentifier)
            let hashIsDuplicate = seenHashes.contains(media.sha256)
            guard !sourceIsDuplicate && !hashIsDuplicate else { continue }

            seenSourceIdentifiers.insert(media.sourceLocalIdentifier)
            seenHashes.insert(media.sha256)
            unique.append(media)
        }

        return unique
    }
}

private extension MomentsSelectedMedia {
    var filenameOrderPrefix: String? {
        filenameOrderMatch?.prefix
    }

    var filenameOrderIndex: Int? {
        filenameOrderMatch?.index
    }

    private var filenameOrderMatch: (prefix: String, index: Int)? {
        let name = (originalFilename as NSString).deletingPathExtension
        guard let match = name.range(
            of: #"^(.+?)(\d+)$"#,
            options: .regularExpression
        ) else {
            return nil
        }

        let prefix = String(name[..<match.upperBound])
            .replacingOccurrences(
                of: #"\d+$"#,
                with: "",
                options: .regularExpression
            )
        let digits = String(name[match])
            .replacingOccurrences(
                of: #"^\D+"#,
                with: "",
                options: .regularExpression
            )

        guard !prefix.isEmpty, let index = Int(digits) else { return nil }
        return (prefix.lowercased(), index)
    }
}
