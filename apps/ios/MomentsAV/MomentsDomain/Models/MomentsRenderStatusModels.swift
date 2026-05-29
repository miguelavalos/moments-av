import Foundation

struct MomentsRenderStatusResponse: Decodable, Equatable {
    let appId: String
    let projectId: String
    let renderJobId: String
    let workflowRunId: String?
    let renderKind: String
    let status: String
    let phase: String?
    let progressPercent: Int
    let userMessage: String?
    let canEditDraft: Bool?
    let canRetry: Bool?
    let artifactId: String?
    let artifactKind: String?
    let artifactStatus: String?
    let errorCode: String?
    let errorMessage: String?
    let updatedAt: String
}
