import AVSettingsFoundation
import SwiftUI

struct MomentsProjectsScreen: View {
    @EnvironmentObject private var viewModel: MomentsProjectsViewModel
    @State private var projectPendingDeletion: MomentDraftProject?
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    private var presentation: MomentsProjectsPresentation {
        MomentsProjectsPresentation.make(
            isSignedIn: viewModel.isSignedIn,
            projectSummary: viewModel.projectSummary,
            projectPendingDeletion: projectPendingDeletion
        )
    }

    init(continueProject: @escaping (MomentsProjectContinuationRequest) -> Void = { _ in }) {
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
            Text(presentation.deletionMessage)
        }
    }

    private var projectsCard: some View {
        AVSettingsCard {
            Text("Projects")
                .font(.headline)

            switch presentation.availability {
            case let .signedOut(unavailable), let .empty(unavailable):
                MomentsProjectsUnavailableState(presentation: unavailable)
            case .available:
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
    let presentation: MomentsProjectsUnavailablePresentation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: presentation.systemImage)
                .font(.title3)
                .foregroundStyle(MomentsTheme.brandPalette.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(presentation.title)
                    .font(.subheadline.weight(.semibold))
                Text(presentation.message)
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
