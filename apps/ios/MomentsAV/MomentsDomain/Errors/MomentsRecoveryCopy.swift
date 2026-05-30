import Foundation

enum MomentsRecoveryCopy {
    static func mediaImportFailure() -> String {
        "Couldn’t add that media. Your photos are still on this device; try again or choose different items."
    }

    static func mediaUploadUnavailable() -> String {
        "Media upload is not ready yet. Your photos and videos are still on this device; please try again in a moment."
    }

    static func mediaStorySaveFailure() -> String {
        "Couldn’t save media for the story. Your photos and videos are still on this device; try again or choose different items."
    }

    static func storyStartFailure() -> String {
        "Couldn’t start a Moment for this story. No final video credits were used. Please try again."
    }

    static func storyFailure() -> String {
        "Avi couldn’t prepare the story right now. No final video credits were used. Please try again."
    }

    static func renderStartFailure() -> String {
        "Couldn’t start video creation. No final video credits were used. Please try again in a moment."
    }

    static func renderRefreshFailure() -> String {
        "Couldn’t refresh the video status. Credits are only finalized when the video is ready. Please try again."
    }

    static func previewStatusMissing() -> String {
        "Preview status cannot be refreshed yet. Generate a preview again if this does not update."
    }

    static func finalRenderStatusMissing() -> String {
        "Final video status cannot be refreshed yet. Credits are only finalized when the video is ready. Please try again."
    }

    static func failedRenderDetail(userMessage: String?, errorMessage: String?) -> String {
        if let userMessage, !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return userMessage
        }

        return "Video creation hit a problem. Any reserved credits will be released if the video was not completed. Please try again or contact support."
    }

    static func artifactActionDetail(kind: String, status: String) -> String {
        let kindTitle = MomentsProjectStatusRules.displayKind(kind)

        switch status {
        case "available":
            return kind == "final_export"
                ? "Your final video is ready to export or share."
                : "\(kindTitle) is ready to review."
        case "expired":
            return "\(kindTitle) is no longer available. Return to Create and generate it again."
        case "failed", "error", "blocked":
            return "\(kindTitle) is not available. Credits are only finalized after a usable final video is ready. Please retry in Create or contact support."
        case "processing", "running", "queued":
            return "\(kindTitle) is still being prepared. Refresh the project in a moment."
        default:
            return "\(kindTitle) is not ready to export or share yet."
        }
    }
}
