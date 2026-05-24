import PhotosUI
import SwiftUI

struct MomentsCreateScreen: View {
    @EnvironmentObject private var viewModel: MomentsCreateViewModel
    @State private var pickerItems: [PhotosPickerItem] = []

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                MomentsCreateWorkflowContent(viewModel: viewModel, pickerItems: $pickerItems)
            }
            .onChange(of: viewModel.pendingFocus) { _, focus in
                guard let focus else { return }
                scrollToPendingFocus(focus, proxy: proxy)
            }
            .onChange(of: viewModel.createdProjectId) { _, _ in
                guard let focus = viewModel.pendingFocus else { return }
                scrollToPendingFocus(focus, proxy: proxy)
            }
            .onChange(of: viewModel.activeProject?.id) { _, _ in
                guard let focus = viewModel.pendingFocus else { return }
                scrollToPendingFocus(focus, proxy: proxy)
            }
        }
        .background(MomentsTheme.canvas.ignoresSafeArea())
        .navigationTitle("Create")
    }

    private func scrollToPendingFocus(_ focus: MomentsProjectContinuationFocus, proxy: ScrollViewProxy) {
        guard canScroll(to: focus) else { return }

        Task { @MainActor in
            await Task.yield()
            withAnimation(.snappy) {
                proxy.scrollTo(MomentsCreateSection(focus: focus), anchor: .top)
            }
            viewModel.consumePendingFocus()
        }
    }

    private func canScroll(to focus: MomentsProjectContinuationFocus) -> Bool {
        switch focus {
        case .review:
            viewModel.activeProject != nil
        case .media, .story, .preview, .finalRender:
            viewModel.createdProjectId != nil
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
