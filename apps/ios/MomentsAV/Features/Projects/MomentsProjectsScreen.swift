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
