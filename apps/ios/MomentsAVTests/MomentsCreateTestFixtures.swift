import Foundation
@testable import MomentsAV

enum MomentsCreateTestFixtures {
    static func makeProject(id: String) -> MomentDraftProject {
        MomentDraftProject(
            id: id,
            template: .birthdayMessage,
            status: "draft_created",
            title: "Family Weekend",
            tone: nil,
            tempo: nil,
            occasion: nil,
            details: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 0,
            previewLimit: 3,
            updatedAt: 10
        )
    }

    static func makeMediaAsset(id: String, sortOrder: Double = 0) -> MomentMediaAsset {
        MomentMediaAsset(
            id: id,
            platformMediaAssetId: "platform-\(id)",
            uploadId: "upload-\(id)",
            kind: "image",
            sortOrder: sortOrder,
            selected: true,
            moderationStatus: "approved",
            uploadedAt: nil,
            sourceExpiresAt: nil
        )
    }

    static func makeSelectedMedia(
        id: String,
        sourceLocalIdentifier: String? = nil,
        sha256: String? = nil
    ) -> MomentsSelectedMedia {
        MomentsSelectedMedia(
            id: UUID(uuidString: id)!,
            sourceLocalIdentifier: sourceLocalIdentifier ?? id,
            originalFilename: "\(id).jpg",
            contentType: "image/jpeg",
            kind: "image",
            byteSize: 4,
            sha256: sha256 ?? id,
            data: Data([1, 2, 3, 4]),
            capturedAt: nil,
            sortOrder: 0,
            selected: true
        )
    }

    static func makeScene(id: String, sceneIndex: Double = 0, caption: String = "Opening") -> MomentStoryScene {
        MomentStoryScene(
            id: id,
            sceneIndex: sceneIndex,
            mediaAssetIds: [],
            caption: caption,
            narrationText: nil,
            tone: nil,
            musicCue: nil,
            durationMs: 3_000,
            createdBy: "avi"
        )
    }

    static func makeArtifact(id: String, kind: String) -> MomentArtifact {
        MomentArtifact(
            id: id,
            kind: kind,
            r2Key: "momentsav/\(id).mp4",
            status: "available",
            hasWatermark: kind == "preview",
            expiresAt: 1_781_592_000_000
        )
    }

    static func makeRenderJob(id: String, kind: String, status: String) -> MomentRenderJob {
        MomentRenderJob(
            id: id,
            kind: kind,
            status: status,
            workflowRunId: "workflow-\(id)",
            provider: "mock-provider",
            model: "mock-model",
            providerRequestId: "request-\(id)",
            errorCode: nil,
            errorMessage: nil,
            createdAt: 9,
            updatedAt: 10
        )
    }

    static func makeRefreshAvailability(canRefresh: Bool) -> RenderJobStatusRefreshAvailability {
        RenderJobStatusRefreshAvailability(
            projectId: canRefresh ? "project-1" : nil,
            job: canRefresh ? MomentsCreateTestFixtures.makeRenderJob(id: "job-1", kind: "preview", status: "running") : nil,
            isAvailable: canRefresh,
            isConfigured: canRefresh,
            isRefreshing: false,
            unavailableMessage: "Unavailable.",
            notConfiguredMessage: "Not configured.",
            missingProjectMessage: "Missing project.",
            missingJobMessage: "Missing job.",
            missingProviderRequestMessage: "Missing request."
        )
    }
}
