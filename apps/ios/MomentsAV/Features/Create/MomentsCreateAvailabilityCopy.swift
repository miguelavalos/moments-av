import Foundation

enum MomentsCreateAvailabilityCopy {
    static var draftSignInRequired: String { L10n.string("create.availability.draftSignInRequired") }
    static var momentSyncNotConfigured: String { L10n.string("create.availability.momentSyncNotConfigured") }
    static var mediaMissingProject: String { L10n.string("create.availability.mediaMissingProject") }
    static var mediaUploadNotConfigured: String { L10n.string("create.availability.mediaUploadNotConfigured") }
    static var mediaTemplateFull: String { L10n.string("create.availability.mediaTemplateFull") }
    static var storySignInRequired: String { L10n.string("create.availability.storySignInRequired") }
    static var storyMissingProject: String { L10n.string("create.availability.storyMissingProject") }
    static var storyUnavailable: String { L10n.string("create.availability.storyUnavailable") }
    static var storyNotConfigured: String { L10n.string("create.availability.storyNotConfigured") }
    static var storyMissingMedia: String { L10n.string("create.availability.storyMissingMedia") }
    static var previewMissingProject: String { L10n.string("create.availability.previewMissingProject") }
    static var previewUnavailable: String { L10n.string("create.availability.previewUnavailable") }
    static var previewNotConfigured: String { L10n.string("create.availability.previewNotConfigured") }
    static var previewMissingWorkspace: String { L10n.string("create.availability.previewMissingWorkspace") }
    static var finalRenderMissingProject: String { L10n.string("create.availability.finalRenderMissingProject") }
    static var finalRenderUnavailable: String { L10n.string("create.availability.finalRenderUnavailable") }
    static var finalRenderNotConfigured: String { L10n.string("create.availability.finalRenderNotConfigured") }
    static var finalRenderMissingWorkspace: String { L10n.string("create.availability.finalRenderMissingWorkspace") }

    static func previewInsufficientCredits(missingCredits: Int) -> String {
        L10n.string("create.availability.previewInsufficientCredits", missingCredits, MomentsCreditCopy.noun(missingCredits))
    }

    static func finalRenderInsufficientCredits(missingCredits: Int) -> String {
        L10n.string("create.availability.finalRenderInsufficientCredits", missingCredits, MomentsCreditCopy.noun(missingCredits))
    }
}
