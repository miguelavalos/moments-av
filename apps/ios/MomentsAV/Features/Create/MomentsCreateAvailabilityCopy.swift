import Foundation

enum MomentsCreateAvailabilityCopy {
    static let draftSignInRequired = "Sign in before creating a draft."
    static let projectSyncNotConfigured = "Project sync is not configured for this build."
    static let mediaMissingProject = "Create or continue a draft before adding media."
    static let mediaUploadNotConfigured = "Media upload is not configured for this build."
    static let mediaTemplateFull = "Remove media before adding more to this template."
    static let storyMissingProject = "Create or continue a draft before generating a story."
    static let storyUnavailable = "Story drafting is not available yet."
    static let storyNotConfigured = "Story drafting is not configured for this build."
    static let storyMissingMedia = "Wait for synced media before drafting."
    static let previewMissingProject = "Create or continue a draft before generating a preview."
    static let previewUnavailable = "Preview generation is not available yet."
    static let previewNotConfigured = "Preview generation is not configured for this build."
    static let previewMissingWorkspace = "Wait for the project workspace to sync before generating a preview."
    static let finalRenderMissingProject = "Create or continue a draft before rendering the final export."
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
