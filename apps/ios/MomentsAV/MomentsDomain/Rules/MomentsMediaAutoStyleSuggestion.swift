import Foundation

struct MomentsMediaAutoStyleSuggestion: Equatable {
    let styleID: MomentCreationStyleID
    let musicPreset: MomentMusicPreset
    let confidence: Double
    let reason: String
    let metrics: MomentsMediaAutoStyleMetrics

    var confidenceTitle: String {
        "\(Int((confidence * 100).rounded()))%"
    }
}

struct MomentsMediaAutoStyleMetrics: Equatable {
    let mediaCount: Int
    let photoCount: Int
    let videoCount: Int
    let datedCount: Int
    let totalBytes: Int
    let sampleCount: Int
    let estimatedThumbnailKilobytes: Int
    let estimatedVisionUnits: Int
    let estimatedMetadataTokens: Int

    var summary: String {
        "\(sampleCount) samples · \(estimatedThumbnailKilobytes) KB thumbs · \(estimatedMetadataTokens) metadata tokens"
    }
}

enum MomentsMediaAutoStyleSuggester {
    static func suggest(
        media: [MomentsSelectedMedia],
        styles: [MomentCreationStyle]
    ) -> MomentsMediaAutoStyleSuggestion? {
        guard !media.isEmpty else { return nil }

        let photoCount = media.filter { $0.kind == "photo" }.count
        let videoCount = media.filter { $0.kind == "video" }.count
        let datedMedia = media.compactMap(\.capturedAt)
        let filenames = media.map { $0.originalFilename.lowercased() }.joined(separator: " ")
        let totalBytes = media.reduce(0) { $0 + $1.byteSize }
        let sampleCount = min(media.count, 12)
        let metrics = MomentsMediaAutoStyleMetrics(
            mediaCount: media.count,
            photoCount: photoCount,
            videoCount: videoCount,
            datedCount: datedMedia.count,
            totalBytes: totalBytes,
            sampleCount: sampleCount,
            estimatedThumbnailKilobytes: sampleCount * 80,
            estimatedVisionUnits: sampleCount,
            estimatedMetadataTokens: media.count * 36
        )

        let dateSpan = dateSpanSeconds(datedMedia)
        let candidate: (MomentCreationStyleID, MomentMusicPreset, Double, String)

        if containsAny(filenames, keywords: ["birthday", "cumple", "anni", "bday"]) {
            candidate = (.birthday, .warm, 0.72, "Filename hints look like a birthday set.")
        } else if containsAny(filenames, keywords: ["trip", "travel", "viaje", "calama", "desert", "road", "playa", "mountain"]) {
            candidate = (.travel, .cinematic, 0.70, "Filename hints and media set look travel oriented.")
        } else if videoCount > 0 && videoCount >= max(1, photoCount / 3) {
            candidate = (.eventRecap, .fun, 0.64, "Several clips suggest a fast event recap.")
        } else if media.count >= 10 && dateSpan > 6 * 60 * 60 {
            candidate = (.travel, .cinematic, 0.62, "Many moments across several hours fit a trip or day recap.")
        } else if media.count >= 6 {
            candidate = (.familyMoments, .warm, 0.58, "A medium set works best as a warm memory recap.")
        } else {
            candidate = (.eventRecap, .warm, 0.48, "Small sets are safest as a simple event recap.")
        }

        guard let style = styles.first(where: { $0.id == candidate.0 && $0.isEnabled }) else {
            return nil
        }

        let music = style.allowedMusic.contains(candidate.1) ? candidate.1 : style.defaultMusic
        return MomentsMediaAutoStyleSuggestion(
            styleID: style.id,
            musicPreset: music,
            confidence: candidate.2,
            reason: candidate.3,
            metrics: metrics
        )
    }

    private static func dateSpanSeconds(_ dates: [Date]) -> TimeInterval {
        guard let first = dates.min(), let last = dates.max() else { return 0 }
        return last.timeIntervalSince(first)
    }

    private static func containsAny(_ value: String, keywords: [String]) -> Bool {
        keywords.contains { value.contains($0) }
    }
}
