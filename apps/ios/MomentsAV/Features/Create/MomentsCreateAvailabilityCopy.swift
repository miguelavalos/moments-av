import Foundation

enum MomentsCreateAvailabilityCopy {
    static let draftSignInRequired = "Sign in before starting a project."
    static let projectSyncNotConfigured = "Project sync is not configured for this build."
    static let mediaMissingProject = "Start or continue a project before adding media."
    static let mediaUploadNotConfigured = "Media upload is not configured for this build."
    static let mediaTemplateFull = "Avi has enough media for this video."
    static let storyMissingProject = "Start or continue a project before generating a story."
    static let storyUnavailable = "Story drafting is not available yet."
    static let storyNotConfigured = "Story drafting is not configured for this build."
    static let storyMissingMedia = "Add photos or clips before preparing the story."
    static let previewMissingProject = "Start or continue a project before generating a preview."
    static let previewUnavailable = "Preview generation is not available yet."
    static let previewNotConfigured = "Preview generation is not configured for this build."
    static let previewMissingWorkspace = "Wait for the project workspace to sync before generating a preview."
    static let finalRenderMissingProject = "Start or continue a project before rendering the final export."
    static let finalRenderUnavailable = "Final rendering is not available yet."
    static let finalRenderNotConfigured = "Final rendering is not configured for this build."
    static let finalRenderMissingWorkspace = "Wait for the project workspace to sync before rendering the final export."

    static func previewInsufficientCredits(missingCredits: Int) -> String {
        "Add \(missingCredits) more \(MomentsCreditCopy.noun(missingCredits)) before generating a preview."
    }

    static func finalRenderInsufficientCredits(missingCredits: Int) -> String {
        "Add \(missingCredits) more \(MomentsCreditCopy.noun(missingCredits)) before final render."
    }
}
