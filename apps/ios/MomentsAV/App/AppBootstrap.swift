import SwiftUI

struct MomentsAppBootstrapView: View {
    @StateObject private var dependencies = MomentsDependencyContainer()

    var body: some View {
        MomentsRootView()
            .environmentObject(dependencies.accountController)
            .environmentObject(dependencies.projectsListWorkflow)
            .environmentObject(dependencies.homeViewModel)
            .environmentObject(dependencies.createViewModel)
            .environmentObject(dependencies.projectsViewModel)
            .onReceive(dependencies.accountController.currentUserIdPublisher) { ownerUserId in
                dependencies.handleAccountChange(ownerUserId: ownerUserId)
            }
    }
}
