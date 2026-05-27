import AVAppShellFoundation
import PhotosUI
import SwiftUI

struct MomentsCreateScreen: View {
    @EnvironmentObject private var viewModel: MomentsCreateViewModel
    @State private var pickerItems: [PhotosPickerItem] = []
    let startSignInFlow: () -> Void
    let openCredits: () -> Void
    let cancelCreation: () -> Void

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
        .safeAreaPadding(.bottom, 82)
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
