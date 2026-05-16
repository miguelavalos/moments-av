import AccountAV
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case create
    case projects
    case account
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .create: "Create"
        case .projects: "Projects"
        case .account: "Account"
        case .settings: "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .create: "sparkles"
        case .projects: "rectangle.stack"
        case .account: "person.crop.circle"
        case .settings: "gearshape"
        }
    }
}

struct RootView: View {
    @StateObject private var accountController = AccountController()
    @State private var selectedTab: AppTab = .create

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tabContent(for: tab)
                        .navigationTitle(tab.title)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.symbolName)
                }
                .tag(tab)
            }
        }
        .tint(MomentsTheme.accent)
        .environmentObject(accountController)
        .alert("Account action failed", isPresented: errorIsPresented) {
            Button("OK", role: .cancel) {
                accountController.errorMessage = nil
            }
        } message: {
            Text(accountController.errorMessage ?? "")
        }
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(
            get: { accountController.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    accountController.errorMessage = nil
                }
            }
        )
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .create:
            CreateMomentView()
        case .projects:
            ProjectsView()
        case .account:
            AccountView()
        case .settings:
            SettingsView()
        }
    }
}

struct CreateMomentView: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AppHeader()

                if accountController.isSignedIn {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose a memory format")
                            .font(.title2.weight(.semibold))

                        ForEach(MomentTemplate.sample) { template in
                            TemplateCard(template: template)
                        }
                    }

                    GuidePanel(
                        title: "Avi helps shape the story",
                        text: "Creation opens here after project state and media selection are connected."
                    )
                } else {
                    SignedOutGateView()
                }
            }
            .padding(20)
        }
        .background(MomentsTheme.background)
    }
}

struct SignedOutGateView: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Sign in to start a memory video", systemImage: "lock")
                .font(.title3.weight(.semibold))

            Text("Creation needs an Account AV session before photos, clips, or drafts can be attached to a private project.")
                .font(.body)
                .foregroundStyle(.secondary)

            AuthActionButtons()

            if !accountController.isAccountAvailable {
                Text("Account sign-in is not configured for this build.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct ProjectsView: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        Group {
            if accountController.isSignedIn {
                ContentUnavailableView(
                    "No projects yet",
                    systemImage: "film.stack",
                    description: Text("Drafts and exports will appear here after project sync is connected.")
                )
            } else {
                VStack(spacing: 18) {
                    Image(systemName: "lock.rectangle.stack")
                        .font(.system(size: 48))
                        .foregroundStyle(MomentsTheme.accent)
                    Text("Sign in to view projects")
                        .font(.title2.weight(.semibold))
                    Text("Your Moments AV drafts and exports appear only after Account AV sign-in.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    AuthActionButtons()
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(MomentsTheme.background)
    }
}

struct AccountView: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        List {
            Section("Account AV") {
                if let user = accountController.user {
                    LabeledContent("Status", value: "Signed in")
                    LabeledContent("Name", value: user.displayName)
                    if let email = user.emailAddress {
                        LabeledContent("Email", value: email)
                    }
                    Button("Sign Out", role: .destructive) {
                        accountController.signOut()
                    }
                    .disabled(accountController.isBusy)
                } else {
                    Text("Sign in before creating Moments AV projects.")
                        .foregroundStyle(.secondary)
                    AuthActionButtons()
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(MomentsTheme.background)
    }
}

struct AuthActionButtons: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        VStack(spacing: 10) {
            Button {
                accountController.signInWithApple()
            } label: {
                Label("Continue with Apple", systemImage: "apple.logo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                accountController.signInWithGoogle()
            } label: {
                Label("Continue with Google", systemImage: "globe")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .disabled(accountController.isBusy || !accountController.isAccountAvailable)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var accountController: AccountController

    var body: some View {
        List {
            Section("Account") {
                if accountController.isSignedIn {
                    NavigationLink("Account controls") {
                        AccountView()
                            .navigationTitle("Account")
                    }
                } else {
                    Text("Account controls appear after sign-in.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Privacy") {
                Label("Private by default", systemImage: "lock")
                Label("User-controlled export", systemImage: "square.and.arrow.up")
            }

            Section("Support") {
                Link("Support", destination: URL(string: "https://moments-av.avalsys.com/support")!)
                Link("Privacy Policy", destination: URL(string: "https://moments-av.avalsys.com/privacy")!)
            }
        }
        .scrollContentBackground(.hidden)
        .background(MomentsTheme.background)
    }
}

struct AppHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Moments AV")
                .font(.largeTitle.weight(.bold))
            Text("Turn selected photos and short clips into private memory videos.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct TemplateCard: View {
    let template: MomentTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(template.title)
                    .font(.headline)
                Spacer()
                Text(template.duration)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MomentsTheme.accent)
            }

            Text(template.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(template.mediaRange, systemImage: "photo.on.rectangle.angled")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct GuidePanel: View {
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.title3)
                .foregroundStyle(MomentsTheme.accent)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(MomentsTheme.panel, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct MomentTemplate: Identifiable {
    let id: String
    let title: String
    let duration: String
    let mediaRange: String
    let summary: String

    static let sample = [
        MomentTemplate(
            id: "birthday",
            title: "Birthday Message",
            duration: "30 sec",
            mediaRange: "3-20 photos or clips",
            summary: "A warm greeting built from selected memories and captions."
        ),
        MomentTemplate(
            id: "party",
            title: "Party Recap",
            duration: "45 sec",
            mediaRange: "6-40 photos or clips",
            summary: "A quick montage for gatherings, trips, and shared celebrations."
        ),
        MomentTemplate(
            id: "soft-roast",
            title: "Soft Roast",
            duration: "30 sec",
            mediaRange: "3-20 photos or clips",
            summary: "Light, affectionate humor for people who are in on the joke."
        )
    ]
}

enum MomentsTheme {
    static let accent = Color(red: 0.85, green: 0.36, blue: 0.28)
    static let background = Color(red: 0.97, green: 0.94, blue: 0.91)
    static let panel = Color(red: 1.0, green: 0.98, blue: 0.95)
}

#Preview {
    RootView()
}
