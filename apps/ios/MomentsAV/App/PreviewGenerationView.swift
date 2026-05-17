import SwiftUI

struct PreviewGenerationView: View {
    let template: MomentTemplate
    let project: MomentDraftProject
    let latestPreview: MomentArtifact?
    let latestRenderJob: MomentRenderJob?

    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var projectStore: MomentsProjectStore
    @State private var statusMessage: String?
    @State private var isGenerating = false
    @State private var isRefreshingStatus = false

    private var previewClient: MomentsPreviewClient {
        MomentsPreviewClient(baseURLString: AppConfig.momentsAPIBaseURL)
    }

    private var statusClient: MomentsRenderStatusClient {
        MomentsRenderStatusClient(baseURLString: AppConfig.momentsAPIBaseURL)
    }

    private var canGenerate: Bool {
        accountController.user != nil
            && previewClient.isConfigured
            && MomentsPreviewRules.canGenerate(project: project, template: template, balance: accountController.creditBalance)
            && !isGenerating
    }

    var body: some View {
        Section("Preview") {
            LabeledContent("Previews", value: "\(Int(project.previewCount))/\(Int(project.previewLimit))")

            if let latestPreview {
                Label("Preview ready to edit", systemImage: "play.rectangle")
                Text(latestPreview.hasWatermark == true ? "Includes a subtle Moments AV mark." : "Preview artifact is available.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("Avi can generate a low-cost preview after the story is ready.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let latestRenderJob {
                RenderJobStatusView(renderJob: latestRenderJob)

                Button {
                    Task { await refreshRenderStatus(renderJob: latestRenderJob) }
                } label: {
                    Label(isRefreshingStatus ? "Refreshing Status" : "Refresh Preview Status", systemImage: "arrow.clockwise")
                }
                .disabled(accountController.user == nil || !statusClient.isConfigured || isRefreshingStatus)
            }

            Button {
                Task { await generatePreview() }
            } label: {
                Label(isGenerating ? "Generating Preview" : "Generate Preview", systemImage: "play.circle")
            }
            .disabled(!canGenerate)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func generatePreview() async {
        guard let ownerUserId = accountController.user?.id else { return }

        isGenerating = true
        statusMessage = "Avi is preparing a preview."

        do {
            let preview = try await previewClient.generatePreview(
                projectId: project.id,
                ownerUserId: ownerUserId,
                template: template,
                previewIndex: Int(project.previewCount) + 1
            )
            if await projectStore.savePreviewResult(
                ownerUserId: ownerUserId,
                projectId: project.id,
                preview: preview,
                template: template
            ) {
                statusMessage = "Preview ready. You can still edit the story before final render."
            }
        } catch {
            statusMessage = error.localizedDescription
        }

        isGenerating = false
    }

    private func refreshRenderStatus(renderJob: MomentRenderJob) async {
        guard let ownerUserId = accountController.user?.id else { return }

        isRefreshingStatus = true
        statusMessage = nil

        if await projectStore.refreshRenderStatus(
            ownerUserId: ownerUserId,
            renderJob: renderJob,
            statusClient: statusClient
        ) {
            statusMessage = "Preview status updated."
        }

        isRefreshingStatus = false
    }
}
