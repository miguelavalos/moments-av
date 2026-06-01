import Foundation

enum MomentsCreateAvailabilityCopy {
    static var draftSignInRequired: String { MomentsL10n.string("create.availability.draftSignInRequired") }
    static var projectSyncNotConfigured: String { MomentsL10n.string("create.availability.projectSyncNotConfigured") }
    static var mediaMissingProject: String { MomentsL10n.string("create.availability.mediaMissingProject") }
    static var mediaUploadNotConfigured: String { MomentsL10n.string("create.availability.mediaUploadNotConfigured") }
    static var mediaTemplateFull: String { MomentsL10n.string("create.availability.mediaTemplateFull") }
    static var storySignInRequired: String { MomentsL10n.string("create.availability.storySignInRequired") }
    static var storyMissingProject: String { MomentsL10n.string("create.availability.storyMissingProject") }
    static var storyUnavailable: String { MomentsL10n.string("create.availability.storyUnavailable") }
    static var storyNotConfigured: String { MomentsL10n.string("create.availability.storyNotConfigured") }
    static var storyMissingMedia: String { MomentsL10n.string("create.availability.storyMissingMedia") }
    static var previewMissingProject: String { MomentsL10n.string("create.availability.previewMissingProject") }
    static var previewUnavailable: String { MomentsL10n.string("create.availability.previewUnavailable") }
    static var previewNotConfigured: String { MomentsL10n.string("create.availability.previewNotConfigured") }
    static var previewMissingWorkspace: String { MomentsL10n.string("create.availability.previewMissingWorkspace") }
    static var finalRenderMissingProject: String { MomentsL10n.string("create.availability.finalRenderMissingProject") }
    static var finalRenderUnavailable: String { MomentsL10n.string("create.availability.finalRenderUnavailable") }
    static var finalRenderNotConfigured: String { MomentsL10n.string("create.availability.finalRenderNotConfigured") }
    static var finalRenderMissingWorkspace: String { MomentsL10n.string("create.availability.finalRenderMissingWorkspace") }

    static func previewInsufficientCredits(missingCredits: Int) -> String {
        MomentsL10n.string("create.availability.previewInsufficientCredits", missingCredits, MomentsCreditCopy.noun(missingCredits))
    }

    static func finalRenderInsufficientCredits(missingCredits: Int) -> String {
        MomentsL10n.string("create.availability.finalRenderInsufficientCredits", missingCredits, MomentsCreditCopy.noun(missingCredits))
    }
}
