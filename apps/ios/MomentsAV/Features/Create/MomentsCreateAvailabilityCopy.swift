import Foundation

enum MomentsCreateAvailabilityCopy {
    static let draftSignInRequired = "Sign in before starting a project."
    static let projectSyncNotConfigured = "Project sync is not configured for this build."
    static let mediaMissingProject = "Start or continue a project before adding media."
    static let mediaUploadNotConfigured = "Media upload is not configured for this build."
    static let mediaTemplateFull = "Avi has enough media for this video."
    static let storySignInRequired = "Sign in before preparing the story."
    static let storyMissingProject = "Start or continue a project before preparing the story."
    static let storyUnavailable = "Story preparation is not available yet."
    static let storyNotConfigured = "Story preparation is not configured for this build."
    static let storyMissingMedia = "Add photos or clips before preparing the story."
    static let previewMissingProject = "Start or continue a project before reviewing the story."
    static let previewUnavailable = "Story Review is not available yet."
    static let previewNotConfigured = "Story Review is not configured for this build."
    static let previewMissingWorkspace = "Wait for the project workspace to sync before reviewing the story."
    static let finalRenderMissingProject = "Start or continue a Moment before creating the final video."
    static let finalRenderUnavailable = "Final video creation is not available yet."
    static let finalRenderNotConfigured = "Final video creation is not configured for this build."
    static let finalRenderMissingWorkspace = "Wait for this Moment to sync before creating the final video."

    static func previewInsufficientCredits(missingCredits: Int) -> String {
        "Add \(missingCredits) more \(MomentsCreditCopy.noun(missingCredits)) before reviewing the story."
    }

    static func finalRenderInsufficientCredits(missingCredits: Int) -> String {
        "Add \(missingCredits) more \(MomentsCreditCopy.noun(missingCredits)) before creating the final video."
    }
}
