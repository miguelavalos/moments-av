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
        isImporting = true
        statusMessage = nil

        do {
            let imported = try await MediaPickerImport.load(
                items: items,
                limit: remainingSlots,
                startingSortOrder: selectedMedia.count
            )

            guard isCurrentWorkflowGeneration(generation) else { return }
            selectedMedia.append(contentsOf: imported)
            sortChronologically()
            statusMessage = "Media ready. Avi can prepare the preview."
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = error.localizedDescription
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        isImporting = false
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
        isImporting = true
        statusMessage = nil

        do {
            let imported = try await MediaPickerImport.loadLatestPhotos(
                limit: remainingSlots,
                startingSortOrder: selectedMedia.count
            )

            guard isCurrentWorkflowGeneration(generation) else { return }
            selectedMedia.append(contentsOf: imported)
            sortChronologically()
            statusMessage = imported.isEmpty ? "No recent photos found." : "Latest photos added."
        } catch {
            guard isCurrentWorkflowGeneration(generation) else { return }
            statusMessage = error.localizedDescription
        }

        guard isCurrentWorkflowGeneration(generation) else { return }
        isImporting = false
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

    func reset(force: Bool = false) {
        guard force || !isImporting else { return }
        advanceWorkflowGeneration()
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

    private var selectedMediaCount: Int {
        MomentsMediaRules.selectedCount(
            localMedia: selectedMedia,
            syncedMedia: activeWorkspace?.mediaAssets ?? []
        )
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
