import Foundation

enum MomentsProjectSyncError: LocalizedError {
    case notConfigured
    case invalidForm
    case missingRenderJob

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            "Project sync is not configured for this build."
        case .invalidForm:
            "Add the occasion before starting a project."
        case .missingRenderJob:
            "The backend did not return a render job for this request."
        }
    }
}
