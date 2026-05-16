import Foundation

struct MomentsSelectedMedia: Identifiable, Equatable {
    let id: UUID
    let sourceLocalIdentifier: String
    let originalFilename: String
    let contentType: String
    let kind: String
    let byteSize: Int
    let sha256: String
    let data: Data
    var sortOrder: Int
    var selected: Bool

    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: Int64(byteSize), countStyle: .file)
    }
}

struct MomentsPreparedUpload: Decodable, Equatable {
    let appId: String
    let projectId: String
    let mediaAssetId: String
    let uploadId: String
    let uploadUrl: URL?
    let method: String
    let headers: [String: String]
    let storageKey: String
    let expiresAt: String
    let generatedAt: String
}

enum MomentsMediaRules {
    static func canStartPreview(template: MomentTemplate, selectedCount: Int) -> Bool {
        selectedCount >= template.minimumAssets && selectedCount <= template.maximumAssets
    }

    static func message(template: MomentTemplate, selectedCount: Int) -> String {
        if selectedCount < template.minimumAssets {
            return "Add \(template.minimumAssets - selectedCount) more."
        }

        if selectedCount > template.maximumAssets {
            return "Remove \(selectedCount - template.maximumAssets)."
        }

        return "Ready for Avi review."
    }
}
