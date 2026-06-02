import Foundation

struct MomentsRenderStatusResponse: Decodable, Equatable {
    let appId: String
    let momentId: String
    let renderJobId: String
    let workflowRunId: String?
    let renderKind: String
    let status: String
    let phase: String?
    let progressPercent: Int
    let userMessage: String?
    let canEditSetup: Bool?
    let canRetry: Bool?
    let artifactId: String?
    let artifactKind: String?
    let artifactStatus: String?
    let errorCode: String?
    let errorMessage: String?
    let updatedAt: String
}
