import SwiftUI

struct MomentsAppBootstrapView: View {
    @StateObject private var dependencies = MomentsDependencyContainer()
    @State private var selectedTab: MomentsRootTab = .home

    var body: some View {
        MomentsAppShellView(selectedTab: $selectedTab)
            .environmentObject(dependencies.accountController)
            .environmentObject(dependencies.projectsListWorkflow)
            .environmentObject(dependencies.homeViewModel)
            .environmentObject(dependencies.createViewModel)
            .environmentObject(dependencies.projectsViewModel)
            .environmentObject(dependencies.aviViewModel)
            .onReceive(dependencies.accountController.currentUserIdPublisher) { ownerUserId in
                dependencies.handleAccountChange(ownerUserId: ownerUserId)
            }
    }
}
