import Foundation

struct RenderJobStatusRefreshError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}
