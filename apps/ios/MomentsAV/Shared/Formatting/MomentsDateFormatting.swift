import Foundation

enum MomentsDateFormatting {
    static func formattedDate(milliseconds: Double) -> String {
        let date = Date(timeIntervalSince1970: milliseconds / 1000)
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

enum MomentsProjectFormatting {
    static func updatedAt(_ project: MomentDraftProject) -> String {
        "Updated \(MomentsDateFormatting.formattedDate(milliseconds: project.updatedAt))"
    }

    static func previewUsage(_ project: MomentDraftProject) -> String {
        "\(Int(project.previewCount))/\(Int(project.previewLimit)) Story Reviews"
    }

    static func statusTitle(_ project: MomentDraftProject) -> String {
        MomentsProjectStatusRules.displayTitle(for: project.status)
    }

    static func compactDetail(for project: MomentDraftProject, includeTitle: Bool = false) -> String {
        var parts: [String] = []

        if includeTitle {
            parts.append(project.title)
        }

        parts.append(statusTitle(project))
        parts.append(updatedAt(project))
        parts.append(previewUsage(project))

        return parts.joined(separator: " · ")
    }

    static func mediaAssetDetail(_ media: MomentMediaAsset) -> String {
        let selection = media.selected ? "Selected" : "Not selected"
        return "\(selection) · \(MomentsProjectStatusRules.displayTitle(for: media.moderationStatus))"
    }

    static func artifactDetail(_ artifact: MomentArtifact) -> String {
        var parts = [
            MomentsProjectStatusRules.displayTitle(for: artifact.status)
        ]

        if artifact.hasWatermark == true {
            parts.append("Watermarked")
        }

        parts.append("Expires \(MomentsDateFormatting.formattedDate(milliseconds: artifact.expiresAt))")
        return parts.joined(separator: " · ")
    }
}
