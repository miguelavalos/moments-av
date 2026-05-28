import Foundation

struct MediaUploadPersistenceResult {
    let savedCount: Int
    let savedMedia: [MomentsStoryDraftMedia]
    let storageBlocked: Bool

    var statusMessage: String {
        if storageBlocked {
            return "\(savedCount) item\(savedCount == 1 ? "" : "s") added to this Moment."
        }
        return "\(savedCount) item\(savedCount == 1 ? "" : "s") added to this Moment."
    }
}

enum MediaUploadPersistence {
    private static let uploadConcurrencyLimit = 3

    private struct UploadedMedia {
        let media: MomentsSelectedMedia
        let preparedUpload: MomentsPreparedUpload
    }

    @MainActor
    static func save(
        imported mediaItems: [MomentsSelectedMedia],
        ownerUserId: String,
        bearerToken: String,
        projectId: String,
        uploadClient: MomentsUploadClient,
        mediaAssetSaver: any MomentsMediaAssetSaving,
        progress: @MainActor @escaping (_ completedCount: Int, _ totalCount: Int) -> Void = { _, _ in },
        shouldContinue: @MainActor () -> Bool
    ) async throws -> MediaUploadPersistenceResult {
        let totalCount = mediaItems.count
        guard totalCount > 0 else {
            return MediaUploadPersistenceResult(savedCount: 0, savedMedia: [], storageBlocked: false)
        }

        var completedUploads = 0
        let uploadedMedia = try await uploadMedia(
            mediaItems,
            projectId: projectId,
            bearerToken: bearerToken,
            uploadClient: uploadClient,
            shouldContinue: shouldContinue,
            progress: { completedCount in
                completedUploads = completedCount
                progress(completedCount, totalCount)
            }
        )

        guard shouldContinue() else {
            throw CancellationError()
        }

        let mediaAssetRequests = uploadedMedia.map {
            MediaAssetPersistenceRequest.asset($0.media, preparedUpload: $0.preparedUpload)
        }
        let savedMediaAssetIds = try await mediaAssetSaver.saveMediaAssets(
            ownerUserId: ownerUserId,
            projectId: projectId,
            mediaAssets: mediaAssetRequests
        )

        return MediaUploadPersistenceResult(
            savedCount: completedUploads,
            savedMedia: zip(uploadedMedia, savedMediaAssetIds).map { uploaded, savedMediaAssetId in
                MomentsStoryDraftMedia(
                    mediaAssetId: savedMediaAssetId,
                    mediaKind: uploaded.media.kind,
                    sortOrder: uploaded.media.sortOrder,
                    selected: uploaded.media.selected,
                    moderationStatus: "pending"
                )
            },
            storageBlocked: uploadedMedia.contains { $0.preparedUpload.uploadUrl == nil }
        )
    }

    @MainActor
    private static func uploadMedia(
        _ mediaItems: [MomentsSelectedMedia],
        projectId: String,
        bearerToken: String,
        uploadClient: MomentsUploadClient,
        shouldContinue: @MainActor () -> Bool,
        progress: @MainActor @escaping (_ completedCount: Int) -> Void
    ) async throws -> [UploadedMedia] {
        var nextIndex = 0
        var completedCount = 0
        var uploadedMedia: [UploadedMedia] = []

        try await withThrowingTaskGroup(of: UploadedMedia.self) { group in
            func enqueueNextUpload() {
                guard nextIndex < mediaItems.count else { return }
                let media = mediaItems[nextIndex]
                nextIndex += 1
                group.addTask {
                    let prepared = try await uploadClient.prepareUpload(
                        projectId: projectId,
                        bearerToken: bearerToken,
                        media: media
                    )

                    do {
                        try await uploadClient.upload(
                            media: media,
                            preparedUpload: prepared
                        )
                    } catch MomentsUploadError.signedUploadUnavailable {
                        return UploadedMedia(media: media, preparedUpload: prepared)
                    }

                    return UploadedMedia(media: media, preparedUpload: prepared)
                }
            }

            for _ in 0..<min(uploadConcurrencyLimit, mediaItems.count) {
                enqueueNextUpload()
            }

            while let uploaded = try await group.next() {
                guard shouldContinue() else {
                    group.cancelAll()
                    throw CancellationError()
                }

                completedCount += 1
                uploadedMedia.append(uploaded)
                progress(completedCount)
                enqueueNextUpload()
            }
        }

        return uploadedMedia.sorted { $0.media.sortOrder < $1.media.sortOrder }
    }
}
