import AVAppShellFoundation
import SwiftUI

struct MomentsProjectsScreen: View {
    @EnvironmentObject private var viewModel: MomentsProjectsViewModel
    @EnvironmentObject private var createViewModel: MomentsCreateViewModel
    @State private var projectPendingDeletion: MomentDraftProject?
    @State private var galleryVideoPendingDeletion: MomentsGalleryVideoPresentation?
    let mode: MomentsHubMode
    let balance: MomentsCreditBalance
    let continueProject: (MomentsProjectContinuationRequest) -> Void
    let startProject: () -> Void
    let startSignInFlow: () -> Void
    let openCredits: () -> Void
    private var presentation: MomentsProjectsPresentation {
        MomentsProjectsPresentation.make(
            isSignedIn: viewModel.isSignedIn,
            projectSummary: viewModel.projectSummary,
            projectPendingDeletion: projectPendingDeletion
        )
    }

    init(
        mode: MomentsHubMode = .inProgress,
        balance: MomentsCreditBalance = .empty,
        continueProject: @escaping (MomentsProjectContinuationRequest) -> Void = { _ in },
        startProject: @escaping () -> Void = {},
        startSignInFlow: @escaping () -> Void = {},
        openCredits: @escaping () -> Void = {}
    ) {
        self.mode = mode
        self.balance = balance
        self.continueProject = continueProject
        self.startProject = startProject
        self.startSignInFlow = startSignInFlow
        self.openCredits = openCredits
    }

    var body: some View {
        AVAppShellScrollableScreenScaffold {
            MomentsTheme.shellBackground
        } content: {
            if createViewModel.hasLocalMomentWorkspace {
                MomentsCurrentCreationCard(
                    selectedCount: createViewModel.mediaSelectedCount,
                    continueCreation: startProject
                )
            }

            MomentsProjectsCard(
                mode: mode,
                presentation: presentation,
                balance: balance,
                projectSummary: viewModel.projectSummary,
                selectedProjectId: viewModel.selectedProjectId,
                isLoadingProjectWorkspace: viewModel.isLoadingProjectWorkspace,
                activeWorkspace: viewModel.activeWorkspace,
                isDeletingProject: viewModel.isDeletingProject,
                statusMessage: viewModel.statusMessage,
                galleryVideos: viewModel.galleryVideos,
                selectProject: viewModel.selectProject,
                continueProject: continueProject,
                startProject: startProject,
                startSignInFlow: startSignInFlow,
                openCredits: openCredits,
                requestDeleteGalleryVideo: { video in
                    galleryVideoPendingDeletion = video
                },
                requestDeleteProject: { project in
                    projectPendingDeletion = project
                }
            )
        }
        .confirmationDialog(
            L10n.string("projects.deleteProject.title"),
            isPresented: deletionConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(L10n.string("projects.deleteProject.button"), role: .destructive) {
                confirmProjectDeletion()
            }
            Button(L10n.string("common.cancel"), role: .cancel) {
                cancelProjectDeletion()
            }
        } message: {
            Text(presentation.deletionMessage)
        }
        .confirmationDialog(
            L10n.string("gallery.delete.title"),
            isPresented: galleryDeletionConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(L10n.string("gallery.delete.button"), role: .destructive) {
                confirmGalleryVideoDeletion()
            }
            Button(L10n.string("common.cancel"), role: .cancel) {
                cancelGalleryVideoDeletion()
            }
        } message: {
            Text(L10n.string("gallery.delete.message"))
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
            if createViewModel.activeProjectId == projectPendingDeletion.id {
                createViewModel.clearSessionState()
            }
            viewModel.deleteProject(projectPendingDeletion)
        }
        projectPendingDeletion = nil
    }

    private func cancelProjectDeletion() {
        projectPendingDeletion = nil
    }

    private var galleryDeletionConfirmationPresented: Binding<Bool> {
        Binding(
            get: { galleryVideoPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    galleryVideoPendingDeletion = nil
                }
            }
        )
    }

    private func confirmGalleryVideoDeletion() {
        if let galleryVideoPendingDeletion {
            viewModel.deleteGalleryVideo(galleryVideoPendingDeletion)
        }
        galleryVideoPendingDeletion = nil
    }

    private func cancelGalleryVideoDeletion() {
        galleryVideoPendingDeletion = nil
    }
}
