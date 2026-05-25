import Foundation
import PhotosUI
import SwiftUI

enum MediaPickerImport {
    static func load(
        items: [PhotosPickerItem],
        limit: Int,
        startingSortOrder: Int,
        uploadClient: MomentsUploadClient
    ) async throws -> [MomentsSelectedMedia] {
        var imported: [MomentsSelectedMedia] = []

        for (offset, item) in items.prefix(limit).enumerated() {
            let media = try await uploadClient.loadMedia(
                from: item,
                sortOrder: startingSortOrder + offset
            )
            imported.append(media)
        }

        return imported
    }
}
