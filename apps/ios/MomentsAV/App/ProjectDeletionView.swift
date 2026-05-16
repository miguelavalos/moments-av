import SwiftUI

struct ProjectDeletionView: View {
    let project: MomentDraftProject
    let onDeleted: () -> Void

    @EnvironmentObject private var accountController: AccountController
    @EnvironmentObject private var projectStore: MomentsProjectStore
    @State private var isConfirming = false
    @State private var isDeleting = false
    @State private var statusMessage: String?

    private var deletionClient: MomentsDeletionClient {
        MomentsDeletionClient(baseURLString: AppConfig.momentsAPIBaseURL)
    }

    var body: some View {
        Section("Project") {
            Button(role: .destructive) {
                isConfirming = true
            } label: {
                Label(isDeleting ? "Deleting Project" : "Delete Project", systemImage: "trash")
            }
            .disabled(accountController.user == nil || !deletionClient.isConfigured || isDeleting)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .confirmationDialog("Delete this project?", isPresented: $isConfirming, titleVisibility: .visible) {
            Button("Delete Project", role: .destructive) {
                Task { await deleteProject() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Source media, previews, exports, and project metadata will be removed from the active Moments AV project view.")
        }
    }

    private func deleteProject() async {
        guard let ownerUserId = accountController.user?.id else { return }

        isDeleting = true
        statusMessage = nil

        do {
            _ = try await deletionClient.deleteProject(projectId: project.id, ownerUserId: ownerUserId)
            if await projectStore.deleteProject(ownerUserId: ownerUserId, projectId: project.id) {
                statusMessage = "Project deletion requested."
                onDeleted()
            }
        } catch {
            statusMessage = error.localizedDescription
        }

        isDeleting = false
    }
}
