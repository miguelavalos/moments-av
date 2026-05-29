import Foundation

enum MomentsCreateUITestFixtures {
    static let projectId = "moments-ui-project-1"

    static var project: MomentDraftProject {
        MomentDraftProject(
            id: projectId,
            template: .birthdayMessage,
            status: "final_rendering",
            title: "Family Weekend",
            tone: "warm",
            tempo: "balanced",
            occasion: "Birthday",
            details: "Keep the opening gentle, highlight the cake scene, and end with the beach clip.",
            storyInputSignature: nil,
            durationSeconds: 30,
            creditCost: 2,
            previewCount: 1,
            previewLimit: 3,
            updatedAt: 1_781_592_000_000
        )
    }

    static var workspace: MomentProjectWorkspace {
        MomentProjectWorkspace(
            project: project,
            mediaAssets: mediaAssets,
            storyScenes: storyScenes,
            renderJobs: renderJobs,
            artifacts: artifacts
        )
    }

    static var balance: MomentsCreditBalance {
        MomentsCreditBalance(proMonthly: 4, promotional: 1, purchased: 3)
    }

    static var selectedMedia: [MomentsSelectedMedia] {
        [
            selectedMedia(id: "11111111-1111-1111-1111-111111111111", filename: "cake-candles.jpg", sortOrder: 0),
            selectedMedia(id: "22222222-2222-2222-2222-222222222222", filename: "beach-toast.mov", kind: "video", contentType: "video/quicktime", sortOrder: 1)
        ]
    }

    static var mediaAssets: [MomentMediaAsset] {
        [
            mediaAsset(id: "media-1", kind: "image", sortOrder: 0),
            mediaAsset(id: "media-2", kind: "video", sortOrder: 1),
            mediaAsset(id: "media-3", kind: "image", sortOrder: 2)
        ]
    }

    static var storyScenes: [MomentStoryScene] {
        [
            storyScene(
                id: "scene-1",
                index: 0,
                caption: "A warm opening with the birthday table and first hug.",
                narration: "We begin with the quiet details that made the day feel personal."
            ),
            storyScene(
                id: "scene-2",
                index: 1,
                caption: "A quick lift into candles, laughter, and the beach toast.",
                narration: "The middle keeps the pace bright while still feeling intimate."
            )
        ]
    }

    static var renderJobs: [MomentRenderJob] {
        [
            renderJob(id: "preview-job-1", kind: "preview", status: "completed", model: "moments-preview-route"),
            renderJob(id: "final-job-1", kind: "final", status: "completed", model: "moments-final-route")
        ]
    }

    static var artifacts: [MomentArtifact] {
        [
            artifact(id: "preview-artifact-1", kind: "preview", key: "momentsav/ui-test/project-1/previews/preview-1.mp4", hasWatermark: true),
            artifact(id: "final-artifact-1", kind: "final", key: "momentsav/ui-test/project-1/final/final-1.mp4", hasWatermark: false)
        ]
    }

    private static func selectedMedia(
        id: String,
        filename: String,
        kind: String = "image",
        contentType: String = "image/jpeg",
        sortOrder: Double
    ) -> MomentsSelectedMedia {
        MomentsSelectedMedia(
            id: UUID(uuidString: id)!,
            sourceLocalIdentifier: id,
            originalFilename: filename,
            contentType: contentType,
            kind: kind,
            byteSize: kind == "video" ? 8_800_000 : 2_400_000,
            sha256: "ui-test-\(id)",
            data: Data([1, 2, 3, 4]),
            capturedAt: nil,
            sortOrder: Int(sortOrder),
            selected: true
        )
    }

    private static func mediaAsset(id: String, kind: String, sortOrder: Double) -> MomentMediaAsset {
        MomentMediaAsset(
            id: id,
            platformMediaAssetId: "platform-\(id)",
            uploadId: "upload-\(id)",
            kind: kind,
            sortOrder: sortOrder,
            selected: true,
            moderationStatus: "approved",
            uploadedAt: 1_781_591_000_000 + sortOrder,
            sourceExpiresAt: nil
        )
    }

    private static func storyScene(
        id: String,
        index: Double,
        caption: String,
        narration: String
    ) -> MomentStoryScene {
        MomentStoryScene(
            id: id,
            sceneIndex: index,
            mediaAssetIds: [],
            caption: caption,
            narrationText: narration,
            tone: "warm",
            musicCue: "gentle acoustic pulse",
            durationMs: 6_000,
            createdBy: "avi"
        )
    }

    private static func renderJob(
        id: String,
        kind: String,
        status: String,
        model: String
    ) -> MomentRenderJob {
        MomentRenderJob(
            id: id,
            kind: kind,
            status: status,
            phase: status == "completed" ? "completed" : "queued",
            progressPercent: status == "completed" ? 100 : 10,
            userMessage: status == "completed" ? "Your video is ready." : "Avi has started creating the video.",
            canEditDraft: status != "running",
            canRetry: status == "failed",
            targetDurationMs: 15_000,
            plannedAssetCount: 10,
            usedAssetCount: 10,
            rejectedAssetCount: 0,
            rendererMode: "ui-test",
            workflowRunId: "workflow-\(id)",
            provider: "apps-av-ui-test",
            model: model,
            providerRequestId: "request-\(id)",
            errorCode: nil,
            errorMessage: nil,
            createdAt: 1_781_591_000_000,
            updatedAt: 1_781_592_000_000
        )
    }

    private static func artifact(
        id: String,
        kind: String,
        key: String,
        hasWatermark: Bool
    ) -> MomentArtifact {
        MomentArtifact(
            id: id,
            kind: kind,
            r2Key: key,
            status: "available",
            hasWatermark: hasWatermark,
            expiresAt: 1_781_852_000_000
        )
    }
}
