import SwiftUI

struct FinalRenderView: View {
    let template: MomentTemplate
    let project: MomentDraftProject
    let latestPreview: MomentArtifact?
    let finalExport: MomentArtifact?

    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var projectStore: MomentsProjectStore
    @State private var statusMessage: String?
    @State private var isGenerating = false

    private var finalClient: MomentsFinalRenderClient {
        MomentsFinalRenderClient(baseURLString: AppConfig.momentsAPIBaseURL)
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
            Text("Final render commits credits after a usable export is delivered.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let finalExport {
                Label("Export ready", systemImage: "square.and.arrow.up")
                ShareLink(item: finalExport.r2Key) {
                    Label("Share Export Reference", systemImage: "square.and.arrow.up")
                }
            }

            Button {
                Task { await generateFinalRender() }
            } label: {
                Label(isGenerating ? "Rendering Final" : "Render Final", systemImage: "film")
            }
            .disabled(!canGenerate)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
}
