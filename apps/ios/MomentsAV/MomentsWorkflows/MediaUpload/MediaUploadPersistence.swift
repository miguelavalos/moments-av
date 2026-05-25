import Foundation

struct MediaUploadPersistenceResult: Equatable {
    let savedCount: Int
    let storageBlocked: Bool

    var statusMessage: String {
        if storageBlocked {
            return "Saved \(savedCount) media records. Signed storage upload is not enabled for this build."
        }
        return "Saved \(savedCount) media records."
    }
}

enum MediaUploadPersistence {
    @MainActor
    static func save(
        imported mediaItems: [MomentsSelectedMedia],
        ownerUserId: String,
        projectId: String,
        uploadClient: MomentsUploadClient,
        mediaAssetSaver: any MomentsMediaAssetSaving,
        shouldContinue: () -> Bool
    ) async throws -> MediaUploadPersistenceResult {
        var savedCount = 0
        var storageBlocked = false

        for media in mediaItems {
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

            try await mediaAssetSaver.saveMediaAsset(
                ownerUserId: ownerUserId,
                projectId: projectId,
                media: media,
                preparedUpload: prepared
            )

            guard shouldContinue() else {
                throw CancellationError()
            }

            savedCount += 1
        }

        return MediaUploadPersistenceResult(
            savedCount: savedCount,
            storageBlocked: storageBlocked
        )
    }
}
