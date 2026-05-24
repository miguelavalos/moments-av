import AVSettingsFoundation
import SwiftUI

struct MomentsProjectsScreen: View {
    @EnvironmentObject private var viewModel: MomentsProjectsViewModel
    @State private var projectPendingDeletion: MomentDraftProject?
    let continueProject: (MomentDraftProject) -> Void

    init(continueProject: @escaping (MomentDraftProject) -> Void = { _ in }) {
        self.continueProject = continueProject
    }

    var body: some View {
        ScrollView {
            projectsCard
            .padding(20)
        }
        .background(MomentsTheme.canvas.ignoresSafeArea())
        .navigationTitle("Projects")
        .confirmationDialog(
            "Delete project?",
            isPresented: deletionConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete Project", role: .destructive) {
                if let projectPendingDeletion {
                    viewModel.deleteProject(projectPendingDeletion)
                }
                projectPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) {
                projectPendingDeletion = nil
            }
        } message: {
            Text("This removes \(projectPendingDeletion?.title ?? "this project"), including source media records and generated artifacts.")
        }
    }

    private var projectsCard: some View {
        AVSettingsCard {
            Text("Projects")
                .font(.headline)

            if !viewModel.isSignedIn {
                MomentsProjectsUnavailableState(
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    title: "Sign in required",
                    message: "Project history loads after your account is connected."
                )
            } else if !viewModel.projectSummary.hasProjects {
                MomentsProjectsUnavailableState(
                    systemImage: "rectangle.stack.badge.plus",
                    title: "No projects yet",
                    message: "Create a moment first, then drafts, previews, and final exports will appear here."
                )
            } else {
                MomentsProjectsList(
                    projectSummary: viewModel.projectSummary,
                    selectedProjectId: viewModel.selectedProjectId
                ) { project in
                    viewModel.selectProject(project)
                }
                selectedProjectDetail
                statusMessage
            }
        }
    }

    @ViewBuilder
    private var selectedProjectDetail: some View {
        if viewModel.isLoadingProjectWorkspace {
            Divider()
                .padding(.vertical, 8)
            MomentsProjectLoadingDetail()
        } else if let workspace = viewModel.activeWorkspace, viewModel.selectedProjectId == workspace.project.id {
            Divider()
                .padding(.vertical, 8)
            MomentsProjectWorkspaceDetail(
                workspace: workspace,
                isDeletingProject: viewModel.isDeletingProject,
                continueProject: continueProject,
                requestDeleteProject: { project in
                    projectPendingDeletion = project
                }
            )
        }
    }

    @ViewBuilder
    private var statusMessage: some View {
        if let statusMessage = viewModel.statusMessage {
            MomentsProjectsStatusMessage(message: statusMessage)
        }
    }

    private var deletionConfirmationPresented: Binding<Bool> {
        Binding(
            get: { projectPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    projectPendingDeletion = nil
                }
            }
        )
    }
}

private struct MomentsProjectsUnavailableState: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(MomentsTheme.brandPalette.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }
}

private struct MomentsProjectsStatusMessage: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 2)
    }
}
