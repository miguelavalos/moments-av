import CryptoKit
import Foundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

enum MediaPickerImport {
    static func load(
        items: [PhotosPickerItem],
        limit: Int,
        startingSortOrder: Int
    ) async throws -> [MomentsSelectedMedia] {
        var imported: [MomentsSelectedMedia] = []

        for (offset, item) in items.prefix(limit).enumerated() {
            let media = try await loadMedia(
                from: item,
                sortOrder: startingSortOrder + offset
            )
            imported.append(media)
        }

        return imported
    }

    private static func loadMedia(from item: PhotosPickerItem, sortOrder: Int) async throws -> MomentsSelectedMedia {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw MomentsUploadError.unreadableSelection
        }

        let contentType = item.supportedContentTypes.first?.preferredMIMEType ?? "application/octet-stream"
        let kind = item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) ? "video" : "photo"
        let digest = SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()

        return MomentsSelectedMedia(
            id: UUID(),
            sourceLocalIdentifier: item.itemIdentifier ?? UUID().uuidString,
            originalFilename: "\(UUID().uuidString).\(kind == "video" ? "mov" : "jpg")",
            contentType: contentType,
            kind: kind,
            byteSize: data.count,
            sha256: digest,
            data: data,
            sortOrder: sortOrder,
            selected: true
        )
    }
}
