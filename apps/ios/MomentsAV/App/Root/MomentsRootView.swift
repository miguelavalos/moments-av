import SwiftUI

struct MomentsRootView: View {
    @State private var selectedTab: MomentsRootTab = .home

    var body: some View {
        MomentsAppShellView(selectedTab: $selectedTab)
    }
}
