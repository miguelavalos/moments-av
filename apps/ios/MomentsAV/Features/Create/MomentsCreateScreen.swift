import AVAppShellFoundation
import PhotosUI
import SwiftUI

struct MomentsCreateScreen: View {
    @EnvironmentObject private var viewModel: MomentsCreateViewModel
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var workflowErrorAlertMessage: String?
    let startSignInFlow: () -> Void
    let openCredits: () -> Void
    let cancelCreation: () -> Void
    let bottomSafeAreaPadding: CGFloat

    init(
        startSignInFlow: @escaping () -> Void,
        openCredits: @escaping () -> Void,
        cancelCreation: @escaping () -> Void,
        bottomSafeAreaPadding: CGFloat = 82
    ) {
        self.startSignInFlow = startSignInFlow
        self.openCredits = openCredits
        self.cancelCreation = cancelCreation
        self.bottomSafeAreaPadding = bottomSafeAreaPadding
    }

    var body: some View {
        MomentsCreateWorkflowContent(
            viewModel: viewModel,
            pickerItems: $pickerItems,
            startSignInFlow: startSignInFlow,
            openCredits: openCredits,
            cancelCreation: cancelCreation
        )
        .background(MomentsTheme.shellBackground.ignoresSafeArea())
        .safeAreaPadding(.horizontal, 20)
        .safeAreaPadding(.top, 12)
        .safeAreaPadding(.bottom, bottomSafeAreaPadding)
        .fullScreenCover(
            isPresented: Binding(
                get: { viewModel.workflowPresentation.showsBlockingPreparation || viewModel.isPreparingStory },
                set: { _ in }
            )
        ) {
            MomentsCreateBlockingPreparationView(
                presentation: viewModel.workflowPresentation,
                isPreparingStory: viewModel.isPreparingStory
            )
            .interactiveDismissDisabled()
        }
        .onChange(of: viewModel.workflowErrorAlertMessage) { _, message in
            workflowErrorAlertMessage = message
        }
        .alert(MomentsL10n.string("access.error.title"), isPresented: Binding(
            get: { workflowErrorAlertMessage != nil },
            set: { isPresented in
                if !isPresented {
                    workflowErrorAlertMessage = nil
                }
            }
        )) {
            Button(MomentsL10n.string("common.ok"), role: .cancel) {
                workflowErrorAlertMessage = nil
            }
        } message: {
            Text(workflowErrorAlertMessage ?? MomentsL10n.string("common.tryAgain"))
        }
    }
}

enum MomentsCreateSection: Hashable {
    case review
    case media
    case story
    case preview
    case finalRender

    init(focus: MomentsProjectContinuationFocus) {
        switch focus {
        case .review:
            self = .review
        case .media:
            self = .media
        case .story:
            self = .story
        case .preview:
            self = .preview
        case .finalRender:
            self = .finalRender
        }
    }
}
