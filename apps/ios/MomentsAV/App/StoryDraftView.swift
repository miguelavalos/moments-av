import SwiftUI

struct StoryDraftView: View {
    let template: MomentTemplate
    let projectId: String
    let form: MomentDraftForm
    let mediaAssets: [MomentMediaAsset]
    let savedScenes: [MomentStoryScene]

    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var projectStore: MomentsProjectStore
    @State private var draft: MomentsStoryDraftResponse?
    @State private var statusMessage: String?
    @State private var isDrafting = false

    private var storyClient: MomentsStoryClient {
        MomentsStoryClient(baseURLString: AppConfig.momentsAPIBaseURL)
    }

    private var canDraft: Bool {
        accountController.user != nil
            && storyClient.isConfigured
            && MomentsStoryDraftRules.canDraft(mediaAssets: mediaAssets, template: template)
            && !isDrafting
    }

    var body: some View {
        Section("Story") {
            AviCompanionView(
                state: .storyDraft,
                message: "Review the generated scenes before preview. The draft stays editable."
            )

            if !savedScenes.isEmpty {
                ForEach(savedScenes.sorted { $0.sceneIndex < $1.sceneIndex }) { scene in
                    StorySceneRow(
                        sceneIndex: Int(scene.sceneIndex),
                        caption: scene.caption,
                        narrationText: scene.narrationText ?? ""
                    )
                }
            } else if let draft {
                Text(draft.helperCopy)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(draft.scenes) { scene in
                    StorySceneRow(
                        sceneIndex: scene.sceneIndex,
                        caption: scene.caption,
                        narrationText: scene.narrationText
                    )
                }
            }

            Button {
                Task { await generateStoryDraft() }
            } label: {
                Label(isDrafting ? "Drafting Story" : "Ask Avi for Story Draft", systemImage: "text.bubble")
            }
            .disabled(!canDraft)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func generateStoryDraft() async {
        guard let ownerUserId = accountController.user?.id else { return }

        isDrafting = true
        statusMessage = nil

        do {
            let generatedDraft = try await storyClient.generateDraft(
                projectId: projectId,
                ownerUserId: ownerUserId,
                form: form,
                mediaAssets: mediaAssets
            )
            draft = generatedDraft

            if await projectStore.saveStoryDraft(
                ownerUserId: ownerUserId,
                projectId: projectId,
                draft: generatedDraft
            ) {
                statusMessage = generatedDraft.helperCopy
            }
        } catch {
            statusMessage = error.localizedDescription
        }

        isDrafting = false
    }
}

struct StorySceneRow: View {
    let sceneIndex: Int
    let caption: String
    let narrationText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Scene \(sceneIndex + 1)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MomentsBrand.ColorToken.primaryAccent)
            Text(caption)
                .font(.subheadline.weight(.medium))
            Text(narrationText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
