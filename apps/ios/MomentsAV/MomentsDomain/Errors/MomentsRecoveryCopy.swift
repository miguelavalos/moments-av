import Foundation

enum MomentsRecoveryCopy {
    static func mediaImportFailure() -> String {
        "Couldn’t add that media. Your photos are still on this device; try again or choose different items."
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

    static func failedRenderDetail(userMessage: String?, errorMessage: String?) -> String {
        if let userMessage, !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return userMessage
        }

        return "Video creation hit a problem. Any reserved credits will be released if the video was not completed. Please try again or contact support."
    }
}
