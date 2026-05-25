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
            MomentsProjectsCard(
                presentation: presentation,
                projectSummary: viewModel.projectSummary,
                selectedProjectId: viewModel.selectedProjectId,
                isLoadingProjectWorkspace: viewModel.isLoadingProjectWorkspace,
                activeWorkspace: viewModel.activeWorkspace,
                isDeletingProject: viewModel.isDeletingProject,
                statusMessage: viewModel.statusMessage,
                selectProject: viewModel.selectProject,
                continueProject: continueProject,
                requestDeleteProject: { project in
                    projectPendingDeletion = project
                }
            )
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
                confirmProjectDeletion()
            }
            Button("Cancel", role: .cancel) {
                cancelProjectDeletion()
            }
        } message: {
            Text(presentation.deletionMessage)
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

    private func confirmProjectDeletion() {
        if let projectPendingDeletion {
            viewModel.deleteProject(projectPendingDeletion)
        }
        projectPendingDeletion = nil
    }

    private func cancelProjectDeletion() {
        projectPendingDeletion = nil
    }
}

private struct MomentsProjectsCard: View {
    let presentation: MomentsProjectsPresentation
    let projectSummary: MomentsProjectListSummary
    let selectedProjectId: String?
    let isLoadingProjectWorkspace: Bool
    let activeWorkspace: MomentProjectWorkspace?
    let isDeletingProject: Bool
    let statusMessage: String?
    let selectProject: (MomentDraftProject) -> Void
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        AVSettingsCard {
            Text("Projects")
                .font(.headline)

            switch presentation.availability {
            case let .signedOut(unavailable), let .empty(unavailable):
                MomentsProjectsUnavailableState(presentation: unavailable)
            case .available:
                MomentsProjectsList(
                    projectSummary: projectSummary,
                    selectedProjectId: selectedProjectId,
                    selectProject: selectProject
                )
                MomentsProjectsSelectedDetail(
                    selectedProjectId: selectedProjectId,
                    isLoadingProjectWorkspace: isLoadingProjectWorkspace,
                    activeWorkspace: activeWorkspace,
                    isDeletingProject: isDeletingProject,
                    continueProject: continueProject,
                    requestDeleteProject: requestDeleteProject
                )
                MomentsProjectsStatusMessage(message: statusMessage)
            }
        }
    }
}

private struct MomentsProjectsSelectedDetail: View {
    let selectedProjectId: String?
    let isLoadingProjectWorkspace: Bool
    let activeWorkspace: MomentProjectWorkspace?
    let isDeletingProject: Bool
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let requestDeleteProject: (MomentDraftProject) -> Void

    var body: some View {
        if isLoadingProjectWorkspace {
            Divider()
                .padding(.vertical, 8)
            MomentsProjectLoadingDetail()
        } else if let activeWorkspace, selectedProjectId == activeWorkspace.project.id {
            Divider()
                .padding(.vertical, 8)
            MomentsProjectWorkspaceDetail(
                workspace: activeWorkspace,
                isDeletingProject: isDeletingProject,
                continueProject: continueProject,
                requestDeleteProject: requestDeleteProject
            )
        }
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
    let message: String?

    var body: some View {
        if let message {
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
}
