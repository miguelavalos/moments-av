import Foundation

enum MomentsDateFormatting {
    static func formattedDate(milliseconds: Double) -> String {
        let date = Date(timeIntervalSince1970: milliseconds / 1000)
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

enum MomentsProjectFormatting {
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
