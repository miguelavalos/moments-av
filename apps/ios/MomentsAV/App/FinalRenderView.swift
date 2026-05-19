import SwiftUI

struct FinalRenderView: View {
    let template: MomentTemplate
    let project: MomentDraftProject
    let latestPreview: MomentArtifact?
    let finalExport: MomentArtifact?
    let latestRenderJob: MomentRenderJob?

    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var projectStore: MomentsProjectStore
    @State private var statusMessage: String?
    @State private var isGenerating = false
    @State private var isRefreshingStatus = false

    private var finalClient: MomentsFinalRenderClient {
        MomentsFinalRenderClient(baseURLString: AppConfig.momentsAPIBaseURL)
    }

    private var statusClient: MomentsRenderStatusClient {
        MomentsRenderStatusClient(baseURLString: AppConfig.momentsAPIBaseURL)
    }

    private var canGenerate: Bool {
        accountController.user != nil
            && finalClient.isConfigured
            && MomentsFinalRenderRules.canGenerate(
                project: project,
                template: template,
                balance: accountController.creditBalance,
                latestPreview: latestPreview
            )
            && !isGenerating
    }

    var body: some View {
        Section("Final Export") {
            LabeledContent("Credits", value: "\(template.creditCost)")
            AviCompanionView(
                state: .finalRender,
                message: "Final render commits credits after a usable export is delivered."
            )

            if let finalExport {
                Label("Export ready", systemImage: "square.and.arrow.up")
                ShareLink(item: finalExport.r2Key) {
                    Label("Share Export Reference", systemImage: "square.and.arrow.up")
                }
            }

            if let latestRenderJob {
                RenderJobStatusView(renderJob: latestRenderJob)

                Button {
                    Task { await refreshRenderStatus(renderJob: latestRenderJob) }
                } label: {
                    Label(isRefreshingStatus ? "Refreshing Status" : "Refresh Final Status", systemImage: "arrow.clockwise")
                }
                .disabled(accountController.user == nil || !statusClient.isConfigured || isRefreshingStatus)
            }

            Button {
                Task { await generateFinalRender() }
            } label: {
                Label(isGenerating ? "Rendering Final" : "Render Final", systemImage: "film")
            }
            .disabled(!canGenerate)

            if let statusMessage {
                AviStatusMessage(message: statusMessage)
            }
        }
    }

    private func generateFinalRender() async {
        guard let ownerUserId = accountController.user?.id else { return }

        isGenerating = true
        statusMessage = "Avi is preparing the final export."

        do {
            let finalRender = try await finalClient.generateFinalRender(
                projectId: project.id,
                ownerUserId: ownerUserId,
                template: template
            )
            if await projectStore.saveFinalRenderResult(
                ownerUserId: ownerUserId,
                projectId: project.id,
                finalRender: finalRender,
                template: template
            ) {
                statusMessage = "Export ready. Credits were committed for the delivered render."
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
            statusMessage = "Final render status updated."
        }

        isRefreshingStatus = false
    }
}

struct RenderJobStatusView: View {
    let renderJob: MomentRenderJob

    private var title: String {
        renderJob.status.replacingOccurrences(of: "_", with: " ").capitalized
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: renderJob.status == "failed" ? "exclamationmark.triangle" : "dot.radiowaves.left.and.right")
            if let errorMessage = renderJob.errorMessage, renderJob.status == "failed" {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if let model = renderJob.model {
                Text(model)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
